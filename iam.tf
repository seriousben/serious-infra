resource "google_service_account" "terraform-viewer" {
  account_id   = "terraform-viewer"
  display_name = "https://github.com/seriousben/serious-infra CI"
}

resource "google_project_iam_member" "terraform-all-viewer" {
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.terraform-viewer.email}"
}

resource "google_service_account" "seriousben-com-deployer" {
  account_id   = "serousben-com-deployer"
  display_name = "https://github.com/seriousben/seriousben.com CD"
}

resource "google_project_iam_member" "serousben-com-deployer" {
  role   = "roles/container.developer"
  member = "serviceAccount:${google_service_account.seriousben-com-deployer.email}"
}

resource "google_service_account" "newsblur-to-hugo-deployer" {
  account_id   = "serousben-com-deployer"
  display_name = "https://github.com/seriousben/newsblur-to-hugo CD"
}

resource "google_project_iam_member" "newsblur-to-hugo-deployer" {
  role   = "roles/container.developer"
  member = "serviceAccount:${google_service_account.newsblur-to-hugo-deployer.email}"
}

