resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket" {
  source = "../../"

  bucket = random_id.name.hex

  cors_configuration = {
    expected_bucket_owner = null
    cors_rules = [
      {
        allowed_headers = ["*"]
        allowed_methods = ["PUT", "POST"]
        allowed_origins = ["https://s3-website-test.hashicorp.com"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
        id              = null
      },
      {
        allowed_headers = null
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        expose_headers  = null
        max_age_seconds = null
        id              = null
      }
    ]  
  }
}

output "create_bucket" {
  value = module.create_bucket
}
