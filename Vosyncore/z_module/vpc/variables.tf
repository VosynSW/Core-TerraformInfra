variable "name" {
  description = "The name of the VPC to create"
  type        = string
}

variable "gcp_region" {
  description = "The default region for VPC"
  type        = string
}

variable "ip_cidr_range" {
  description = "Cluster CIDR IPs for Nodes, Pods, and Services. Each CIDR is represeted as, e.g., 10.10.0.0/20"
  type = object({
    nodes     = string
    pods      = string
    services  = string
    connector = string
  })
}

variable "vpc_flow_log_enable" {
  description = "VPC flow logs status"
  type        = bool
  default     = false
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "firewall_rules" {
  description = "List of firewall rules to be created"
  type = list(object({
    name = string
    allow = list(object({
      protocol = string
      ports    = optional(list(string))
    }))
    source_tags   = optional(list(string))
    source_ranges = optional(list(string))
    target_tags   = optional(list(string))
  }))
  default = []
}
