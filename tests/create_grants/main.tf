data "aws_canonical_user_id" "current_user" {}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_grants" {
  source = "../../"

  bucket = random_id.name.hex

  grants = [
    {
      id          = data.aws_canonical_user_id.current_user.id
      type        = "CanonicalUser"
      permissions = "READ"
      uri         = null
    },
    {
      id          = null
      type        = "Group"
      permissions = "READ"
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    {
      id          = null
      type        = "Group"
      permissions = "WRITE"
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
  ]

  tags = {
    environment = "testing"
  }
}

output "create_grants" {
  value = module.create_grants
}
