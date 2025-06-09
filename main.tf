data "google_project" "project" {}

module "project_labels" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-project-label-loader?ref=v1"
}
