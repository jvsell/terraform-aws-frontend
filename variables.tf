variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = true
}

variable "enable_cloudfront_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "cloudfront_logging_bucket" {
  description = "The S3 bucket for CloudFront access logs"
  type        = string
  default     = null
}

variable "cloudfront_logging_prefix" {
  description = "The prefix for CloudFront access logs"
  type        = string
  default     = null
}
