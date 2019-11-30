#####
# serious-infra
#####

resource "google_service_account" "terraform-viewer" {
  account_id   = "terraform-viewer"
  display_name = "https://github.com/seriousben/serious-infra CI"
}

resource "google_project_iam_member" "terraform-all-viewer" {
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.terraform-viewer.email}"
}

#####
# seriousben.com
#####

resource "google_service_account" "seriousben-com-deployer" {
  account_id   = "seriousben-com-deployer"
  display_name = "https://github.com/seriousben/seriousben.com CD"
}

resource "google_project_iam_member" "seriousben-com-deployer" {
  role   = "roles/container.viewer"
  member = "serviceAccount:${google_service_account.seriousben-com-deployer.email}"
}

#####
# Newsblur to hugo
#####

resource "google_service_account" "newsblur-to-hugo-deployer" {
  account_id   = "newsblur-to-hugo-deployer"
  display_name = "https://github.com/seriousben/newsblur-to-hugo CD"
}

resource "google_project_iam_member" "newsblur-to-hugo-deployer" {
  role   = "roles/container.viewer"
  member = "serviceAccount:${google_service_account.newsblur-to-hugo-deployer.email}"
}

#####
# Serious Watcher
#####

resource "google_service_account" "serious-watcher-deployer" {
  account_id   = "serious-watcher-deployer"
  display_name = "https://github.com/seriousben/serious-watcher CD"
}

resource "google_project_iam_member" "serious-watcher-deployer" {
  role   = "roles/container.viewer"
  member = "serviceAccount:${google_service_account.serious-watcher-deployer.email}"
}

resource "google_service_account" "serious-watcher-backend" {
  account_id   = "serious-watcher-backend"
  display_name = "https://github.com/seriousben/serious-watcher backend"
}

resource "google_project_iam_member" "serious-watcher-backend" {
  role   = "roles/datastore.user"
  member = "serviceAccount:${google_service_account.serious-watcher-backend.email}"
}

