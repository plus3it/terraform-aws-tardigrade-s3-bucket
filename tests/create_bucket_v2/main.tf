provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket_v2" {
  source = "../../"
  providers = {
    aws = aws
  }

  bucket = random_id.name.hex
  tags = {
    environment = "testing"
  }
}

output "create_bucket_v2" {
  value = module.create_bucket_v2
}
