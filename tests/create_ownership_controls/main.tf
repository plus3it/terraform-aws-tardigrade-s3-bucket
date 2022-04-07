resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket" {
  source = "../../"

  acl    = "private"
  bucket = random_id.name.hex

  ownership_controls = {
    rule = {
      object_ownership = "ObjectWriter"
    } 
  }
}

output "create_bucket" {
  value = module.create_bucket
}
