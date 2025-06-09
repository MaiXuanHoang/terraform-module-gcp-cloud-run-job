# GCP module to deploy a GCS Bucket

Deploys a bucket in Cloud Storage with:

* (optional) files
* (optional) a list of accessors
* (optional) a list of managers

The accessors are allowed to access the bucket.

The managers are allowed to read/write/delete files to the bucket.

## Usage

### Empty bucket

```hcl
module "bucket" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job//gcs_bucket?ref=v1"

  project  = var.project
  name     = "grp-dev-sbxrbu-gcs-test-bucket"
  location = "eu"
  accessors = [
    "serviceAccount:...",
  ]
  
  managers = [
    "group:somegroup@lvmh.com",
  ]
}
```

### With files

```hcl
module "bucket" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job//gcs_bucket?ref=v1"

  project  = var.project
  name     = "grp-dev-sbxrbu-gcs-test-bucket"
  location = "eu"

  files = [
    {
      path    = "path/to/file_1.txt"
      content = "Static content"
    },
    {
      path = "path/to/file_2.txt"
      content = templatefile("templates/file.txt.tpl", {
        "source" : "template",
      })
    },
  ]
}
```

With a template file `templates/file.txt.tpl`:

```txt
Content from: ${ source }

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
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.managers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.readers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.bucket_objects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_labels"></a> [additional\_labels](#input\_additional\_labels) | Additional labels to set on the bucket to create. | `map(string)` | `{}` | no |
| <a name="input_files"></a> [files](#input\_files) | List of files to upload to the bucket. | <pre>list(object({<br/>    path : string<br/>    content : string<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the bucket to create. | `string` | n/a | yes |
| <a name="input_managers"></a> [managers](#input\_managers) | List of members allowed to manage objects the bucket. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the bucket to create. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_readers"></a> [readers](#input\_readers) | List of members allowed to read objects in the bucket. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The created GCS bucket. |
<!-- END_TF_DOCS -->