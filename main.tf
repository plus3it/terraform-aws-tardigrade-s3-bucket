resource "aws_s3_bucket" "this" {

  bucket        = var.bucket
  policy        = var.policy
  acl           = var.acl
  tags          = var.tags
  force_destroy = var.force_destroy

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

resource "aws_s3_bucket_public_access_block" "this" {

  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}
