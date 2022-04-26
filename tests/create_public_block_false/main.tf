resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_public_access_block" {
  source = "../../"

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

output "create_public_access_block" {
  value = module.create_public_access_block
}
