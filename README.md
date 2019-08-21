# terraform-aws-tardigrade-s3-bucket

Terraform module to create a S3 bucket

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acl | The canned ACL the bucket will use | string | `"private"` | no |
| bucket | The name of the bucket | string | n/a | yes |
| create\_bucket | Controls whether to create a bucket | string | `"false"` | no |
| policy | An IAM policy document in JSON format to apply to the bucket | string | `""` | no |
| region | Region where the bucket will reside | string | n/a | yes |
| server\_side\_encryption\_configuration | A schema for the server side encryption configuration | list | `<list>` | no |
| tags | The tags applied to the bucket | map | `<map>` | no |
| versioning | The state of versioning of the bucket | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | The Amazon Resource Name of the bucket |
| bucket\_id | The name of the bucket |
| bucket\_region | The region in which the bucket was created |

