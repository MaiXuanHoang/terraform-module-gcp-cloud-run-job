variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "region" {
  description = "Region where the resources reside."
  type        = string
}

variable "secret_id" {
  description = "ID of the secret to create."
  type        = string
}

variable "create_mock_init_value" {
  description = "Create a first mock value."
  type        = bool
  default     = true
}

variable "additional_labels" {
  description = "Additional labels to set on the secret to create."
  type        = map(string)
  default     = {}
}

variable "accessors" {
  description = "List of members allowed to access the secret's versions."
  type        = list(string)
  default     = []
}

variable "managers" {
  description = "List of members allowed to manage the secret's versions."
  type        = list(string)
  default     = []
}
