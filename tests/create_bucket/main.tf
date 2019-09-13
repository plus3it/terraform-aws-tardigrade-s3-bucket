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

  create_bucket = "true"
  bucket        = random_id.name.hex
  region        = "us-east-1"
  tags = {
    environment = "testing"
  }
}
