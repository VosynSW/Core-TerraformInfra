variable "environments" {
  type = map(object({
    folder_name = string,
    list_of_projects = list(object({
      project_name = string,
      project_id   = string
    }))
  }))
}

variable "apis" {
  description = "The list of APIs to enable"
  type        = set(string)
}