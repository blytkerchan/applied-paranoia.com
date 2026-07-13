output "site_name" {
  description = "Fully qualified site hostname for the active stage. Null for the devops state (no site resources there)."
  value       = local.is_app ? local.site_name : null
  sensitive   = false
}

output "s3_bucket_name" {
  description = "S3 bucket name serving static site content. Null for the devops state."
  value       = try(aws_s3_bucket.site[0].id, null)
  sensitive   = false
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation and operations. Null for the devops state."
  value       = try(aws_cloudfront_distribution.site[0].id, null)
  sensitive   = false
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name. Null for the devops state."
  value       = try(aws_cloudfront_distribution.site[0].domain_name, null)
  sensitive   = false
}

output "site_deploy_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC deploys. Only set on the devops state (and only once aws_state_bucket is set there) - other states will show null here since they don't own the module."
  value       = try(module.github_oidc[0].role_arns["site_deploy"], null)
  sensitive   = false
}

output "selected_environment" {
  description = "Confirms which environment bootstrap selected for this run - useful for debugging a state/backend mismatch (also gives selected_environment a real reference so it's not just a validation-only variable, which tflint's unused-declarations check can't otherwise see past)."
  value       = var.selected_environment
  sensitive   = false
}
