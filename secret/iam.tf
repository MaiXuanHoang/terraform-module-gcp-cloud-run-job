locals {
  secret_accessor_roles = ["roles/secretmanager.secretAccessor"]
  secret_manager_roles  = ["roles/secretmanager.secretVersionManager"]

  secret_accessor_iam_bindings = [
    for p in setproduct(var.accessors, local.secret_accessor_roles) : {
      "member" : p[0],
      "role" : p[1],
    }
  ]
  secret_manager_iam_bindings = [
    for p in setproduct(var.managers, local.secret_manager_roles) : {
      "member" : p[0],
      "role" : p[1],
    }
  ]
}

resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each = { for b in local.secret_accessor_iam_bindings : "${b.member}_${b.role}" => b }

  project   = var.project
  secret_id = google_secret_manager_secret.secret.secret_id
  role      = each.value.role
  member    = each.value.member
}

resource "google_secret_manager_secret_iam_member" "managers" {
  for_each = { for b in local.secret_manager_iam_bindings : "${b.member}_${b.role}" => b }

  project   = var.project
  secret_id = google_secret_manager_secret.secret.secret_id
  role      = each.value.role
  member    = each.value.member
}
