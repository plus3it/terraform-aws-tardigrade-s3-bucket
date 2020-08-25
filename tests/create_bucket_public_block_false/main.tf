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

  bucket = random_id.name.hex

  public_access_block = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }

  tags = {
    environment = "testing"
  }
}
