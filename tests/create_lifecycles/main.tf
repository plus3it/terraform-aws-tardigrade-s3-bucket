resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_lifecycles" {
  source = "../../"

  bucket = random_id.name.hex

  lifecycle_rules = [
    {
      id     = "transitionRule"
      status = "Enabled"
      prefix = "aPrefix/"

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      filter = {
        prefix = "aPrefix/"
      }

      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]
    },
    {
      id     = "expiredObjDelMarkers"
      status = "Enabled"

      filter = {
        and = [
          {
            prefix = null
            tags = {
              tagFilter  = "testing",
              tagFilter2 = "123"
            }
          },
        ]
      }

      expiration = {
        days = 45
      }

      transitions = [
        {
          days          = 31
          storage_class = "STANDARD_IA"
        },
      ]
    },
    {
      id     = "nonCurrentVersionsTransition"
      status = "Enabled"

      filter = {
        prefix = "anotherPrefix/"
      }

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      expiration = {
        days = 95
      }

      noncurrent_version_expiration = {
        noncurrent_days           = 300
        newer_noncurrent_versions = 10
      }

      noncurrent_version_transitions = [
        {
          noncurrent_days           = 50
          newer_noncurrent_versions = 10
          storage_class             = "GLACIER"
        },
      ]
    }
  ]

  tags = {
    environment = "testing"
  }
}

output "create_lifecycles" {
  value = module.create_lifecycles
}
