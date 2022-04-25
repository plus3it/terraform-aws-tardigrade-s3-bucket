output "bucket" {
  description = "AWS S3 Bucket object"
  value       = aws_s3_bucket.this

  depends_on = [
    aws_s3_bucket_logging.this,
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_request_payment_configuration.this,
    aws_s3_bucket_cors_configuration.this,
    aws_s3_bucket_intelligent_tiering_configuration.this,
    aws_s3_bucket_replication_configuration.this,
    aws_s3_bucket_inventory.this,
    aws_s3_bucket_acl.with_acl,
    aws_s3_bucket_acl.with_grants,
    aws_s3_bucket_policy.this,
    aws_s3_bucket_versioning.this,
    aws_s3_bucket_server_side_encryption_configuration.this,
    aws_s3_bucket_lifecycle_configuration.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_notification.this,
  ]
}

output "public_access_block" {
  description = "Object containing the AWS S3 Bucket public access block configuration"
  value       = aws_s3_bucket_public_access_block.this
}

output "notification" {
  description = "Object containing the AWS S3 Bucket notification configuration"
  value       = aws_s3_bucket_notification.this
}
