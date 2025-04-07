module "create_logging" {
  source = "../../"

  bucket        = random_id.name.hex
  force_destroy = true

  logging = {
    target_bucket = aws_s3_bucket_policy.log_bucket.bucket
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = format("%s-%s", "logging", random_id.name.hex)
  force_destroy = true
}

resource "aws_s3_bucket_policy" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3ServerAccessLogsPolicy",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.log_bucket.id}/*",
      }
    ]
  })
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

output "create_logging" {
  value = module.create_logging
}
