// vpc module
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=5.14.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.14.0"
    }
  }
  required_version = ">= 1.5"
}

resource "google_compute_network" "private_network" {
  project                 = var.gcp_project_id
  name                    = var.name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false

}

resource "google_compute_subnetwork" "private_subnetwork" {
  name                     = "${var.name}-subnet"
  description              = "Private subnet for the VPC"
  ip_cidr_range            = var.ip_cidr_range.nodes
  project                  = var.gcp_project_id
  region                   = var.gcp_region
  network                  = google_compute_network.private_network.id
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.ip_cidr_range.pods
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.ip_cidr_range.services
  }
  dynamic "log_config" {
    for_each = var.vpc_flow_log_enable == true ? [1] : []
    content {
      flow_sampling = 1.0
      metadata      = "INCLUDE_ALL_METADATA"
    }
  }
}

# Proxy subnet for internal ingress
resource "google_compute_subnetwork" "network-for-sync-gateway-lb" {
  provider = google-beta

  name          = "syncgateway-lb-subnet"
  ip_cidr_range = "172.20.0.0/24"
  region        = var.gcp_region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.private_network.name
}

# We need to allocate an IP block for private IPs. We want everything in the VPC
# to have a private IP. This improves security and latency, since requests to
# private IPs are routed through Google's network, not the Internet.
resource "google_compute_global_address" "private_ip_block" {

  name         = "private-ip-block-${var.name}"
  description  = "A block of private IP addresses that are accessible only from within the VPC."
  project      = var.gcp_project_id
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  # We don't specify a address range because Google will automatically assign one for us.
  prefix_length = 20 # ~4k IPs
  network       = google_compute_network.private_network.self_link
}

# This enables private services access. This makes it possible for instances
# within the VPC and Google services to communicate exclusively using internal
# IP addresses


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

## Since we have created Private Subnet, We need NAT for resource in this
## private subnet to reach to the internets
resource "google_compute_router" "router" {

  name    = "vpc-router-${var.name}"
  project = var.gcp_project_id
  region  = google_compute_subnetwork.private_subnetwork.region
  network = google_compute_network.private_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "vpc-router-nat-${var.name}"
  project                            = var.gcp_project_id
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "rules" {
  count   = length(var.firewall_rules)
  name    = var.firewall_rules[count.index].name
  network = google_compute_network.private_network.id

  dynamic "allow" {
    for_each = var.firewall_rules[count.index].allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  source_tags   = var.firewall_rules[count.index].source_tags
  source_ranges = var.firewall_rules[count.index].source_ranges
  target_tags   = var.firewall_rules[count.index].target_tags
}

# VPC Access Connector
# Used for Cloud Run Function to communicate with GKE cluster.
resource "google_vpc_access_connector" "connector" {
  name          = "crf-vpc-connector"
  region        = var.gcp_region
  ip_cidr_range = var.ip_cidr_range.connector
  network       = google_compute_network.private_network.name
  min_instances = 2
  max_instances = 3
  machine_type  = "e2-micro"
}
