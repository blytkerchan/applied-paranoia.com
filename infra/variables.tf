variable "aws_region" {
  description = "AWS region for provider and resources."
  type        = string
  default     = "us-east-1"
}

variable "stage" {
  description = "Deployment stage used for hostname selection (for example: prod, dev)."
  type        = string
  default     = "prod"
}

variable "root_domain" {
  description = "Root DNS domain for the site."
  type        = string
  default     = "applied-paranoia.com"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for the CloudFront alias domain."
  type        = string
}

variable "aws_state_bucket" {
  description = "S3 bucket holding this repo's terraform state (for scoping the deploy role's state read/write access)."
  type        = string
  default     = ""
}
