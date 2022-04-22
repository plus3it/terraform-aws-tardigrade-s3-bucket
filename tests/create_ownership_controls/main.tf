resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_ownership_controls" {
  source = "../../"

  bucket = random_id.name.hex
  acl    = "private"

  ownership_controls = {
    rule = {
      object_ownership = "ObjectWriter"
    }
  }
}

output "create_ownership_controls" {
  value = module.create_ownership_controls
}
