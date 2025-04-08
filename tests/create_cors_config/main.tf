resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_cors_configuration" {
  source = "../../"

  bucket = random_id.name.hex

  cors_configuration = {
    cors_rules = [
      {
        allowed_headers = ["*"]
        allowed_methods = ["PUT", "POST"]
        allowed_origins = ["https://s3-website-test.hashicorp.com"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
      },
      {
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
      },
    ]
  }
}

output "create_cors_configuration" {
  value = module.create_cors_configuration
}
