resource "google_project_service" "project_apis" {
  # The for_each block creates a map of unique keys for each project-API combination.
  # This allows Terraform to manage each API enablement as a separate resource.
  for_each = {
    # The outer flatten function is used to create a single list from the nested structure.
    for item in flatten([
      # Iterate through each environment in the var.environments map.
      for env in var.environments : [
        # For each environment, iterate through its list of projects.
        for proj in env.list_of_projects : [
          # For each project, iterate through the list of APIs to be enabled.
          for api in var.apis : {
            # Create an object with project_id and api for each combination.
            project_id = proj.project_id
            api        = api
          }
        ]
      ]
    # Create a unique key for each item using project_id and api, and map it to the item itself.
    ]) : "${item.project_id}-${item.api}" => item
  }

  # Set the project ID for the current resource iteration.
  project = each.value.project_id
  # Set the API service to be enabled for the current resource iteration.
  service = each.value.api

  # If true, disable services that depend on this service when this service is destroyed.
  disable_dependent_services = true
  # If false, prevent the service from being disabled via Terraform destroy.
  disable_on_destroy         = false
}