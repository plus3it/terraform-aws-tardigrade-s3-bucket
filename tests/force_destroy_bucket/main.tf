resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "force_destroy" {
  source = "../../"

  bucket        = random_id.name.hex
  force_destroy = true

  tags = {
    environment = "testing"
  }
}

resource "aws_s3_bucket_object" "this" {
  bucket = module.force_destroy.bucket.id
  key    = random_id.name.hex
  source = "${path.module}/main.tf"
  etag   = filemd5("${path.module}/main.tf")
}

output "force_destroy" {
  value = module.force_destroy
}
