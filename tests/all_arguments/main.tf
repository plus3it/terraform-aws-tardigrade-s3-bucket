provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

module "all_arguments" {
  source = "../../"

  bucket        = random_id.name.hex
  acl           = null
  force_destroy = true
  versioning    = "Enabled"

  # tags
  tags = {
    environment = "testing"
  }

  # cors_configuration
  cors_configuration = {
    expected_bucket_owner = null
    cors_rules = [
      {
        allowed_headers = ["*"]
        allowed_methods = ["PUT", "POST"]
        allowed_origins = ["https://s3-website-test.hashicorp.com"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
        id              = null
      },
      {
        allowed_headers = null
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        expose_headers  = null
        max_age_seconds = null
        id              = null
      }
    ]
  }

  # grants
  grants = [
    {
      id         = data.aws_canonical_user_id.current.id
      type       = "CanonicalUser"
      permission = "READ"
      uri        = null
    },
    {
      id         = null
      type       = "Group"
      permission = "READ"
      uri        = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    {
      id         = null
      type       = "Group"
      permission = "WRITE"
      uri        = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
  ]

  # intelligent_tiering_configuration
  intelligent_tiering_configuration = {
    name   = "ImportantBlueDocuments"
    status = "Enabled"

    filter = {
      prefix = "documents/"

      tags = {
        priority = "high"
        class    = "blue"
      }
    }

    tiering = [
      {
        access_tier = "DEEP_ARCHIVE_ACCESS"
        days        = 180
      },
      {
        access_tier = "ARCHIVE_ACCESS"
        days        = 125
      }
    ]
  }

  # Moto/localstack currently do not support inventory actions, so we comment out
  # the argument. It is still valuable to run the test in CI against localstack,
  # to confirm combinations of arguments continue to work.
  #
  #  # inventory
  #   inventory = {
  #     name                     = "EntireBucketDaily"
  #     included_object_versions = "All"
  #     enabled                  = true

  #     filter = null

  #     schedule = {
  #       frequency = "Daily"
  #     }

  #     destination = {
  #       bucket = {
  #         format     = "ORC"
  #         bucket_arn = aws_s3_bucket.inventory.arn
  #         account_id = null
  #         prefix     = null
  #       }
  #     }
  #   }

  # lifecycle_rules
  lifecycle_rules = [
    {
      id         = "transitionRule"
      expiration = null
      status     = "Enabled"
      prefix     = "aPrefix/"

      noncurrent_version_expiration  = null
      noncurrent_version_transitions = []

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
    },
  ]

  # logging
  logging = {
    expected_bucket_owner = null
    target_bucket         = aws_s3_bucket_acl.logging.bucket
    target_prefix         = "log/"
    target_grants         = null
  }

  # notifications
  notifications = {
    lambda_functions = []
    topics = [
      {
        topic_arn     = aws_sns_topic_policy.notifications.arn
        events        = ["s3:ObjectRemoved:*"]
        filter_prefix = null
        filter_suffix = null
      }
    ]
    queues = []
  }

  # ownership_controls
  ownership_controls = {
    rule = {
      object_ownership = "BucketOwnerPreferred"
    }
  }

  # policy
  policy = {
    json = templatefile("${path.module}/templates/basic_bucket_policy.json", {
      bucket    = random_id.name.hex
      partition = data.aws_partition.current.partition
    })
  }

  # public_access_block
  public_access_block = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }

  # replication_configuration
  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id                               = "foobar"
        delete_marker_replication_status = "Disabled"
        priority                         = null
        status                           = "Enabled"
        source_selection_criteria        = null

        destination = {
          bucket                     = "arn:aws:s3:::${aws_s3_bucket_versioning.replication.id}"
          storage_class              = "STANDARD"
          access_control_translation = null
          account                    = null
          encryption_configuration   = null
          metrics                    = null
          replication_time           = null
        }

        filter = {
          prefix = "foo"
          tag = {
            key   = "Name"
            value = "Foo"
          }
          and = null
        }
      }
    ]
  }

  # request_payment_configuration
  request_payment_configuration = {
    expected_bucket_owner = null
    payer                 = "BucketOwner"
  }

  # server_side_encryption_configuration
  server_side_encryption_configuration = {
    bucket_key_enabled = true
    sse_algorithm      = "aws:kms"
    kms_master_key_id  = aws_kms_key.encryption.arn
  }
}

resource "aws_s3_bucket" "inventory" {
  bucket = format("%s-%s", "inventory", random_id.name.hex)
}

resource "aws_s3_bucket" "logging" {
  bucket = format("%s-%s", "logging", random_id.name.hex)
}

resource "aws_s3_bucket_acl" "logging" {
  bucket = aws_s3_bucket.logging.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "replication" {
  provider = aws.west

  bucket = format("%s-%s", "replication", random_id.name.hex)
}

resource "aws_s3_bucket_versioning" "replication" {
  provider = aws.west

  bucket = aws_s3_bucket.replication.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  name = "tf-iam-role-replication-12345"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "s3.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )

  inline_policy {
    name = "tf-iam-role-policy-replication"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Action" : [
              "s3:GetReplicationConfiguration",
              "s3:ListBucket"
            ],
            "Effect" : "Allow",
            "Resource" : [
              "arn:aws:s3:::${random_id.name.hex}"
            ]
          },
          {
            "Action" : [
              "s3:GetObjectVersionForReplication",
              "s3:GetObjectVersionAcl",
              "s3:GetObjectVersionTagging"
            ],
            "Effect" : "Allow",
            "Resource" : [
              "arn:aws:s3:::${random_id.name.hex}/*"
            ]
          },
          {
            "Action" : [
              "s3:ReplicateObject",
              "s3:ReplicateDelete",
              "s3:ReplicateTags"
            ],
            "Effect" : "Allow",
            "Resource" : "${aws_s3_bucket.replication.arn}/*"
          }
        ]
      }
    )
  }
}

resource "aws_sns_topic" "notifications" {}

resource "aws_sns_topic_policy" "notifications" {
  arn = aws_sns_topic.notifications.arn
  policy = templatefile("templates/sns_policy.json", {
    account_id  = data.aws_caller_identity.current.account_id
    bucket_name = random_id.name.hex
    partition   = data.aws_partition.current.partition
    topic_arn   = aws_sns_topic.notifications.arn
  })
}

resource "aws_kms_key" "encryption" {
  description = random_id.name.hex
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

output "all_arguments" {
  value = module.all_arguments
}
