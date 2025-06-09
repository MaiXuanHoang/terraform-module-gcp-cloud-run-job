output "secret" {
  description = "The created secret."
  value       = google_secret_manager_secret.secret
}
