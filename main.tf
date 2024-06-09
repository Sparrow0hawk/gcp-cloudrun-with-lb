locals {
  project = "cloudrun-with-lb"
  lb_name = "cloud-run-lb"
  location = "europe-west1"
}

resource "google_project_service" "run" {
  project = local.project
  service = "run.googleapis.com"
}

resource "google_project_service" "compute" {
  project = local.project
  service = "compute.googleapis.com"
}

module "lb-http" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 10.0"

  name    = local.lb_name
  project = local.project

  ssl                             = true
  managed_ssl_certificate_domains = [trimprefix(google_cloud_run_v2_service.default.uri, "https://")]
  https_redirect                  = true
  labels                          = { "example-label" = "cloud-run-example" }

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }
  depends_on = [google_project_service.compute]
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "serverless-neg"
  project = local.project
  network_endpoint_type = "SERVERLESS"
  region                = local.location

  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
  depends_on = [google_project_service.compute]
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
