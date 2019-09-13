variable "create_bucket" {
  description = "Controls whether to create a bucket"
  default     = true
}

variable "bucket" {
  description = "The name of the bucket"
  type        = string
}

variable "region" {
  description = "Region where the bucket will reside"
  type        = string
}

variable "policy" {
  description = "An IAM policy document in JSON format to apply to the bucket"
  type        = string
  default     = ""
}

variable "versioning" {
  description = "The state of versioning of the bucket"
  default     = false
}

variable "acl" {
  description = "The canned ACL the bucket will use"
  type        = string
  default     = "private"
}

variable "tags" {
  description = "The tags applied to the bucket"
  type        = map(string)
  default     = {}
}

variable "server_side_encryption_configuration" {
  description = "A schema for the server side encryption configuration"
  type        = list
  default     = []
}
