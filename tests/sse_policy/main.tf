resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_kms_key" "this" {
  description = random_id.name.hex
}

module "sse_policy" {
  source = "../../"

  bucket = random_id.name.hex

  tags = {
    environment = "testing"
  }

  server_side_encryption_configuration = {
    bucket_key_enabled = true
    sse_algorithm      = "aws:kms"
    kms_master_key_id  = aws_kms_key.this.arn
  }
}

output "sse_policy" {
  value = module.sse_policy
}
