variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "name" {
  description = "Name of the bucket to create."
  type        = string
}

variable "location" {
  description = "Location of the bucket to create."
  type        = string
}

variable "additional_labels" {
  description = "Additional labels to set on the bucket to create."
  type        = map(string)
  default     = {}
}

variable "files" {
  description = "List of files to upload to the bucket."
  type = list(object({
    path : string
    content : string
  }))
  default = []
}

variable "readers" {
  description = "List of members allowed to read objects in the bucket."
  type        = list(string)
  default     = []
}

variable "managers" {
  description = "List of members allowed to manage objects the bucket."
  type        = list(string)
  default     = []
}
