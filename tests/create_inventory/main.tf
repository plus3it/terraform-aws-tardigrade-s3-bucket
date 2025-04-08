resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_s3_bucket" "inventory" {
  bucket        = format("%s-%s", "inventory", random_id.name.hex)
  force_destroy = true
}

module "create_inventory" {
  source = "../../"

  bucket        = random_id.name.hex
  force_destroy = true

  inventory = {
    name                     = "EntireBucketDaily"
    included_object_versions = "All"
    enabled                  = true

    schedule = {
      frequency = "Daily"
    }

    destination = {
      bucket = {
        format     = "ORC"
        bucket_arn = aws_s3_bucket.inventory.arn
      }
    }
  }
}

output "create_inventory" {
  value = module.create_inventory
}
