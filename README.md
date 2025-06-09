# GCP module to deploy a Scheduled Cloud Run Job module

Deploy a complete Cloud Run Job on GCP:

* the job itself
* a dedicated Service Account
* (optional) a Cloud Scheduler to trigger the job, with its dedicated Service Account
* (optional) grants access to the configured Artifact Registries
* (optional) grants IAM to linked GCS buckets
* (optional) grants IAM to linked Secret

This repo also contains 2 submodules to help create [GCS buckets](gcs_bucket) and [Secrets](secret) to be used by jobs.

## Usage

### Minimal example

```hcl
module "my_job" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job?ref=v1"

  project = var.project
  region  = var.region

  artifact_registry_repository = {
    project  = "cloudrun"
    location = "us"
    id       = "container"
  }
  grant_artifact_registry_iam = false

  cloud_run_job_service_account_id   = "grp-dev-sbxrbu-sac-job"
  cloud_run_job_service_display_name = "Job Service Account"
  cloud_run_job_name                 = "grp-dev-sbxrbu-run-job"

  cloud_run_job_containers = {
    "test" = {
      image = "us-docker.pkg.dev/cloudrun/container/job:latest"
    },
  }
}
```

### With more settings

```hcl
module "my_job" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job?ref=v1"

  project = var.project
  region  = var.region

  artifact_registry_repository = {
    project  = "cloudrun"
    location = "us"
    id       = "container"
  }
  grant_artifact_registry_iam = false

  job_scheduler = {
    name               = "grp-dev-sbxrbu-sch-job-daily"
    description        = "Scheduler to trigger the tet job daily"
    schedule           = "5 3 * * *"
    time_zone          = "Europe/Paris"
    attempt_deadline   = "180s"
    service_account_id = "grp-dev-sbxrbu-sac-scheduler"
  }

  cloud_run_job_service_account_id   = "grp-dev-sbxrbu-sac-job"
  cloud_run_job_service_display_name = "Job Service Account"
  cloud_run_job_name                 = "grp-dev-sbxrbu-run-job"

  cloud_run_job_additional_labels = {
    "foo" : "bar",
  }
  cloud_run_job_timeout     = "600s"
  cloud_run_job_max_retries = 3

  cloud_run_job_containers = {
    "test-1" = {
      image = "us-docker.pkg.dev/cloudrun/container/job:latest"
      limits = {
        cpu : "1",
        memory : "512Mi",
      }
      environment_variables = {
        "FOO" = "BAR",
      }
    },
    "test-2" = {
      image = "us-docker.pkg.dev/cloudrun/container/job:latest"
    },
  }
}
```

### With a custom image in one of our Artifact Registries

Requirements: allow the Terraform Service Account used to deploy the Cloud Run Job to grant IAM bindings on the Artifact Registry.

When using the group's ARR (`grp-prd-gar-prj-registry`), this can be done [here](https://github.com/lvmh-group-it/grp-gar-registry-on-gcp/blob/main/terraform/production/terraform.tfvars).

Add the Service Account in the `managers` list for the repository in the variable `gar_docker_repositories`:

```hcl
gar_docker_repositories = {
  "my-repo" = {
    ...
    managers = [
      "serviceAccount:my-sac-terraform@my-project.iam.gserviceaccount.com",
    ]
  }
```

Then use:

```hcl
module "my_job" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job?ref=v1"

  project = var.project
  region  = var.region

  artifact_registry_repository = {
    project  = "grp-prd-gar-prj-registry"
    location = "europe-west1"
    id       = "grp-prd-gar-arr-docker-my-repo"
  }
  grant_artifact_registry_iam = true

  cloud_run_job_service_account_id   = "grp-dev-sbxrbu-sac-job"
  cloud_run_job_service_display_name = "Job Service Account"
  cloud_run_job_name                 = "grp-dev-sbxrbu-run-job"

  cloud_run_job_containers = {
    "test" = {
      image = "europe-west1-docker.pkg.dev/grp-prd-gar-prj-registry/grp-prd-gar-arr-docker-my-repo/my-image:latest"
    },
  }
}
```

### With a bucket

Using the provided helper module to create the bucket:

