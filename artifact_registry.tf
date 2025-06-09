data "google_artifact_registry_repository" "garr" {
  project       = var.artifact_registry_repository.project
  location      = var.artifact_registry_repository.location
  repository_id = var.artifact_registry_repository.id
}

resource "google_artifact_registry_repository_iam_member" "run_reader" {
  count = var.grant_artifact_registry_iam ? 1 : 0

  project    = data.google_artifact_registry_repository.garr.project
  location   = data.google_artifact_registry_repository.garr.location
  repository = data.google_artifact_registry_repository.garr.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
