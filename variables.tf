variable "bucket" {
  description = "The name of the bucket"
  type        = string
  default     = null
  validation {
    condition     = var.bucket != null ? length(var.bucket) <= 63 : true
    error_message = "Bucket name must be <= to 63 characters in length."
  }
}

variable "logging" {
  description = "Schema object for the S3 bucket logging configuration"
  type = object({
    target_bucket         = string # (Required) The name of the bucket where you want Amazon S3 to store server access logs.
    target_prefix         = string # (Required) A prefix for all log object keys.
    expected_bucket_owner = string # (Optional, Forces new resource) The account ID of the expected bucket owner.
    target_grants = list(object({
      grantee = object({
        email_address = string # (Optional) Email address of the grantee. See Regions and Endpoints for supported AWS regions where this argument can be specified.
        id            = string # (Optional) The canonical user ID of the grantee.
        type          = string # (Required) Type of grantee. Valid values: CanonicalUser, AmazonCustomerByEmail, Group.
        uri           = string # (Optional) URI of the grantee group.
      })
      permission = string # (Required) Logging permissions assigned to the grantee for the bucket. Valid values: FULL_CONTROL, READ, WRITE.
    }))
  })
  default = null
}

variable "ownership_controls" {
  description = "Schema object for the S3 ownership controls"
  type = object({
    rule = object({             # (Required) Configuration block with Ownership Controls rules.
      object_ownership = string # (Required) Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced
    })
  })
  default = null
}

variable "request_payment_configuration" {
  description = "Request payment configuration for the S3 bucket"
  type = object({
    expected_bucket_owner = string # (Optional, Forces new resource) The account ID of the expected bucket owner.
    payer                 = string # (Required) Specifies who pays for the download and request fees. Valid values: BucketOwner, Requester.
  })
  default = null
}

variable "cors_configuration" {
  description = "Schema object of CORS configurations for the S3 bucket"
  type = object({
    expected_bucket_owner = string  # (Optional, Forces new resource) The account ID of the expected bucket owner.
    cors_rules = list(object({      # (Required) Set of origins and methods (cross-origin access that you want to allow). You can configure up to 100 rules.
      allowed_headers = set(string) # (Optional) Set of Headers that are specified in the Access-Control-Request-Headers header.
      allowed_methods = set(string) # (Required) Set of HTTP methods that you allow the origin to execute. Valid values are GET, PUT, HEAD, POST, and DELETE.
      allowed_origins = set(string) # (Required) Set of origins you want customers to be able to access the bucket from.
      expose_headers  = set(string) # (Optional) Set of headers in the response that you want customers to be able to access from their applications (for example, from a JavaScript XMLHttpRequest object).
      id              = string      # (Optional) Unique identifier for the rule. The value cannot be longer than 255 characters.
      max_age_seconds = number      # (Optional) The time in seconds that your browser is to cache the preflight response for the specified resource.
    }))
  })
  default = null
}

variable "intelligent_tiering_configuration" {
  description = "Intelligent_tiering_configurations for the S3 bucket"
  type = object({
    name   = string        # (Required) The unique name used to identify the S3 Intelligent-Tiering configuration for the bucket.
    status = string        # (Required) The status of the rule. Either "Enabled" or "Disabled". The rule is ignored if status is not "Enabled".
    filter = object({      # (Optional) Filter that identifies subset of objects to which the replication rule applies
      prefix = string      # (Optional) An object key name prefix that identifies the subset of objects to which the configuration applies.
      tags   = map(string) # (Optional) All of these tags must exist in the object's tag set in order for the configuration to apply.
    })
    tiering = list(object({ # (Required) The S3 Intelligent-Tiering storage class tiers of the configuration
      access_tier = string  # (Required) S3 Intelligent-Tiering access tier. Valid values: ARCHIVE_ACCESS, DEEP_ARCHIVE_ACCESS.
      days        = number  # (Required) The number of consecutive days of no access after which an object will be eligible to be transitioned to the corresponding tier.
    }))
  })
  default = null
}

