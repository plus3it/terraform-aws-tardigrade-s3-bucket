resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = format("%s-%s", "logging", random_id.name.hex)
  force_destroy = true
}

resource "aws_s3_bucket_acl" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

module "create_logging" {
  source = "../../"

  bucket        = random_id.name.hex
  force_destroy = true

  logging = {
    target_bucket = aws_s3_bucket_acl.log_bucket.bucket
    target_prefix = "log/"
    target_grants = null
  }
}

output "create_logging" {
  value = module.create_logging
}
