output "bucket" {
  description = "AWS S3 Bucket object"
  value       = aws_s3_bucket.this
}

output "public_access_block" {
  description = "Object containing the AWS S3 Bucket public access block configuration"
  value       = aws_s3_bucket_public_access_block.this
}

output "notification" {
  description = "Object containing the AWS S3 Bucket notification configuration"
  value       = aws_s3_bucket_notification.this
}
