resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_s3_bucket" "inventory" {
  bucket = format("%s-%s", "inventory", random_id.name.hex)
}

// moto has not implemented the bucket_inventory_configuration yet, so the CI test fails while running pytest.  The 
// test passes when run against an actual AWS account.  We need to uncomment the folloiwng module when moto catches 
// up.  
/*module "create_bucket" {
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
        prefix     = null
      }
    }
  } 
} */
