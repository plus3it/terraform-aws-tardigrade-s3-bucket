locals {
  partition = "aws"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_policy" {
  source = "../../"

  bucket        = random_id.name.hex
  create_policy = true

  policy = templatefile("${path.module}/templates/config_bucket_policy.json", {
    bucket    = random_id.name.hex
    partition = local.partition
  })
}

output "create_policy" {
  value = module.create_policy
}
