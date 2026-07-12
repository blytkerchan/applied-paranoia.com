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

output "site_deploy_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC deploys. Only set on the state that created it (stage == prod and aws_state_bucket set) - other applies will show null here since they don't own the module."
  value       = try(module.github_oidc[0].role_arns["site_deploy"], null)
  sensitive   = false
}
