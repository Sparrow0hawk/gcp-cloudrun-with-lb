locals {
  project = "cloudrun-with-lb"
  location = "europe-west1"
}

resource "google_project_service" "run" {
  project = local.project
  service = "run.googleapis.com"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "example"
  location = local.location
  project  = local.project
  ingress = "INGRESS_TRAFFIC_ALL"


  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
  depends_on = [google_project_service.run]
}

resource "google_cloud_run_v2_service_iam_binding" "default" {
  name     = google_cloud_run_v2_service.default.name
  project  = local.project
  location = local.location

  role = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}