variable "replication_configuration" {
  description = "Schema object of the S3 replication configuration"
  type = object({
    role = string                               # Required) The ARN of the IAM role for Amazon S3 to assume when replicating the objects.
    rules = list(object({                       # (Required) List of configuration blocks describing the rules managing the replication
      delete_marker_replication_status = string # (Optional) Whether delete markers are replicated. This argument is only valid with V2 replication configurations (i.e., when filter is used)
      id                               = string # (Optional) Unique identifier for the rule. Must be less than or equal to 255 characters in length.
      priority                         = number # (Optional) The priority associated with the rule. Priority should only be set if filter is configured. If not provided, defaults to 0. Priority must be unique between multiple rules.
      status                           = string # (Required) The status of the rule. Either "Enabled" or "Disabled". The rule is ignored if status is not "Enabled".
      destination = object({                    # Required) Specifies the destination for the rule
        bucket        = string                  # (Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the objects identified by the rule.
        storage_class = string                  # (Optional) The storage class used to store the object. By default, Amazon S3 uses the storage class of the source object to create the object replica.
        account       = string                  # (Optional) The Account ID to specify the replica ownership. Must be used in conjunction with access_control_translation override configuration.
        encryption_configuration = object({     # (Optional) A configuration block that provides information about encryption. If source_selection_criteria is specified, you must specify this element
          replica_kms_key_id = string           # (Required) The ID (Key ARN or Alias ARN) of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) for the destination bucket.
        })
        access_control_translation = object({ # (Optional) A configuration block that specifies the overrides to use for object owners on replication
          owner = string                      # (Required) Specifies the replica ownership. Valid values: Destination.
        })
        metrics = object({           # (Optional) A configuration block that specifies replication metrics-related settings enabling replication metrics and events
          status = string            # (Required) The status of the Destination Metrics. Either "Enabled" or "Disabled".
          event_threshold = object({ # (Optional) A configuration block that specifies the time threshold for emitting the s3:Replication:OperationMissedThreshold event
            minutes = number         # (Required) Time in minutes. Valid values: 15.
          })
        })
        replication_time = object({ # Optional) A configuration block that specifies S3 Replication Time Control (S3 RTC), including whether S3 RTC is enabled and the time when all objects and operations on objects must be replicated. Replication Time Control must be used in conjunction with metrics.
          status = string           # (Required) The status of the Destination Metrics. Either "Enabled" or "Disabled".
          time = object({           # (Required) A configuration block specifying the time by which replication should be complete for all objects and operations on objects
            minutes = number        # (Required) Time in minutes. Valid values: 15.
          })
        })
      })
      filter = object({  # (Optional) Filter that identifies subset of objects to which the replication rule applies
        prefix = string  # (Optional) An object key name prefix that identifies subset of objects to which the rule applies.
        tag = object({   # (Optional) A configuration block for specifying a tag key and value
          key   = string # (Required) Name of the object key
          value = string # (Required) Value of the tag
        })
        and = list(object({    # (Optional) A configuration block for specifying rule filters. This element is required only if you specify more than one filter.
          prefix = string      # (Optional) An object key name prefix that identifies subset of objects to which the rule applies.
          tags   = map(string) # (Optional) A map of tags (key and value pairs) that identifies a subset of objects to which the rule applies. The rule applies only to objects having all the tags in its tagset.
        }))
      })
      source_selection_criteria = object({ # (Optional) Specifies special object selection criteria
        replica_modifications = object({   # (Optional) A configuration block that you can specify for selections for modifications on replicas. Amazon S3 doesn't replicate replica modifications by default. In the latest version of replication configuration (when filter is specified), you can specify this element and set the status to Enabled to replicate modifications on replicas.
          status = string                  # (Required) Whether the existing objects should be replicated. Either "Enabled" or "Disabled".
        })
        sse_kms_encrypted_objects = object({ # (Optional) A configuration block for filter information for the selection of Amazon S3 objects encrypted with AWS KMS. If specified, replica_kms_key_id in destination encryption_configuration must be specified as well. status = string # (Required) Whether the existing objects should be replicated. Either "Enabled" or "Disabled".
        })
      })
    }))
  })
  default = null
}

