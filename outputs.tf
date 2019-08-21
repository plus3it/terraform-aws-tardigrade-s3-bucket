# Bucket
output "bucket_id" {
  description = "The name of the bucket"
  value       = "${join("", aws_s3_bucket.this.*.id)}"
}

output "bucket_region" {
  description = "The region in which the bucket was created"
  value       = "${join("", aws_s3_bucket.this.*.region)}"
}

output "bucket_arn" {
  description = "The Amazon Resource Name of the bucket"
  value       = "${join("", aws_s3_bucket.this.*.arn)}"
}

