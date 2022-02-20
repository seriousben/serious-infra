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
