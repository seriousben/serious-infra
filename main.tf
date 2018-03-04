terraform {
  backend "gcs" {
    bucket  = "tf-seriousben-states"
    path    = "states/tf-projects-seriousben.tfstate"
    project = "projects-seriousben"
  }
}

variable "region" {
  default = "us-east1"
}

variable "region_zone" {
  default = "us-east1-d"
}

variable "project_name" {
  default = "projects-seriousben"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "~/.gcloud/projects-seriousben.json"
}

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file(var.credentials_file_path)}"
}

resource "google_compute_network" "main" {
  name                    = "main-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "${var.project_name}-${var.region}"
  ip_cidr_range = "10.1.2.0/24"
  network       = "${google_compute_network.main.self_link}"
  region        = "${var.region}"
}

resource "random_id" "master-password" {
  keepers = {
    region = "${var.region}"
  }

  byte_length = 16
}

resource "google_container_cluster" "main" {
  name = "main"
  zone = "${var.region_zone}"

  network    = "${google_compute_network.main.name}"
  subnetwork = "${google_compute_subnetwork.main.name}"

  master_auth {
    username = "admin"
    password = "${random_id.master-password.b64}"
  }

  enable_legacy_abac = false

  node_pool = [{
    name       = "default"
    node_count = 1

    node_config {
      machine_type = "n1-standard-2"

      oauth_scopes = [
        "https://www.googleapis.com/auth/projecthosting",
        "https://www.googleapis.com/auth/devstorage.full_control",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    }

    management {
      auto_repair  = true
      auto_upgrade = true
    }
  }]

  provisioner "local-exec" {
    # description = "Install kubectl"
    command = "gcloud components install kubectl"
  }

  provisioner "local-exec" {
    # description = "Fetch cluster credentials for kubectl"
    command = "gcloud container clusters get-credentials main"
  }

  provisioner "local-exec" {
    # description = "Setup rbac"
    command = "kubectl apply -f rbac-setup"
  }

  provisioner "local-exec" {
    # description = "Install helm"
    command = "helm init --service-account tiller --wait"
  }

  provisioner "local-exec" {
    # description = "Create cluster base services"
    command = "helm upgrade --install base ./base-charts"
  }

  provisioner "local-exec" {
    # description = "Delete cluster base services"
    when    = "destroy"
    command = "helm delete --purge base"
  }
}

data "external" "frontend_loadbalancer" {
  program = ["./wait-for-lb-ip.sh", "base-nginx-ingress-controller", "default"]

  //result =
  //{
  //  "name": frontend",
  //  "external_ip": "127.0.0.1"
  //}
}

////////////////////
// SERIOUSBEN.COM
////////////////////

resource "google_dns_managed_zone" "root" {
  name        = "seriousben-com"
  dns_name    = "seriousben.com."
  description = "seriousben.com DNS zone"
}

resource "google_dns_record_set" "root" {
  name = "seriousben.com."
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.root.name}"

  rrdatas = ["${data.external.frontend_loadbalancer.result.external_ip}"]
}

resource "google_dns_record_set" "www-seriousben" {
  name = "www.seriousben.com."
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.root.name}"

  rrdatas = ["${data.external.frontend_loadbalancer.result.external_ip}"]
}

////////////////////
// VIDEO-BOOMERANG.COM
////////////////////

resource "google_dns_managed_zone" "video-boomerang" {
  name        = "video-boomerang-com"
  dns_name    = "video-boomerang.com."
  description = "video-boomerang.com DNS zone"
}

resource "google_dns_record_set" "video-boomerang" {
  name = "video-boomerang.com."
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.video-boomerang.name}"

  rrdatas = ["${data.external.frontend_loadbalancer.result.external_ip}"]
}

resource "google_dns_record_set" "www-video-boomerang" {
  name = "www.video-boomerang.com."
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.video-boomerang.name}"

  rrdatas = ["${data.external.frontend_loadbalancer.result.external_ip}"]
}

resource "google_dns_record_set" "api-video-boomerang" {
  name = "api.video-boomerang.com."
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.video-boomerang.name}"

  rrdatas = ["${data.external.frontend_loadbalancer.result.external_ip}"]
}
