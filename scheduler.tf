resource "google_project_service" "cloud_scheduler" {
  count = var.job_scheduler != null ? 1 : 0

  service            = "cloudscheduler.googleapis.com"
  project            = var.project
  disable_on_destroy = false
}

resource "google_service_account" "schedule_invoker" {
  count = var.job_scheduler != null ? 1 : 0

  project      = var.project
  account_id   = var.job_scheduler.service_account_id
  display_name = "Service account used by Cloud Scheduler to trigger ${var.cloud_run_job_name}"
}

resource "google_cloud_run_v2_job_iam_member" "schedule_invoker" {
  count = var.job_scheduler != null ? 1 : 0

  project = var.project
  name    = google_cloud_run_v2_job.job.name
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.schedule_invoker[0].email}"
}

resource "google_cloud_scheduler_job" "job" {
  count = var.job_scheduler != null ? 1 : 0

  name             = var.job_scheduler.name
  project          = var.project
  description      = var.job_scheduler.description
  schedule         = var.job_scheduler.schedule
  time_zone        = var.job_scheduler.time_zone
  attempt_deadline = var.job_scheduler.attempt_deadline

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.job.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.project.number}/jobs/${google_cloud_run_v2_job.job.name}:run"

    oauth_token {
      service_account_email = google_service_account.schedule_invoker[0].email
    }
  }

  depends_on = [
    google_project_service.cloud_scheduler,
  ]
}
