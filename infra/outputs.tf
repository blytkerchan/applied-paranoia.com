output "site_name" {
  description = "Fully qualified site hostname for the active stage."
  value       = local.site_name
  sensitive   = false
}

output "s3_bucket_name" {
  description = "S3 bucket name serving static site content."
  value       = aws_s3_bucket.site.id
  sensitive   = false
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation and operations."
  value       = aws_cloudfront_distribution.site.id
  sensitive   = false
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.site.domain_name
  sensitive   = false
}
