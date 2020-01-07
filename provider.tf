provider "google" {
  region  = var.region
  zone    = var.region_zone
  project = var.project_name

  version = "~> 3.4.0"
}
