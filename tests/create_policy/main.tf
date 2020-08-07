provider "aws" {
  region = "us-east-1"
}

locals {
  create_bucket = "true"
  partition     = "aws"
}

data "template_file" "this" {
  count = local.create_bucket ? 1 : 0

  template = file("${path.module}/templates/config_bucket_policy.json")

  vars = {
    bucket    = random_id.name.hex
    partition = local.partition
  }
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_policy" {
  source = "../../"
  providers = {
    aws = aws
  }

  create_bucket = "true"
  bucket        = random_id.name.hex
  policy        = join("", data.template_file.this.*.rendered)
  tags = {
    environment = "testing"
  }
}
