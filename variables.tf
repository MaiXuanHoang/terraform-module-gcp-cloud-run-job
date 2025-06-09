variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "region" {
  description = "Region where the resources reside."
  type        = string
}

##################################################
#                  GCS Buckets                   #
##################################################
variable "buckets" {
  description = "Map of buckets used by the Cloud Run job."
  type = map(object({
    name      = string
    read_only = bool
  }))
  default = {}
}

##################################################
#                 Secret Manager                 #
##################################################
variable "secrets" {
  description = "Map of secrets used by the Cloud Run job."
  type = map(object({
    secret_id = string
    read_only = bool
  }))
  default = {}
}

variable "cloud_run_job_secret_volumes" {
  description = "Map of secret volumes to attach to the Cloud Run job."
  type = map(object({
    secret_ref     = string
    secret_version = optional(string, "latest")
    default_mode   = optional(number, 0444)
    path           = string
  }))
  default = {}
}

##################################################
#               Artifact Registry                #
##################################################
variable "artifact_registry_repository" {
  description = "Artifact Registry repository used to store the Cloud Run Job image."
  type = object({
    project  = string
    location = string
    id       = string
  })
}

variable "grant_artifact_registry_iam" {
  description = "Grant the IAM role to the Cloud Run Service Account to access the Artifact Registry repository"
  type        = bool
  default     = false
}

##################################################
#              Binary Authorization              #
##################################################
variable "binary_authorization_dry_run" {
  description = "Enable dry-run mode for Binary Authorization. Defaults to false."
  type        = bool
  default     = false
}

variable "binary_authorization_admission_additional_whitelist_name_patterns" {
  description = "Optional list of additional image name patterns to allow."
  type        = list(string)
  default     = []
}

##################################################
#                Service Account                 #
##################################################
variable "cloud_run_job_service_account_id" {
  description = "ID of the Cloud Run Job Service Account."
  type        = string
}

variable "cloud_run_job_service_display_name" {
  description = "Display name of the Cloud Run Job Service Account."
  type        = string
}

##################################################
#                   Scheduler                    #
##################################################
variable "job_scheduler" {
  description = "Scheduler configuration to trigger the Cloud Run Job. Leave it empty to disable scheduling."
  type = object({
    name               = string
    description        = optional(string)
    schedule           = string
    time_zone          = string
    attempt_deadline   = optional(string, "180s")
    service_account_id = string
  })
  default = null
}

##################################################
#                 Cloud Run Job                  #
##################################################
variable "cloud_run_job_name" {
  description = "Name of the Cloud Run Job."
  type        = string
}

variable "cloud_run_job_additional_labels" {
  description = "Additional labels to set on the Cloud Run job."
  type        = map(string)
  default     = {}
}

variable "cloud_run_job_timeout" {
  description = "Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers. This applies per attempt of a task, meaning each retry can run for the full timeout. A duration in seconds with up to nine fractional digits, ending with 's'. Example: \"3.5s\"."
  type        = string
  default     = "600s"
}

variable "cloud_run_job_max_retries" {
  description = "Number of retries allowed per Task, before marking this Task failed."
  type        = string
  default     = 3
}

variable "cloud_run_job_empty_dir_volumes" {
  description = "Dict of empty_dir volumes to attach to the Cloud Run Job."
  type = map(object({
    size_limit = string
  }))
  default = {}
}

variable "cloud_run_job_in_external_bucket_volumes" {
  description = "Dict of external GCS Buckets to attach to the Cloud Run Job."
  type = map(object({
    bucket_name = string
    read_only   = bool
  }))
  default = {}
}

variable "cloud_run_job_containers" {
  description = "List of containers to run in the Cloud Run Job."
  type = map(object({
    image   = string
    command = optional(list(string), [])
    args    = optional(list(string), [])
    limits = optional(object({
      cpu    = string
      memory = string
      }), {
      cpu    = "1"
      memory = "512Mi"
    })
    environment_variables = optional(map(string), {})
    environment_variable_secrets = optional(map(object({
      secret_ref     = string
      secret_version = optional(string, "latest")
    })), {})
    volume_mounts = optional(list(object({
      volume_name = string
      mount_path  = string
    })), [])
    depends_on = optional(list(string), [])
  }))
}
