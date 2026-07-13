variable "deployment_environment" {
  description = "Environment name (dev, prod, devops). Selects the backend/state; drives the is_devops/is_app split in locals.tf."
  type        = string

  validation {
    condition     = contains(["dev", "prod", "devops"], var.deployment_environment)
    error_message = "deployment_environment must be one of 'dev', 'prod', or 'devops'."
  }
}

variable "selected_environment" {
  description = "Environment selected for the current Terraform run, set automatically by `bootstrap`. Must match deployment_environment - this catches applying the wrong tfvars file against the wrong backend."
  type        = string

  validation {
    condition     = contains(["dev", "prod", "devops"], var.selected_environment)
    error_message = "selected_environment must be one of 'dev', 'prod', or 'devops'."
  }

  validation {
    condition     = var.selected_environment == var.deployment_environment
    error_message = "selected_environment must match deployment_environment. Re-run bootstrap for the intended backend/environment and use the matching tfvars file."
  }
}

variable "aws_region" {
  description = "AWS region for provider and resources."
  type        = string
  default     = "us-east-1"
}

variable "stage" {
  description = "Deployment stage used for hostname selection (for example: prod, dev). Only meaningful when deployment_environment != devops - devops doesn't create site resources."
  type        = string
  default     = "prod"
}

variable "root_domain" {
  description = "Root DNS domain for the site."
  type        = string
  default     = "applied-paranoia.com"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for the CloudFront alias domain. Required for dev/prod (site resources); unused for devops."
  type        = string
  default     = null

  validation {
    condition     = var.deployment_environment == "devops" || var.acm_certificate_arn != null
    error_message = "acm_certificate_arn is required when deployment_environment is dev or prod (the CloudFront distribution needs it)."
  }
}

variable "aws_state_bucket" {
  description = "S3 bucket holding this repo's terraform state (for scoping the devops-only deploy role's state read/write access). Only needed for deployment_environment == devops."
  type        = string
  default     = ""
}
