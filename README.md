# terraform-aws-tardigrade-s3-bucket

Terraform module to create a S3 bucket

<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket | The name of the bucket | `string` | n/a | yes |
| acl | The canned ACL the bucket will use | `string` | `null` | no |
| force\_destroy | Boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `false` | no |
| grants | A list of ACL policy grants. Conflicts with `acl`, which must be set to `null` | <pre>list(object({<br>    id          = string<br>    type        = string<br>    permissions = list(string)<br>    uri         = string<br>  }))</pre> | `[]` | no |
| lifecycle\_rules | n/a | <pre>list(object({<br>    id                                     = string<br>    enabled                                = string<br>    prefix                                 = string<br>    tags                                   = map(string)<br>    abort_incomplete_multipart_upload_days = number<br><br>    expiration = object({<br>      date                         = string<br>      days                         = number<br>      expired_object_delete_marker = string<br>    })<br><br>    transitions = list(object({<br>      date          = string<br>      days          = number<br>      storage_class = string<br>    }))<br><br>    noncurrent_version_expiration = object({<br>      days = number<br>    })<br><br>    noncurrent_version_transitions = list(object({<br>      days          = number<br>      storage_class = string<br>    }))<br>  }))</pre> | `[]` | no |
| notifications | A schema object for the S3 bucket notifications configuration | <pre>object({<br>    lambda_functions = list(object({<br>      lambda_function_arn = string<br>      events              = list(string)<br>      filter_prefix       = string<br>      filter_suffix       = string<br>    }))<br>    topics = list(object({<br>      topic_arn     = string<br>      events        = list(string)<br>      filter_prefix = string<br>      filter_suffix = string<br>    }))<br>    queues = list(object({<br>      queue_arn     = string<br>      events        = list(string)<br>      filter_prefix = string<br>      filter_suffix = string<br>    }))<br>  })</pre> | <pre>{<br>  "lambda_functions": [],<br>  "queues": [],<br>  "topics": []<br>}</pre> | no |
| policy | An IAM policy document in JSON format to apply to the bucket | `string` | `""` | no |
| public\_access\_block | A schema object for the S3 bucket public access block policy | <pre>object({<br>    block_public_acls       = bool<br>    block_public_policy     = bool<br>    ignore_public_acls      = bool<br>    restrict_public_buckets = bool<br>  })</pre> | <pre>{<br>  "block_public_acls": true,<br>  "block_public_policy": true,<br>  "ignore_public_acls": true,<br>  "restrict_public_buckets": true<br>}</pre> | no |
| server\_side\_encryption\_configuration | A list of schema objects for the server side encryption configuration | `list(any)` | `[]` | no |
| tags | The tags applied to the bucket | `map(string)` | `{}` | no |
| versioning | The state of versioning of the bucket | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | AWS S3 Bucket object |
| notification | Object containing the AWS S3 Bucket notification configuration |
| public\_access\_block | Object containing the AWS S3 Bucket public access block configuration |

<!-- END TFDOCS -->
