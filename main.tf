provider "aws" {
}

resource "aws_s3_bucket" "this" {
  count = var.create_bucket ? 1 : 0

  bucket = var.bucket
  region = var.region
  policy = var.policy
  acl    = var.acl
  tags   = var.tags

  versioning {
    enabled = var.versioning
  }

  dynamic "server_side_encryption_configuration" {
    iterator = sse_config
    for_each = var.server_side_encryption_configuration
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = lookup(sse_config.value, "sse_algorithm", null)
          kms_master_key_id = lookup(sse_config.value, "kms_master_key_id", null)
        }
      }
    }
  }
}