```hcl
module "my_bucket" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job//gcs_bucket?ref=v1"

  project  = var.project
  name     = "grp-dev-sbxrbu-gcs-test-bucket"
  location = "eu"
}

module "my_job" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job?ref=v1"

  project = var.project
  region  = var.region

  artifact_registry_repository = {
    project  = "cloudrun"
    location = "us"
    id       = "container"
  }
  grant_artifact_registry_iam = false


  buckets = {
    "my_volume_name" = {
      name      = module.my_bucket.bucket.name
      read_only = false
    }
  }

  cloud_run_job_service_account_id   = "grp-dev-sbxrbu-sac-job"
  cloud_run_job_service_display_name = "Job Service Account"
  cloud_run_job_name                 = "grp-dev-sbxrbu-run-job"

  cloud_run_job_containers = {
    "test" = {
      image = "us-docker.pkg.dev/cloudrun/container/job:latest"
      volume_mounts = concat(
        [
          {
            volume_name = "my_volume_name",
            mount_path  = "/path/in/container",
          },
        ]
      )
    },
  }
}
```

Here, the whole bucket is mounted in the `test` container at `/path/in/container`.

Note that the bucket is listed in the `buckets` variable in a dict. The dict key is the volume name used in the `volume_mounts` of the container.

See the [gcs_bucket](gcp_bucket/README.md) submodule for more details on its configuration (how to inject a file for example).

### With a secret

Using the provided helper module to create the secret:

```hcl
module "my_secret_env" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job//secret?ref=v1"

  project = var.project
  region  = var.region

  secret_id = "grp-dev-sbxrbu-sec-test-secret-env"
}

module "my_secret_file" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job//secret?ref=v1"

  project = var.project
  region  = var.region

  secret_id = "grp-dev-sbxrbu-sec-test-secret-file"
}

module "my_job" {
  source = "github.com/lvmh-group-it/terraform-module-gcp-cloud-run-job?ref=v1"

  project = var.project
  region  = var.region

  artifact_registry_repository = {
    project  = "cloudrun"
    location = "us"
    id       = "container"
  }
  grant_artifact_registry_iam = false

  secrets = {
    "my_env_secret_ref" = {
      secret_id = module.my_secret_env.secret.secret_id,
      read_only = true,
    }
    "my_volume_secret_ref" = {
      secret_id = module.my_secret_file.secret.secret_id,
      read_only = true,
    }
  }

  cloud_run_job_secret_volumes = {
    "my_volume_name" = {
      secret_ref = "my_volume_secret_ref"
      path       = "file.name"
    }
  }

  cloud_run_job_service_account_id   = "grp-dev-sbxrbu-sac-job"
  cloud_run_job_service_display_name = "Job Service Account"
  cloud_run_job_name                 = "grp-dev-sbxrbu-run-job"

  cloud_run_job_containers = {
    "test" = {
      image = "us-docker.pkg.dev/cloudrun/container/job:latest"

      environment_variable_secrets = {
        "FOO" = {
          secret_ref = "my_env_secret_ref"
        }
      }

      volume_mounts = [
        {
          volume_name = "my_volume_name",
          mount_path  = "/folder/in/container",
        },
      ]
    },
  }
}
```

2 secrets are used here:

* `my_secret_env` is injected in the `test` container as an environment variable
* `my_secret_file` is mounted in the `test` container at `"/folder/in/container/file.name`

Note that the secrets are listed in the `secrets` variable in a dict. The dict key is `secret_ref` used in the `cloud_run_job_secret_volumes` and `environment_variable_secrets` variables.

See the [secret](secret/README.md) submodule for more details on its configuration.

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.25.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.25.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_project_labels"></a> [project\_labels](#module\_project\_labels) | github.com/lvmh-group-it/terraform-module-gcp-project-label-loader | v1 |

### Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository_iam_member.run_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_binary_authorization_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_policy) | resource |
| [google_cloud_run_v2_job.job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_job) | resource |
| [google_cloud_run_v2_job_iam_member.schedule_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_job_iam_member) | resource |
| [google_cloud_scheduler_job.job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_project_service.binaryauthorization](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.cloud_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret_iam_member.run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.schedule_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket_iam_member.run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_artifact_registry_repository.garr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/artifact_registry_repository) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_registry_repository"></a> [artifact\_registry\_repository](#input\_artifact\_registry\_repository) | Artifact Registry repository used to store the Cloud Run Job image. | <pre>object({<br/>    project  = string<br/>    location = string<br/>    id       = string<br/>  })</pre> | n/a | yes |
| <a name="input_binary_authorization_admission_additional_whitelist_name_patterns"></a> [binary\_authorization\_admission\_additional\_whitelist\_name\_patterns](#input\_binary\_authorization\_admission\_additional\_whitelist\_name\_patterns) | Optional list of additional image name patterns to allow. | `list(string)` | `[]` | no |
| <a name="input_binary_authorization_dry_run"></a> [binary\_authorization\_dry\_run](#input\_binary\_authorization\_dry\_run) | Enable dry-run mode for Binary Authorization. Defaults to false. | `bool` | `false` | no |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | Map of buckets used by the Cloud Run job. | <pre>map(object({<br/>    name      = string<br/>    read_only = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_cloud_run_job_additional_labels"></a> [cloud\_run\_job\_additional\_labels](#input\_cloud\_run\_job\_additional\_labels) | Additional labels to set on the Cloud Run job. | `map(string)` | `{}` | no |
| <a name="input_cloud_run_job_containers"></a> [cloud\_run\_job\_containers](#input\_cloud\_run\_job\_containers) | List of containers to run in the Cloud Run Job. | <pre>map(object({<br/>    image   = string<br/>    command = optional(list(string), [])<br/>    args    = optional(list(string), [])<br/>    limits = optional(object({<br/>      cpu    = string<br/>      memory = string<br/>      }), {<br/>      cpu    = "1"<br/>      memory = "512Mi"<br/>    })<br/>    environment_variables = optional(map(string), {})<br/>    environment_variable_secrets = optional(map(object({<br/>      secret_ref     = string<br/>      secret_version = optional(string, "latest")<br/>    })), {})<br/>    volume_mounts = optional(list(object({<br/>      volume_name = string<br/>      mount_path  = string<br/>    })), [])<br/>    depends_on = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_cloud_run_job_empty_dir_volumes"></a> [cloud\_run\_job\_empty\_dir\_volumes](#input\_cloud\_run\_job\_empty\_dir\_volumes) | Dict of empty\_dir volumes to attach to the Cloud Run Job. | <pre>map(object({<br/>    size_limit = string<br/>  }))</pre> | `{}` | no |
| <a name="input_cloud_run_job_in_external_bucket_volumes"></a> [cloud\_run\_job\_in\_external\_bucket\_volumes](#input\_cloud\_run\_job\_in\_external\_bucket\_volumes) | Dict of external GCS Buckets to attach to the Cloud Run Job. | <pre>map(object({<br/>    bucket_name = string<br/>    read_only   = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_cloud_run_job_max_retries"></a> [cloud\_run\_job\_max\_retries](#input\_cloud\_run\_job\_max\_retries) | Number of retries allowed per Task, before marking this Task failed. | `string` | `3` | no |
| <a name="input_cloud_run_job_name"></a> [cloud\_run\_job\_name](#input\_cloud\_run\_job\_name) | Name of the Cloud Run Job. | `string` | n/a | yes |
| <a name="input_cloud_run_job_secret_volumes"></a> [cloud\_run\_job\_secret\_volumes](#input\_cloud\_run\_job\_secret\_volumes) | Map of secret volumes to attach to the Cloud Run job. | <pre>map(object({<br/>    secret_ref     = string<br/>    secret_version = optional(string, "latest")<br/>    default_mode   = optional(number, 0444)<br/>    path           = string<br/>  }))</pre> | `{}` | no |
| <a name="input_cloud_run_job_service_account_id"></a> [cloud\_run\_job\_service\_account\_id](#input\_cloud\_run\_job\_service\_account\_id) | ID of the Cloud Run Job Service Account. | `string` | n/a | yes |
| <a name="input_cloud_run_job_service_display_name"></a> [cloud\_run\_job\_service\_display\_name](#input\_cloud\_run\_job\_service\_display\_name) | Display name of the Cloud Run Job Service Account. | `string` | n/a | yes |
| <a name="input_cloud_run_job_timeout"></a> [cloud\_run\_job\_timeout](#input\_cloud\_run\_job\_timeout) | Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers. This applies per attempt of a task, meaning each retry can run for the full timeout. A duration in seconds with up to nine fractional digits, ending with 's'. Example: "3.5s". | `string` | `"600s"` | no |
| <a name="input_grant_artifact_registry_iam"></a> [grant\_artifact\_registry\_iam](#input\_grant\_artifact\_registry\_iam) | Grant the IAM role to the Cloud Run Service Account to access the Artifact Registry repository | `bool` | `false` | no |
| <a name="input_job_scheduler"></a> [job\_scheduler](#input\_job\_scheduler) | Scheduler configuration to trigger the Cloud Run Job. Leave it empty to disable scheduling. | <pre>object({<br/>    name               = string<br/>    description        = optional(string)<br/>    schedule           = string<br/>    time_zone          = string<br/>    attempt_deadline   = optional(string, "180s")<br/>    service_account_id = string<br/>  })</pre> | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the resources reside. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets used by the Cloud Run job. | <pre>map(object({<br/>    secret_id = string<br/>    read_only = bool<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_job"></a> [job](#output\_job) | Cloud Run Job. |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Service Account used by the Cloud Run Job. |
<!-- END_TF_DOCS -->
