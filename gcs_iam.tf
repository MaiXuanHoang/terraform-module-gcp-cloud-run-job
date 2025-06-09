resource "google_storage_bucket_iam_member" "run" {
  for_each = var.buckets

  bucket = each.value.name
  role   = each.value.read_only ? "roles/storage.objectViewer" : "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.run.email}"
}
