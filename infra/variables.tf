variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "stage" {
  type    = string
  default = "prod"
}

variable "root_domain" {
  type    = string
  default = "applied-paranoia.com"
}

variable "acm_certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:981855120431:certificate/58d98960-42ee-47de-81de-d36623c86a8a"
}
