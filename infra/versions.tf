terraform {
  required_version = ">= 1.7.0" # mock_provider (tests/*.tftest.hcl) requires 1.7+

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}
