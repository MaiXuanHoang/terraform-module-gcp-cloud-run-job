locals {
  bucket_reader_roles  = ["roles/storage.objectViewer"]
  bucket_manager_roles = ["roles/storage.objectAdmin"]

  bucket_reader_iam_bindings = [
    for p in setproduct(var.readers, local.bucket_reader_roles) : {
      "member" : p[0],
      "role" : p[1],
    }
  ]

  bucket_manager_iam_bindings = [
    for p in setproduct(var.managers, local.bucket_manager_roles) : {
      "member" : p[0],
      "role" : p[1],
    }
  ]
}

resource "google_storage_bucket_iam_member" "readers" {
  for_each = { for b in local.bucket_reader_iam_bindings : "${b.member}_${b.role}" => b }

  bucket = google_storage_bucket.bucket.name
  role   = each.value.role
  member = each.value.member
}

resource "google_storage_bucket_iam_member" "managers" {
  for_each = { for b in local.bucket_manager_iam_bindings : "${b.member}_${b.role}" => b }

  bucket = google_storage_bucket.bucket.name
  role   = each.value.role
  member = each.value.member
}
