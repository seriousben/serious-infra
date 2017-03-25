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
  name = "main-network"
}

resource "google_compute_subnetwork" "main" {
  name          = "${var.project_name}-${var.region}"
  ip_cidr_range = "10.1.2.0/24"
  network       = "${google_compute_network.main.self_link}"
  region        = "${var.region}"
}

resource "google_dns_managed_zone" "main" {
  name        = "projects-seriousben-com"
  dns_name    = "projects.seriousben.com."
  description = "projects.seriousben.com DNS zone"
}

resource "random_id" "master-password" {
  keepers = {
    region = "${var.region}"
  }

  byte_length = 16
}

/* Leftovers of trying to not create a Loadbalancer from GKE
resource "google_compute_target_pool" "main" {
  name = "main"

  lifecycle {
    ignore_changes = ["instances"]
  }
}
*/

resource "google_container_cluster" "main" {
  name       = "main"
  zone       = "${var.region_zone}"

  network    = "${google_compute_network.main.name}"
  subnetwork = "${google_compute_subnetwork.main.name}"

  initial_node_count = 1

  master_auth {
    username = "admin"
    password = "${random_id.master-password.b64}"
  }

  node_config {
    machine_type = "g1-small"

    oauth_scopes = [
      "https://www.googleapis.com/auth/projecthosting",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  /* Leftovers of trying to not create a Loadbalancer from GKE
  provisioner "local-exec" {
    description = "Add instance group manager backing this cluster to target group for loadbalancing"
    command = "gcloud compute instance-groups managed set-target-pools \"$(echo '${element(google_container_cluster.main.instance_group_urls, 0)}' | sed 's/instanceGroup/instanceGroupManager/')\" --target-pools=${google_compute_target_pool.main.name}"
  }
  */

  provisioner "local-exec" {
    # description = "Install kubectl"
    command = "gcloud components install kubectl"
  }

  provisioner "local-exec" {
    # description = "Fetch cluster credentials for kubectl"
    command = "gcloud container clusters get-credentials main"
  }

  provisioner "local-exec" {
    # description = "Create cluster frontend"
    command = "kubectl create -f frontend.yml"
  }

  provisioner "local-exec" {
    # description = "Delete cluster frontend"
    when = "destroy"
    command = "kubectl delete -f frontend.yml"
  }
}

data "external" "frontend_loadbalancer" {
  program = ["./wait-for-lb-ip.sh"]
}

/* Leftovers of trying to not create a Loadbalancer from GKE
resource "google_compute_firewall" "main" {
  name    = "main"
  network    = "${google_compute_network.main.name}"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }
}

resource "google_compute_forwarding_rule" "main" {
  name = "main-http"
  target = "${google_compute_target_pool.main.self_link}"
  port_range = "8080"

  # network    = "${google_compute_network.main.self_link}"
  # subnetwork = "${google_compute_subnetwork.main.self_link}"
}

resource "google_dns_record_set" "main" {
  name  = "${google_dns_managed_zone.main.dns_name}"
  type  = "A"
  ttl   = 300

  managed_zone = "${google_dns_managed_zone.main.name}"

  rrdatas = ["${google_compute_forwarding_rule.main.ip_address}"]
}
*/

resource "google_dns_record_set" "main" {
  name  = "${google_dns_managed_zone.main.dns_name}"
  type  = "A"
  ttl   = 300

  managed_zone = "${google_dns_managed_zone.main.name}"

  rrdatas = ["${data.external.frontend_loadbalancer.result.external_ip}"]
}
