provider "google" {
  region  = var.region
  zone    = var.region_zone
  project = var.project_name

  version = "~> 2.20.0"
}
