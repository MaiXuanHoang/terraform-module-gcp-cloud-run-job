output "bucket" {
  description = "The created GCS bucket."
  value       = google_storage_bucket.bucket
}
