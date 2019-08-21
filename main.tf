provider "aws" {}

resource "aws_s3_bucket" "this" {
  count = "${var.create_bucket ? 1 : 0}"

  bucket = "${var.bucket}"
  region = "${var.region}"
  policy = "${var.policy}"
  acl    = "${var.acl}"
  tags   = "${var.tags}"

  versioning {
    enabled = "${var.versioning}"
  }

  server_side_encryption_configuration = "${var.server_side_encryption_configuration}"
}

