resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_s3_bucket" "inventory" {
  bucket = format("%s-%s", "inventory", random_id.name.hex)
}

module "create_bucket" {
  source = "../../"

  bucket = random_id.name.hex

  bucket_inventory = {

    name                     = "EntireBucketDaily"
    included_object_versions = "All"
    enabled                  = true

    filter = null
    
    schedule = {
      frequency = "Daily"
    }

    destination = {
      bucket = {
        format     = "ORC"
        bucket_arn = aws_s3_bucket.inventory.arn
        account_id = null
        prefix = null
      }
    }
  }
}
