module "project_labels" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-project-label-loader?ref=v1"
}

resource "google_storage_bucket" "bucket" {
  name          = var.name
  location      = var.location
  force_destroy = true

  labels = merge(
    module.project_labels.inheritable_labels,
    var.additional_labels,
  )

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "bucket_objects" {
  for_each = { for file in var.files : "${file.path}" => file }
  bucket   = google_storage_bucket.bucket.name
  name     = each.value.path
  content  = each.value.content
}
