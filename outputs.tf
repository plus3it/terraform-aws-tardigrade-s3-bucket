output "bucket" {
  description = "AWS S3 Bucket object"
  value       = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this : null
}
