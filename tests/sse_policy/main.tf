provider "aws" {
  region = "us-east-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_kms_key" "this" {
  description = random_id.name.hex
}

module "sse_policy" {
  source = "../../"
  providers = {
    aws = aws
  }

  create_bucket = "true"
  bucket        = random_id.name.hex
  tags = {
    environment = "testing"
  }

  server_side_encryption_configuration = [{
    "sse_algorithm"     = "aws:kms"
    "kms_master_key_id" = aws_kms_key.this.arn
  }]
}
