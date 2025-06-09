# GCP module to deploy a Secret

Deploys a Secret in Secret Manager with:

* (optional) a default mock value
* (optional) a list of accessors
* (optional) a list of managers

This module supports using a default mock value.
This allows the immediate use of the secret in terraform using the `latest` value without failure.
It is expected that the real value will be manually added (on the GCP console or using gcloud).

The accessors are allowed to access secret values.

The managers are allowed to add secret values.

## Usage

```hcl
module "secret" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job//secret?ref=v1"

  project = var.project
  region  = var.region

  secret_id = "grp-dev-sbxrbu-sec-test-secret-env"

  accessors = [
    "serviceAccount:...",
  ]
  
  managers = [
    "group:somegroup@lvmh.com",
  ]
}
```

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

No requirements.

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_project_labels"></a> [project\_labels](#module\_project\_labels) | github.com/lvmh-group-it/terraform-module-gcp-project-label-loader | v1 |

### Resources

| Name | Type |
|------|------|
| [google_project_service.secret_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.accessors](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.managers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.init](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accessors"></a> [accessors](#input\_accessors) | List of members allowed to access the secret's versions. | `list(string)` | `[]` | no |
| <a name="input_additional_labels"></a> [additional\_labels](#input\_additional\_labels) | Additional labels to set on the secret to create. | `map(string)` | `{}` | no |
| <a name="input_create_mock_init_value"></a> [create\_mock\_init\_value](#input\_create\_mock\_init\_value) | Create a first mock value. | `bool` | `true` | no |
| <a name="input_managers"></a> [managers](#input\_managers) | List of members allowed to manage the secret's versions. | `list(string)` | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the resources reside. | `string` | n/a | yes |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | ID of the secret to create. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret"></a> [secret](#output\_secret) | The created secret. |
<!-- END_TF_DOCS -->