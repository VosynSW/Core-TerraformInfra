resource "google_cloud_run_service" "cloud-run-tf" {
  name     = "cloud-run-tf"
  location = "us-central1"

  template {
    spec {
      #containers {
      #  image = "us-docker.pkg.dev/cloudrun/container/hello"
      #}
    }
  }

   traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_policy" "pub1-access" {
    service = google_cloud_run_service.cloud-run-tf.name
    location = google_cloud_run_service.cloud-run-tf.location
    policy_data = data.google_iam_policy.pub-1
  
}

data "google_iam_policy" "pub-1"{
    binding {
      role = "roles/run.invoker"
      members = ["allUsers"]
    }
}