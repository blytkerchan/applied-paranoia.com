# Unit tests for the environments/bootstrap pattern's core logic - the
# is_devops/is_app resource split and the variable validations - using
# Terraform's native mock_provider so no real AWS credentials or network
# access are needed. Run with: terraform test

mock_provider "aws" {}

run "prod_creates_site_not_oidc" {
  command = plan

  variables {
    deployment_environment = "prod"
    selected_environment   = "prod"
    stage                  = "prod"
    acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/test"
  }

  assert {
    condition     = local.is_app == true && local.is_devops == false
    error_message = "prod should be is_app, not is_devops"
  }

  assert {
    condition     = length(aws_s3_bucket.site) == 1
    error_message = "prod should create the site S3 bucket"
  }

  assert {
    condition     = length(aws_cloudfront_distribution.site) == 1
    error_message = "prod should create the CloudFront distribution"
  }

  assert {
    condition     = length(aws_route53_record.site_a) == 1
    error_message = "prod should create the Route53 record"
  }

  assert {
    condition     = length(module.github_oidc) == 0
    error_message = "prod must NOT create the OIDC module - only devops owns it"
  }
}

run "dev_creates_site_not_oidc" {
  command = plan

  variables {
    deployment_environment = "dev"
    selected_environment   = "dev"
    stage                  = "dev"
    acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/test"
  }

  assert {
    condition     = local.is_app == true && local.is_devops == false
    error_message = "dev should be is_app, not is_devops"
  }

  assert {
    condition     = length(aws_s3_bucket.site) == 1
    error_message = "dev should create the site S3 bucket"
  }

  assert {
    condition     = length(module.github_oidc) == 0
    error_message = "dev must NOT create the OIDC module"
  }
}

run "devops_creates_oidc_not_site" {
  command = plan

  variables {
    deployment_environment = "devops"
    selected_environment   = "devops"
    aws_state_bucket       = "s3-applied-paranoia-prod-tfstate"
  }

  assert {
    condition     = local.is_devops == true && local.is_app == false
    error_message = "devops should be is_devops, not is_app"
  }

  assert {
    condition     = length(aws_s3_bucket.site) == 0
    error_message = "devops must NOT create the site S3 bucket - that would duplicate the live site"
  }

  assert {
    condition     = length(aws_cloudfront_distribution.site) == 0
    error_message = "devops must NOT create a CloudFront distribution"
  }

  assert {
    condition     = length(module.github_oidc) == 1
    error_message = "devops should create the OIDC module (aws_state_bucket is set)"
  }
}

run "devops_without_state_bucket_skips_oidc_instead_of_breaking" {
  command = plan

  variables {
    deployment_environment = "devops"
    selected_environment   = "devops"
    # aws_state_bucket intentionally omitted (defaults to "")
  }

  assert {
    condition     = length(module.github_oidc) == 0
    error_message = "with aws_state_bucket unset, the OIDC module should be skipped, not applied with invalid S3 ARNs"
  }
}

run "mismatched_selected_environment_is_rejected" {
  command = plan

  variables {
    deployment_environment = "prod"
    selected_environment   = "dev"
    acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/test"
  }

  expect_failures = [
    var.selected_environment,
  ]
}

run "invalid_deployment_environment_is_rejected" {
  command = plan

  variables {
    deployment_environment = "staging"
    selected_environment   = "staging"
  }

  expect_failures = [
    var.deployment_environment,
  ]
}

run "missing_acm_cert_rejected_for_app_environment" {
  command = plan

  variables {
    deployment_environment = "prod"
    selected_environment   = "prod"
    # acm_certificate_arn intentionally omitted (defaults to null)
  }

  expect_failures = [
    var.acm_certificate_arn,
  ]
}

run "missing_acm_cert_allowed_for_devops" {
  command = plan

  variables {
    deployment_environment = "devops"
    selected_environment   = "devops"
    # acm_certificate_arn intentionally omitted - devops doesn't need it
  }

  assert {
    condition     = var.acm_certificate_arn == null
    error_message = "devops should be able to omit acm_certificate_arn"
  }
}
