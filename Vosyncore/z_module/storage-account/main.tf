

resource "google_storage_bucket" "gcs_bucket" {
  name          = var.bucket_name
  location      = var.region
  storage_class = var.storage_class

  versioning {
    enabled = var.versioning_enabled
  }
}

 #uniform_bucket_level_access = var.uniform_bucket_level_access

 #labels = {
#environment = var.environment
 # }