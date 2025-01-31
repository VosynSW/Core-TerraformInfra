resource "google_compute_instance" "vm_instances" {
  for_each = var.instances

  name         = each.value.instance_name
  machine_type = each.value.machine_type
  zone         = each.value.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.disk_size
      type  = each.value.disk_type
    }
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork

    access_config {
      # Assigns an external IP
    }
  }

  metadata = each.value.metadata

  service_account {
    email  = each.value.service_account_email
    scopes = each.value.scopes
  }

  tags = each.value.tags
}
