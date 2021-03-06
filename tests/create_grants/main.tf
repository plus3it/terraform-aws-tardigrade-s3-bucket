provider "aws" {
  region = "us-east-1"
}

data "aws_canonical_user_id" "current_user" {}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_grants" {
  source = "../../"
  providers = {
    aws = aws
  }

  acl = null

  grants = [
    {
      id          = data.aws_canonical_user_id.current_user.id
      type        = "CanonicalUser"
      permissions = ["READ"]
      uri         = null
    },
    {
      id          = null
      type        = "Group"
      permissions = ["READ", "WRITE"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
  ]
  bucket = random_id.name.hex
  tags = {
    environment = "testing"
  }
}

output "create_bucket" {
  value = module.create_grants
}
