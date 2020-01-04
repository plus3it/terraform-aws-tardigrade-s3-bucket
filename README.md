# terraform-aws-tardigrade-s3-bucket

Terraform module to create a S3 bucket

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acl | The canned ACL the bucket will use | string | `"private"` | no |
| bucket | The name of the bucket | string | n/a | yes |
| create\_bucket | Controls whether to create a bucket | bool | `"true"` | no |
| force\_destroy | boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | bool | `"false"` | no |
| policy | An IAM policy document in JSON format to apply to the bucket | string | `""` | no |
| public\_access\_block | A schema object for the S3 bucket public access block policy | object | `<map>` | no |
| region | Region where the bucket will reside | string | `"null"` | no |
| server\_side\_encryption\_configuration | A list of schema objects for the server side encryption configuration | list | `<list>` | no |
| tags | The tags applied to the bucket | map(string) | `<map>` | no |
| versioning | The state of versioning of the bucket | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | AWS S3 Bucket object |

