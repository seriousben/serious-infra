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
resource "google_dns_record_set" "spf-txt-seriousben" {
  name = google_dns_managed_zone.root.dns_name
  type = "TXT"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["\"v=spf1 include:mxlogin.com -all\""]
}
resource "google_dns_record_set" "dkim-txt-seriousben" {
  name = "x._domainkey.${google_dns_managed_zone.root.dns_name}"
  type = "TXT"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1hG9YzQBKvPAJwafbte2g6c19DSh+ZktT0+/ZzZuMSKGaWCFaV7NOC87yo/2Inm9FyWFn5eUYeT63n1Iwt23uNlc92M49hp2ydfJP3l0DiXAGp6S0v8QQpnEofl+ GRNAjqBcB3Lew44NvOALUgqKtuykH4WRDOkPMYuWsH2aMPD0ptjemX62f9Bim7t/a3sNXLNi/fxkBhJt2KFEa9Yn0kSFS3qVlRhJ2C2xFaHCaMNs0CnsIEgx7KTA3YCcZQqRzVCsi4O9jdE0nRPK3EReZLi7C+AMsQbr5Q8ZcN57ZByPnLoKtU7NzFo+N0I01ZUT0Q4czgtk2ydZ3LtLTwglSwIDAQAB"]
}
resource "google_dns_record_set" "dmarc-txt-seriousben" {
  name = "_dmarc.${google_dns_managed_zone.root.dns_name}"
  type = "TXT"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["\"v=DMARC1; p=none; rua=mailto:support@seriousben.com; ruf=mailto:support@seriousben.com; fo=1;\""]
}
resource "google_dns_record_set" "mx-txt-seriousben" {
  name = google_dns_managed_zone.root.dns_name
  type = "MX"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "10 wednesday.mxrouting.net.",
    "20 wednesday-relay.mxrouting.net.",
  ]
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

resource "google_dns_record_set" "render-badges-seriousben" {
  name = "badges.${google_dns_managed_zone.root.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["seriousben-projects.onrender.com."]
}

resource "google_dns_record_set" "render-dev-idp-seriousben" {
  name = "dev-idp.${google_dns_managed_zone.root.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.root.name

  rrdatas = ["seriousben-projects.onrender.com."]
}

