resource "aws_s3_bucket" "site" {
  bucket = var.site_domain

  tags = {
    Name        = "SiteBucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "site_ownership_control" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "site_block" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = false # Needed for OAC to access via policy
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "site_versioning" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.site.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}


resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.site_domain}-oac"
  description                       = "Origin Access Control for ${var.site_domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.site_domain}"
  default_root_object = var.index_document

  default_cache_behavior {
    # Using the CachingOptimized managed policy ID:
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "site_cert" {
  domain_name       = var.site_domain
  validation_method = "DNS"

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "site_cname" {
  zone_id = var.cloudflare_zone_id
  name    = var.site_domain
  type    = "CNAME"
  comment = "Points to cloudfront"
  content = aws_cloudfront_distribution.s3_distribution.domain_name
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 3600
  comment = "ACM DNS validation record"
  content = each.value.value
  proxied = false 

  # Optional settings block, only applicable if needed
  # You can remove or customize if not relevant to validation records
  settings = {
    ipv4_only = false
    ipv6_only = false
  }

}