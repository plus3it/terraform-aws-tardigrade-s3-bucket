resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_lifecycles" {
  source = "../../"

  acl = null

  lifecycle_rules = [
    {
      id     = "transitionRule"
      status = "Enabled"
      prefix = "aPrefix/"

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      filter = {
        prefix                   = "aPrefix/"
        tag                      = null
        and                      = null
        object_size_greater_than = null
        object_size_less_than    = null
      }

      expiration = null

      transitions = [{
        date          = null
        days          = 30
        storage_class = "STANDARD_IA"
        },
        {
          date          = null
          days          = 90
          storage_class = "GLACIER"
      }]

      noncurrent_version_expiration = null

      noncurrent_version_transitions = []
    },
    {
      id     = "expiredObjDelMarkers"
      status = "Enabled"

      filter = {
        prefix = null
        tag    = null
        and = [{
          prefix = null
          tags = {
            tagFilter  = "testing",
            tagFilter2 = "123"
          }
          object_size_greater_than = null
          object_size_less_than    = null
        }]
        object_size_greater_than = null
        object_size_less_than    = null
      }

      abort_incomplete_multipart_upload = null

      expiration = {
        date                         = null
        days                         = 45
        expired_object_delete_marker = true
      }

      transitions = [{
        date          = null
        days          = 31
        storage_class = "STANDARD_IA"
      }]

      noncurrent_version_expiration = null

      noncurrent_version_transitions = []
    },
    {
      id     = "nonCurrentVersionsTransition"
      status = "Enabled"

      filter = {
        prefix                   = "anotherPrefix/"
        tag                      = null
        and                      = null
        object_size_greater_than = null
        object_size_less_than    = null
      }

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      expiration = {
        date                         = null
        days                         = 95
        expired_object_delete_marker = null
      }

      transitions = []

      noncurrent_version_expiration = {
        noncurrent_days           = 300
        newer_noncurrent_versions = 10
      }

      noncurrent_version_transitions = [{
        noncurrent_days           = 50
        newer_noncurrent_versions = 10
        storage_class             = "GLACIER"
      }]
  }]


  bucket = random_id.name.hex
  tags = {
    environment = "testing"
  }
}

output "create_bucket" {
  value = module.create_lifecycles
}
