variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "instances" {
  description = "A map of Compute Engine instances with their configurations"
  type = map(object({
    instance_name         = string
    machine_type          = string
    zone                 = string
    image                = string
    disk_size            = number
    disk_type            = string
    network              = string
    subnetwork           = string
    metadata             = map(string)
    service_account_email = string
    scopes               = list(string)
    tags                 = list(string)
  }))
}
