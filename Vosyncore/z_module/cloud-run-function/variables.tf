variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "Region where the bucket will be created"
  type        = string
  default     = "us-central1"
}

/**
  * Cloud Run Function Module Variables
*/

## ---------------------------------------------------------------------------------------------------------------------
## Required Variables
## ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the Cloudrun"
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloudrun"
  type        = string
}

variable "gcp_project_id" {
  description = "The Google Project Id"
  type        = string
}

variable "env" {
  description = "Environment variable"
  type        = string
}

variable "source_bucket" {
  description = "The name of Source Code Bucket for Cloudrun"
  type        = string
}

variable "source_dir" {
  description = "The source code directory for Cloudrun"
  type        = string
}

variable "trigger_bucket" {
  description = "The name of Trigger Bucket for Cloudrun"
  type        = string
}

variable "trigger_sa" {
  description = "The Trigger service account email"
  type        = string
}

variable "function_sa" {
  description = "The Cloud Run Function service account email"
  type        = string
}

variable "env_vars" {
  description = "Cloud Run Functions environment variables"
  type        = map(string)
}

variable "vpc_connector" {
  description = "The VPC Connector fot the Cloud Run Function"
  type        = string
}

variable "config" {
  type = object({
    runtime       = string
    entry_point   = string
    min_intances  = number
    max_instances = number
    memory        = string
    timeout       = number
  })
  default = (
    {
      runtime       = "python312"
      entry_point   = "cloudrun_handler"
      min_intances  = 0
      max_instances = 1
      memory        = "128Mi"
      timeout       = 15
    }
  )
  description = "Cloud Run Function Service settings"
}

## ---------------------------------------------------------------------------------------------------------------------
## Optional Variables
## ---------------------------------------------------------------------------------------------------------------------

variable "build_vars" {
  description = "Cloud Run Functions build environment variables"
  type        = map(string)
  default     = null
}