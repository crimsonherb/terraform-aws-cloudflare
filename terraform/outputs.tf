output "website_url" {
  description = "Satic website URL"
  value       = "https://${var.site_domain}"
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}