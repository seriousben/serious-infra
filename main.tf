terraform {
  required_version = ">= 0.12"

  backend "gcs" {
    bucket = "tf-seriousben-states"
    path   = "states/tf-projects-seriousben.tfstate"
  }
}

resource "google_compute_network" "main" {
  name                    = "main-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "${var.project_name}-${var.region}"
  ip_cidr_range = "10.1.2.0/24"
  network       = google_compute_network.main.self_link
  region        = var.region
}

resource "google_container_cluster" "main" {
  name = "main"

  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.main.name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  logging_service    = "none"
  monitoring_service = "none"

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = true
    }
  }
}

resource "google_container_node_pool" "main" {
  name       = "main"
  cluster    = "${google_container_cluster.main.name}"
  node_count = 1

  node_config {
    disk_size_gb = 50
    machine_type = "n1-standard-2"

    oauth_scopes = [
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

////////////////////
// SERIOUSBEN.COM
////////////////////

resource "google_dns_managed_zone" "root" {
  name        = "seriousben-com"
  dns_name    = "seriousben.com."
  description = "seriousben.com DNS zone"
}

