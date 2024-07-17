data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  acl = var.enable_cloudfront ? "private" : "public-read"

  tags = {
    Name = var.bucket_name
  }

  policy = var.enable_cloudfront ? local.cloudfront_policy : local.global_policy
}

resource "aws_s3_bucket" "cloudfront_logging_bucket" {
  count = var.enable_cloudfront_logging ? 1 : 0

  bucket = coalesce(var.cloudfront_logging_bucket, "cloudfront-logs-${data.aws_caller_identity.current.account_id}")

  tags = {
    Name = "CloudFrontLoggingBucket"
  }
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  count = var.enable_cloudfront ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = var.bucket_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = false
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Frontend for ${var.bucket_name}"
  default_root_object = "index.html"

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.bucket_name
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  logging_config {
    bucket = coalesce(var.cloudfront_logging_bucket, aws_s3_bucket.cloudfront_logging_bucket[0].bucket_domain_name)
    prefix = "${coalesce(var.cloudfront_logging_prefix, "cloudfront/")}${var.bucket_name}/"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  count = var.enable_cloudfront ? 1 : 0

  comment = "OAI for ${var.bucket_name}"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  count = var.enable_cloudfront ? 1 : 0

  origin_id                           = aws_cloudfront_distribution.frontend_distribution[count.index].id
  origin_access_control_origin_type   = "s3"  # Aqui define o tipo de origem como S3

  # Outros argumentos necessários conforme sua configuração
}

locals {
  cloudfront_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai[count.index].s3_canonical_user_id
        },
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })

  global_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}
