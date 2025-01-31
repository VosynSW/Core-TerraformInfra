variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "Region where the bucket will be created"
  type        = string
  default     = "us-central1"
}