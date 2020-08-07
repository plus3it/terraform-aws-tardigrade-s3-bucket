provider "aws" {
  region = "us-east-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket" {
  source = "../../"
  providers = {
    aws = aws
  }

  create_bucket = true
  bucket        = random_id.name.hex
  tags = {
    environment = "testing"
  }
  force_destroy = true
}

resource "aws_s3_bucket_object" "this" {
  bucket = module.create_bucket.bucket.id
  key    = random_id.name.hex
  source = "${path.module}/main.tf"
  etag   = filemd5("${path.module}/main.tf")
}
