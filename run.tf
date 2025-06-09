resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  project            = var.project
  disable_on_destroy = false
}

resource "google_cloud_run_v2_job" "job" {
  name                = var.cloud_run_job_name
  location            = var.region
  deletion_protection = false

  labels = merge(
    module.project_labels.inheritable_labels,
    var.cloud_run_job_additional_labels,
  )

  template {
    template {
      service_account = google_service_account.run.email
      timeout         = var.cloud_run_job_timeout
      max_retries     = var.cloud_run_job_max_retries

      dynamic "containers" {
        for_each = var.cloud_run_job_containers
        content {
          name    = containers.key
          image   = containers.value.image
          command = containers.value.command
          args    = containers.value.args
          #depends_on = containers.value.depends_on
          resources {
            limits = containers.value.limits
          }

          dynamic "env" {
            for_each = containers.value.environment_variables
            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = containers.value.environment_variable_secrets
            content {
              name = env.key
              value_source {
                secret_key_ref {
                  secret  = var.secrets[env.value.secret_ref].secret_id
                  version = env.value.secret_version
                }
              }
            }
          }

          dynamic "volume_mounts" {
            for_each = containers.value.volume_mounts
            content {
              name       = volume_mounts.value.volume_name
              mount_path = volume_mounts.value.mount_path
            }
          }
        }
      }

      dynamic "volumes" {
        for_each = var.buckets
        content {
          name = volumes.key
          gcs {
            bucket    = volumes.value.name
            read_only = volumes.value.read_only
          }
        }
      }
      dynamic "volumes" {
        for_each = var.cloud_run_job_secret_volumes
        content {
          name = volumes.key
          secret {
            secret       = var.secrets[volumes.value.secret_ref].secret_id
            default_mode = volumes.value.default_mode
            items {
              version = volumes.value.secret_version
              path    = volumes.value.path
            }
          }
        }
      }
      dynamic "volumes" {
        for_each = var.cloud_run_job_empty_dir_volumes
        content {
          name = volumes.key
          empty_dir {
            size_limit = volumes.value.size_limit
          }
        }
      }
      dynamic "volumes" {
        for_each = var.cloud_run_job_in_external_bucket_volumes
        content {
          name = volumes.key
          gcs {
            bucket    = volumes.value.bucket_name
            read_only = volumes.value.read_only
          }
        }
      }
    }
  }

  binary_authorization {
    use_default = true
  }

  depends_on = [
    google_project_service.run,
    # Wait for the Secret Manager IAM binding to be applied to avoid an error when using a secret as env var or volume
    google_secret_manager_secret_iam_member.run,
  ]
}
