module "project_labels" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-project-label-loader?ref=v1"
}

resource "google_project_service" "secret_manager" {
  service            = "secretmanager.googleapis.com"
  project            = var.project
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "secret" {
  project   = var.project
  secret_id = var.secret_id

  labels = merge(
    module.project_labels.inheritable_labels,
    var.additional_labels,
  )

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.secret_manager
  ]
}

resource "google_secret_manager_secret_version" "init" {
  count = var.create_mock_init_value ? 1 : 0

  secret                 = google_secret_manager_secret.secret.id
  secret_data_wo_version = 1
  secret_data_wo         = "mock"
}
