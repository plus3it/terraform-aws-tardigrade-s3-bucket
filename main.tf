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

  dynamic "grant" {

    for_each = var.grants

    content {
      id          = grant.value.id
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = grant.value.uri
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

resource "aws_s3_bucket_notification" "this" {
  count = length(var.notifications.lambda_functions) > 0 || length(var.notifications.topics) > 0 || length(var.notifications.queues) > 0 ? 1 : 0

  bucket = aws_s3_bucket_public_access_block.this.id

  dynamic lambda_function {
    for_each = var.notifications.lambda_functions
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic topic {
    for_each = var.notifications.topics
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic queue {
    for_each = var.notifications.queues
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }
}
