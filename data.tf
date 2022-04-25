data "aws_canonical_user_id" "current" {
  count = length(var.grants) == 0 ? 0 : 1
}

locals {
  default_bucket_policy = jsonencode(
    {
      "Statement" : [
        {
          "Action" : "s3:*",
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          },
          "Effect" : "Deny",
          "Principal" : "*",
          "Resource" : "${aws_s3_bucket.this.arn}/*",
          "Sid" : ""
        }
      ],
      "Version" : "2012-10-17"
    }
  )
}
