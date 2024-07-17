output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend_distribution.id
}

output "cloudfront_logging_bucket_name" {
  description = "The name of the CloudFront logging bucket"
  value       = aws_s3_bucket.cloudfront_logging_bucket.bucket
}

output "cloudfront_logging_bucket_arn" {
  description = "The ARN of the CloudFront logging bucket"
  value       = aws_s3_bucket.cloudfront_logging_bucket.arn
}
