provider "aws" {
  region  = "us-east-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_lifecycles" {
  source = "../../"
  providers = {
    aws = aws
  }

  acl = null

  lifecycle_rules = [{
    id                                     = "transitionRule"
    enabled                                = "true"
    prefix                                 = "aPrefix/"
    tags                                   = null
    abort_incomplete_multipart_upload_days = 7

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
      id                                     = "expiredObjDelMarkers"
      enabled                                = "true"
      prefix                                 = null
      tags                                   = { tagFilter = "testing", tagFilter2 = "123" }
      abort_incomplete_multipart_upload_days = null

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
      id                                     = "nonCurrentVersionsTransition"
      enabled                                = "true"
      prefix                                 = "anotherPrefix/"
      tags                                   = null
      abort_incomplete_multipart_upload_days = 7

      expiration = {
        date                         = null
        days                         = 95
        expired_object_delete_marker = null
      }

      transitions = []

      noncurrent_version_expiration = {
        days = 300
      }

      noncurrent_version_transitions = [{
        days          = 50
        storage_class = "GLACIER"
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
