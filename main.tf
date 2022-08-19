terraform {
  required_version = ">= 1.0.11"

  backend "gcs" {
    bucket = "tf-seriousben-states"
  }
  required_providers {
    google = {
      version = "~> 4.32.0"
    }
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

resource "google_dns_record_set" "keybase-txt-seriousben" {
  name = "_keybase.${google_dns_managed_zone.root.dns_name}"
  type = "TXT"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["keybase-site-verification=ERi_i6uGAAD2zab4lSiVDYlOXttrWBMlRFwuD3fykTk"]
}
resource "google_dns_record_set" "github-pages-txt-seriousben" {
  name = "_github-pages-challenge-seriousben.${google_dns_managed_zone.root.dns_name}"
  type = "TXT"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["7234c2752e5658f71e93b4471ba20a"]
}

resource "google_dns_record_set" "github-pages-seriousben" {
  name = google_dns_managed_zone.root.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

resource "google_dns_record_set" "github-pages-www-seriousben" {
  name = "www.${google_dns_managed_zone.root.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["seriousben.github.io."]
}

resource "google_dns_record_set" "render-projects-seriousben" {
  name = "badges.${google_dns_managed_zone.root.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["seriousben-projects.onrender.com."]
}

