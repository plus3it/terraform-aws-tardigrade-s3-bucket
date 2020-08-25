provider "aws" {
  region = "us-east-1"
}

locals {
  partition = "aws"
}

data "template_file" "this" {

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

  bucket = random_id.name.hex
  policy = join("", data.template_file.this.*.rendered)
  tags = {
    environment = "testing"
  }
}