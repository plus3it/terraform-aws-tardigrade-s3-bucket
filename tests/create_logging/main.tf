resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = format("%s-%s", "logging", random_id.name.hex)
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

module "create_bucket" {
  source = "../../"

  acl    = "private"
  bucket = random_id.name.hex

  logging = {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
    expected_bucket_owner = null
    target_grants = null
  }  
}

output "create_bucket" {
  value = module.create_bucket
}
