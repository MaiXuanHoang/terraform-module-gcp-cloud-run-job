resource "google_project_service" "binaryauthorization" {
  service            = "binaryauthorization.googleapis.com"
  project            = var.project
  disable_on_destroy = false
}

resource "google_binary_authorization_policy" "default" {
  # Deny all images by default
  default_admission_rule {
    evaluation_mode  = "ALWAYS_DENY"
    enforcement_mode = var.binary_authorization_dry_run ? "DRYRUN_AUDIT_LOG_ONLY" : "ENFORCED_BLOCK_AND_AUDIT_LOG"
  }

  # Enable Google-maintained global admission policy for common system-level images
  global_policy_evaluation_mode = "ENABLE"

  # Whitelist our Google Artifact Registry images
  admission_whitelist_patterns {
    name_pattern = "${var.artifact_registry_repository.location}-docker.pkg.dev/${var.artifact_registry_repository.project}/${var.artifact_registry_repository.id}/*"
  }

  # Whitelist additional images
  dynamic "admission_whitelist_patterns" {
    for_each = toset(var.binary_authorization_admission_additional_whitelist_name_patterns)
    content {
      name_pattern = each.value
    }
  }

  depends_on = [
    google_project_service.binaryauthorization,
  ]
}
