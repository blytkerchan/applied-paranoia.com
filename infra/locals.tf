locals {
  # devops owns account-wide resources (currently: the GitHub Actions OIDC
  # deploy role). app (dev/prod) owns the actual site resources. Kept as a
  # genuinely separate state/backend key from the site states so an IAM OIDC
  # provider - which is account-global, not per-state - only ever gets
  # created once, regardless of how many site environments exist.
  is_devops = var.deployment_environment == "devops"
  is_app    = var.deployment_environment != "devops"
}
