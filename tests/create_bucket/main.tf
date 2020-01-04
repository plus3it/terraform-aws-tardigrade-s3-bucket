provider "aws" {
  region = "us-east-1"
}

resource "random_id" "name" {
  count = 2

  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket" {
  source = "../../"
  providers = {
    aws = aws
  }

  create_bucket = true
  bucket        = random_id.name[0].hex
  region        = "us-east-1"
  tags = {
    environment = "testing"
  }
}

module "create_bucket_null_region" {
  source = "../../"
  providers = {
    aws = aws
  }

  create_bucket = true
  bucket        = random_id.name[1].hex
  tags = {
    environment = "testing"
  }
}

output "create_bucket" {
  value = module.create_bucket
}

output "create_bucket_null_region" {
  value = module.create_bucket_null_region
}
