variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "Region where the bucket will be created"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Unique name for the GCS bucket"
  type        = string
}

variable "storage_class" {
  description = "GCS storage class (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

#variable "object_retention_days" {
 # description = "Number of days before objects are deleted"
  #type        = number
#  default     = 30
#}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access"
  type        = bool
  default     = true
}
variable "environment" {
 description = "Environment label (e.g., dev, staging, prod)"
 type        = string
}
