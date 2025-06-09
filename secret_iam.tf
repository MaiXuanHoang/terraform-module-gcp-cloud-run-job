resource "google_secret_manager_secret_iam_member" "run" {
  for_each = var.secrets

  project   = var.project
  secret_id = each.value.secret_id
  role      = each.value.read_only ? "roles/secretmanager.secretAccessor" : "roles/secretmanager.secretVersionManager"
  member    = "serviceAccount:${google_service_account.run.email}"
}