variable "inventory" {
  description = "Schema object of the S3 bucket inventory configuration"
  type = object({
    name                     = string # (Required) Unique identifier of the inventory configuration for the bucket.
    included_object_versions = string # (Required) Object versions to include in the inventory list. Valid values: All, Current.
    enabled                  = bool   # (Optional, Default: true) Specifies whether the inventory is enabled or disabled.

    schedule = object({  # (Required) Specifies the schedule for generating inventory results.
      frequency = string # (Required) Specifies how frequently inventory results are produced. Valid values: Daily, Weekly.
    })
    destination = object({  # (Required) Contains information about where to publish the inventory results.
      bucket = object({     # (Required) The S3 bucket configuration where inventory results are published.
        bucket_arn = string # (Required) The Amazon S3 bucket ARN of the destination.
        format     = string # (Required) Specifies the output format of the inventory results. Can be CSV, ORC or Parquet.
        account_id = string # (Optional) The ID of the account that owns the destination bucket. Recommended to be set to prevent problems if the destination bucket ownership changes.
        prefix     = string # (Optional) The prefix that is prepended to all inventory results.
        //encryption = object({         # (Optional) Contains the type of server-side encryption to use to encrypt the inventory

        //})
      })
    })
    filter = object({ # (Optional) Specifies an inventory filter. The inventory only includes objects that meet the filter's criteria
      prefix = string # (Optional) The prefix that an object must have to be included in the inventory results.
    })
    //optional_fields = list(string)   # (Optional) List of optional fields that are included in the inventory results. Poorly documented!
  })
  default = null
}

variable "acl" {
  description = "The canned ACL the bucket will use"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "grants" {
  description = "A list of ACL policy grants. Conflicts with `acl`, which must be set to `null`"
  type = list(object({
    id          = string
    type        = string
    permissions = string
    uri         = string
  }))
  default = []
}

variable "notifications" {
  description = "A schema object for the S3 bucket notifications configuration"
  type = object({
    lambda_functions = list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = string
      filter_suffix       = string
    }))
    topics = list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = string
      filter_suffix = string
    }))
    queues = list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = string
      filter_suffix = string
    }))
  })
  default = {
    lambda_functions = []
    topics           = []
    queues           = []
  }
}

variable "policy" {
  description = "A schema object with an IAM policy document in JSON format to apply to the bucket"
  type = object({
    json = string
  })
  default = null
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
  description = "Schema object of the server side encryption configuration"
  type = object({
    bucket_key_enabled = bool
    sse_algorithm      = string
    kms_master_key_id  = string
  })
  default = null
}

variable "tags" {
  description = "The tags applied to the bucket"
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "The state of versioning of the bucket"
  type        = string # (Required) The versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets.
  default     = null
  validation {
    condition     = var.versioning != null ? contains(["Enabled", "Disabled", "Suspended"], var.versioning) : true
    error_message = "The versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled."
  }
}

variable "lifecycle_rules" {
  type = list(object({
    id     = string # (Required) Unique identifier for the rule.
    status = string # (Required) Whether the rule is currently being applied. Valid values: Enabled or Disabled.

    abort_incomplete_multipart_upload = object({
      days_after_initiation = number # number of days after which Amazon S3 aborts an incomplete multipart upload.
    })

    filter = object({
      prefix = string  # (Optional) Prefix identifying one or more objects to which the rule applies.
      tag = object({   # (Optional) A configuration block for specifying a tag key and value
        key   = string # (Required) Name of the object key
        value = string # (Required) Value of the tag
      })
      object_size_greater_than = number # (Optional) Minimum object size to which the rule applies. Value must be at least 0 if specified.
      object_size_less_than    = number # (Optional) Maximum object size to which the rule applies. Value must be at least 1 if specified.
      and = list(object({               # (Optional) Configuration block used to apply a logical AND to two or more predicates
        prefix                   = string
        tags                     = map(string)
        object_size_greater_than = number
        object_size_less_than    = number
      }))
    })

    expiration = object({
      date                         = string # (Optional) The date the object is to be moved or deleted. Should be in RFC3339 format.
      days                         = number # (Optional) The lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer.
      expired_object_delete_marker = string # (Optional, Conflicts with date and days) Indicates whether Amazon S3 will remove a delete marker with no noncurrent versions. If set to true, the delete marker will be expired; if set to false the policy takes no action.
    })

    transitions = list(object({
      date          = string # Must be set to midnight UTC e.g. 2023-01-13T00:00:00Z.
      days          = number # Must be a positive integer
      storage_class = string # Valid Values: GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR
    }))

    noncurrent_version_expiration = object({
      noncurrent_days           = number # days an object is noncurrent before Amazon S3 can perform the associated action. Must be a positive integer.
      newer_noncurrent_versions = number # number of noncurrent versions Amazon S3 will retain. Must be a non-zero positive integer.
    })

    noncurrent_version_transitions = list(object({
      noncurrent_days           = number # days an object is noncurrent before Amazon S3 can perform the associated action. Must be a positive integer.
      newer_noncurrent_versions = number # number of noncurrent versions Amazon S3 will retain. Must be a non-zero positive integer.
      storage_class             = string # Valid Values: GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR
    }))
  }))
  default = []
}
