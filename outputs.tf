output "service_account" {
  description = "Service Account used by the Cloud Run Job."
  value       = google_service_account.run
}

output "job" {
  description = "Cloud Run Job."
  value       = google_cloud_run_v2_job.job
}
