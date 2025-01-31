# terraform {
#   required_providers {
#     google-beta = {
#       source  = "hashicorp/google-beta"
#       version = ">=5.14.0"
#     }
#     google = {
#       source  = "hashicorp/google"
#       version = ">=5.14.0"
#     }
#   }
#   required_version = ">= 1.5"
# }

## ---------------------------------------------------------------------------------------------------------------------
## Cloud Run Functions Source Code
## ---------------------------------------------------------------------------------------------------------------------
data "archive_file" "source_code" {
  type        = "zip"
  output_path = "/tmp/${var.name}-${var.env}.zip"
  source_dir  = var.source_dir
}

resource "google_storage_bucket_object" "source_code" {
  name   = "${var.name}-${var.env}.zip"
  bucket = var.source_bucket
  source = data.archive_file.source_code.output_path
}

## ---------------------------------------------------------------------------------------------------------------------
## Cloud Run Functions
## ---------------------------------------------------------------------------------------------------------------------
resource "google_cloudfunctions2_function" "default" {
  name        = "${var.env}-${var.name}"
  location    = var.region
  project     = var.gcp_project_id
  description = "Translation Pipeline - ${var.env}-${var.name} function"

  build_config {
    runtime               = var.config.runtime
    entry_point           = var.config.entry_point
    environment_variables = var.build_vars
    source {
      storage_source {
        bucket = var.source_bucket
        object = google_storage_bucket_object.source_code.name
      }
    }
  }

  service_config {
    max_instance_count             = var.config.max_instances
    min_instance_count             = var.config.min_intances
    available_memory               = var.config.memory
    timeout_seconds                = var.config.timeout
    environment_variables          = var.env_vars
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    vpc_connector                  = var.vpc_connector
    service_account_email          = var.function_sa
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = var.trigger_sa
    event_filters {
      attribute = "bucket"
      value     = var.trigger_bucket
    }
  }

  lifecycle {
    replace_triggered_by = [
      google_storage_bucket_object.source_code
    ]
  }
}