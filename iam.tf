
resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.gke_service_account]

  for_each = toset([
    "roles/iam.serviceAccountTokenCreator",
    "roles/clouddeploy.jobRunner",
    "roles/container.developer",
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}
