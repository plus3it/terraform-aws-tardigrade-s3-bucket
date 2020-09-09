variable "bucket" {
  description = "The name of the bucket"
  type        = string
}

variable "acl" {
  description = "The canned ACL the bucket will use"
  type        = string
  default     = "private"
}

variable "force_destroy" {
  description = "boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "grants" {
  description = "A list of ACL policy grants. Conflicts with `acl`, which must be set to `null`"
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = []
}

variable "policy" {
  description = "An IAM policy document in JSON format to apply to the bucket"
  type        = string
  default     = ""
}

variable "public_access_block" {
  description = "A schema object for the S3 bucket public access block policy"
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "server_side_encryption_configuration" {
  description = "A list of schema objects for the server side encryption configuration"
  type        = list
  default     = []
}

variable "tags" {
  description = "The tags applied to the bucket"
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "The state of versioning of the bucket"
  default     = false
}
