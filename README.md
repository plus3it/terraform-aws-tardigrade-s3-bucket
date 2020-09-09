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
| acl | The canned ACL the bucket will use | `string` | `"private"` | no |
| force\_destroy | boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `false` | no |
| grants | An ACL policy grant. Conflicts with `acl`, which must be set to `null` | <pre>list(object({<br>    id          = string<br>    type        = string<br>    permissions = list(string)<br>    uri         = string<br>  }))</pre> | `null` | no |
| policy | An IAM policy document in JSON format to apply to the bucket | `string` | `""` | no |
| public\_access\_block | A schema object for the S3 bucket public access block policy | <pre>object({<br>    block_public_acls       = bool<br>    block_public_policy     = bool<br>    ignore_public_acls      = bool<br>    restrict_public_buckets = bool<br>  })</pre> | <pre>{<br>  "block_public_acls": true,<br>  "block_public_policy": true,<br>  "ignore_public_acls": true,<br>  "restrict_public_buckets": true<br>}</pre> | no |
| server\_side\_encryption\_configuration | A list of schema objects for the server side encryption configuration | `list` | `[]` | no |
| tags | The tags applied to the bucket | `map(string)` | `{}` | no |
| versioning | The state of versioning of the bucket | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | AWS S3 Bucket object |

<!-- END TFDOCS -->
