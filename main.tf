resource "aws_s3_bucket" "this" {
  bucket        = var.bucket
  tags          = var.tags
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.logging == null ? 0 : 1
  bucket = aws_s3_bucket.this.id

  target_bucket         = var.logging.target_bucket
  target_prefix         = var.logging.target_prefix
  expected_bucket_owner = var.logging.expected_bucket_owner

  dynamic "target_grant" {
    iterator = target_grant
    for_each = var.logging.target_grants != null ? var.logging.target_grants : []

    content {
      grantee {
        email_address = target_grant.grantee.value.email_address
        id            = target_grant.grantee.value.id
        type          = target_grant.grantee.value.type
        uri           = target_grant.grantee.value.uri
      }
      permission = target_grant.value.permission
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = var.ownership_controls == null ? 0 : 1
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    iterator = rule
    for_each = var.ownership_controls.rule != null ? [var.ownership_controls.rule] : []

    content {
      object_ownership = rule.value.object_ownership
    }
  }
}

resource "aws_s3_bucket_request_payment_configuration" "this" {
  count                 = var.request_payment_configuration == null ? 0 : 1
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.request_payment_configuration.expected_bucket_owner
  payer                 = var.request_payment_configuration.payer
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count                 = var.cors_configuration == null ? 0 : 1
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.cors_configuration.expected_bucket_owner

  dynamic "cors_rule" {
    for_each = var.cors_configuration.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      id              = cors_rule.value.id
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  count  = var.intelligent_tiering_configuration == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
  name   = var.intelligent_tiering_configuration.name
  status = var.intelligent_tiering_configuration.status

  dynamic "tiering" {
    for_each = var.intelligent_tiering_configuration.tiering != null ? var.intelligent_tiering_configuration.tiering : []
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }

  dynamic "filter" {
    for_each = var.intelligent_tiering_configuration.filter != null ? [var.intelligent_tiering_configuration.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.replication_configuration == null ? 0 : 1

  bucket = aws_s3_bucket.this.id
  role   = var.replication_configuration.role

  dynamic "rule" {
    for_each = var.replication_configuration.rules
    content {
      id       = rule.value.id
      priority = rule.value.priority
      status   = rule.value.status

      dynamic "delete_marker_replication" {
        for_each = rule.value.delete_marker_replication_status != null ? [rule.value.delete_marker_replication_status] : []
        content {
          status = delete_marker_replication.value
        }
      }

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class
        account       = rule.value.destination.account

        dynamic "encryption_configuration" {
          for_each = rule.value.destination.encryption_configuration != null ? [rule.value.destination.encryption_configuration] : []
          content {
            replica_kms_key_id = encryption_configuration.value.replica_kms_key_id
          }
        }

        dynamic "access_control_translation" {
          for_each = rule.value.destination.access_control_translation != null ? [rule.value.destination.access_control_translation] : []
          content {
            owner = access_control_translation.value.owner
          }
        }

        dynamic "metrics" {
          for_each = rule.value.destination.metrics != null ? [rule.value.destination.metrics] : []
          content {
            status = metrics.value.status
            dynamic "event_threshold" {
              for_each = metrics.value.event_threshold != null ? [metrics.value.event_threshold] : []
              content {
                minutes = event_threshold.value.minutes
              }
            }
          }
        }

        dynamic "replication_time" {
          for_each = rule.value.destination.replication_time != null ? [rule.value.destination.replication_time] : []
          content {
            status = replication_time.value.status
            dynamic "time" {
              for_each = replication_time.value.time != null ? [replication_time.value.time] : []
              content {
                minutes = time.value.minutes
              }
            }
          }
        }
      }

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix
          dynamic "tag" {
            for_each = filter.value.tags != null ? [filter.value.tags] : []
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
          dynamic "and" {
            for_each = filter.value.and != null ? filter.value.and : []
            content {
              prefix = and.value.prefix
              tags   = and.value.tags
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.source_selection_criteria != null ? [rule.value.source_selection_criteria] : []
        content {
          dynamic "replica_modifications" {
            for_each = source_selection_criteria.value.replica_modifications != null ? [source_selection_criteria.value.replica_modifications] : []
            content {
              status = replica_modifications.value.status
            }
          }

          dynamic "sse_kms_encrypted_objects" {
            for_each = source_selection_criteria.value.sse_kms_encrypted_objects != null ? [source_selection_criteria.value.sse_kms_encrypted_objects] : []
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_inventory" "this" {
  count                    = var.bucket_inventory == null ? 0 : 1
  bucket                   = aws_s3_bucket.this.id
  name                     = var.bucket_inventory.name
  included_object_versions = var.bucket_inventory.included_object_versions
  enabled                  = var.bucket_inventory.enabled

  schedule {
    frequency = var.bucket_inventory.schedule.frequency
  }

  destination {
    bucket {
      bucket_arn = var.bucket_inventory.destination.bucket.bucket_arn
      format     = var.bucket_inventory.destination.bucket.format
      account_id = var.bucket_inventory.destination.bucket.account_id
      prefix     = var.bucket_inventory.destination.bucket.prefix
    }
  }

  dynamic "filter" {
    for_each = var.bucket_inventory.filter != null ? [var.bucket_inventory.filter] : []
    content {
      prefix = filter.value.prefix
    }
  }
}

resource "aws_s3_bucket_acl" "with_acl" {
  count  = var.acl == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
  acl    = var.acl
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_acl" "with_grants" {
  count  = length(var.grants) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  access_control_policy {
    dynamic "grant" {

      for_each = var.grants

      content {
        grantee {
          id   = grant.value.id
          type = grant.value.type
          uri  = grant.value.uri
        }
        permission = grant.value.permissions
      }
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.create_policy == true ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.policy
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.server_side_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    iterator = sse_config
    for_each = var.server_side_encryption_configuration
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm     = lookup(sse_config.value, "sse_algorithm", null)
        kms_master_key_id = lookup(sse_config.value, "kms_master_key_id", null)
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    iterator = lifecycle_rule
    for_each = var.lifecycle_rules

    content {
      id     = lifecycle_rule.value.id
      status = lifecycle_rule.value.status

      dynamic "abort_incomplete_multipart_upload" {
        for_each = lifecycle_rule.value.abort_incomplete_multipart_upload != null ? [lifecycle_rule.value.abort_incomplete_multipart_upload] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }

      dynamic "filter" {
        for_each = lifecycle_rule.value.filter != null ? [lifecycle_rule.value.filter] : []

        content {
          prefix                   = filter.value.prefix
          object_size_greater_than = filter.value.object_size_greater_than
          object_size_less_than    = filter.value.object_size_less_than
          dynamic "tag" {
            for_each = filter.value.tags != null ? [filter.value.tags] : []

            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
          dynamic "and" {
            for_each = filter.value.and != null ? [filter.value.and] : []

            content {
              prefix                   = and.value.prefix
              object_size_greater_than = and.value.object_size_greater_than
              object_size_less_than    = and.value.object_size_less_than
              tags                     = and.value.tags
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = lifecycle_rule.value.expiration != null ? [lifecycle_rule.value.expiration] : []

        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        iterator = transition
        for_each = lifecycle_rule.value.transitions != null ? lifecycle_rule.value.transitions : []

        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration != null ? [lifecycle_rule.value.noncurrent_version_expiration] : []

        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.noncurrent_version_transition != null ? lifecycle_rule.value.noncurrent_version_transition : []

        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
          storage_class             = noncurrent_version_transition.value.storage_class
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

resource "aws_s3_bucket_notification" "this" {
  count = length(var.notifications.lambda_functions) > 0 || length(var.notifications.topics) > 0 || length(var.notifications.queues) > 0 ? 1 : 0

  bucket = aws_s3_bucket_public_access_block.this.id

  dynamic "lambda_function" {
    for_each = var.notifications.lambda_functions
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = var.notifications.topics
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.notifications.queues
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }
}
