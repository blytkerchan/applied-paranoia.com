locals {
  site_name = var.stage == "prod" ? var.root_domain : "${var.stage}.${var.root_domain}"
}

data "aws_route53_zone" "root" {
  count = local.is_app ? 1 : 0

  name         = "${var.root_domain}."
  private_zone = false
}

resource "aws_s3_bucket" "site" {
  count = local.is_app ? 1 : 0

  bucket        = local.site_name
  force_destroy = false

  tags = {
    STAGE = var.stage
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  count = local.is_app ? 1 : 0

  bucket = aws_s3_bucket.site[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "site" {
  count = local.is_app ? 1 : 0

  name                              = "${local.site_name}-oac"
  description                       = "Origin access control for ${local.site_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "rewrite_pretty_urls" {
  count = local.is_app ? 1 : 0

  name    = "${replace(local.site_name, ".", "-")}-rewrite-pretty-urls"
  runtime = "cloudfront-js-1.0"
  publish = true
  comment = "Rewrite pretty URLs to index.html for S3 REST origin"
  code    = <<-EOT
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
    return request;
  }

  if (!uri.includes('.')) {
    request.uri = uri + '/index.html';
  }

  return request;
}
EOT
}

data "aws_iam_policy_document" "site_cloudfront_read" {
  count = local.is_app ? 1 : 0

  version = "2012-10-17"

  statement {
    sid       = "AllowCloudFrontRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site[0].arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  count = local.is_app ? 1 : 0

  bucket = aws_s3_bucket.site[0].id
  policy = data.aws_iam_policy_document.site_cloudfront_read[0].json
}

resource "aws_cloudfront_distribution" "site" {
  count = local.is_app ? 1 : 0

  enabled             = true
  aliases             = [local.site_name]
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  http_version        = "http2"

  origin {
    domain_name              = aws_s3_bucket.site[0].bucket_regional_domain_name
    origin_id                = "StaticSite"
    origin_access_control_id = aws_cloudfront_origin_access_control.site[0].id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    target_origin_id       = "StaticSite"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_pretty_urls[0].arn
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    STAGE = var.stage
  }
}

resource "aws_route53_record" "site_a" {
  count = local.is_app ? 1 : 0

  zone_id = data.aws_route53_zone.root[0].zone_id
  name    = local.site_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site[0].domain_name
    zone_id                = aws_cloudfront_distribution.site[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# OIDC deploy role for GitHub Actions, replacing the static AWS_ACCESS_KEY_ID/
# AWS_SECRET_ACCESS_KEY currently used by deploy.yml/destroy.yml. Owned by the
# devops state, not app: an IAM OIDC provider is account-global, so it must
# only ever be created once regardless of how many site environments exist.
# The role's subject_claims cover the whole repo, so one role already serves
# every branch/stage - dev and prod deploys just need its ARN as a variable.
#
# Also gated on aws_state_bucket being set: an empty value would produce
# invalid S3 ARNs (arn:aws:s3::: / arn:aws:s3:::/*) in the inline policy
# below rather than failing clearly. Skipping creation until the var is
# actually set is safer than applying a broken policy.
#
# Not yet wired into deploy.yml/destroy.yml - that's a follow-up PR, once
# this has been applied and the resulting role ARN is available to set as a
# repo variable.
module "github_oidc" {
  count = local.is_devops && var.aws_state_bucket != "" ? 1 : 0

  source = "git::https://github.com/vln-devsecops/terraform-modules.git//modules/aws/github_oidc?ref=v0.17.0"

  roles = {
    site_deploy = {
      role_name      = "applied-paranoia-com-site-deploy"
      description    = "Deploy applied-paranoia.com (all branches/stages) from GitHub Actions"
      subject_claims = ["repo:blytkerchan/applied-paranoia.com:*"]
      inline_policies = {
        site_management = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Sid    = "S3SiteManagement"
              Effect = "Allow"
              Action = [
                "s3:CreateBucket", "s3:DeleteBucket", "s3:Get*", "s3:List*",
                "s3:DeleteObject", "s3:DeleteObjectVersion",
                "s3:PutBucketPolicy", "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketTagging", "s3:PutBucketVersioning",
                "s3:PutObject", "s3:PutObjectTagging",
                "s3:DeleteBucketPolicy",
              ]
              # any stage's site bucket: <root_domain>, dev.<root_domain>, <branch>.<root_domain>, ...
              Resource = [
                "arn:aws:s3:::*${var.root_domain}",
                "arn:aws:s3:::*${var.root_domain}/*",
              ]
            },
            {
              # Bucket-level actions can't be scoped to a prefix via Resource
              # alone (GetBucketVersioning has no object-key concept at all;
              # ListBucket needs the bucket ARN, so it's scoped to this
              # repo's state prefix via a condition instead - see the
              # object-level statement below for the actual read/write scope).
              Sid    = "StateBucketLevel"
              Effect = "Allow"
              Action = [
                "s3:ListBucket", "s3:GetBucketVersioning",
              ]
              Resource = "arn:aws:s3:::${var.aws_state_bucket}"
              Condition = {
                StringLike = {
                  "s3:prefix" = ["applied-paranoia/*"]
                }
              }
            },
            {
              Sid    = "StateObjectReadWrite"
              Effect = "Allow"
              Action = [
                "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
              ]
              # scoped to this repo's own state prefix, not the whole bucket -
              # reduces blast radius if the deploy role is ever compromised
              Resource = "arn:aws:s3:::${var.aws_state_bucket}/applied-paranoia/*"
            },
            {
              Sid    = "CloudFrontManagement"
              Effect = "Allow"
              Action = [
                "cloudfront:CreateDistribution", "cloudfront:UpdateDistribution",
                "cloudfront:GetDistribution", "cloudfront:GetDistributionConfig",
                "cloudfront:DeleteDistribution",
                "cloudfront:CreateInvalidation", "cloudfront:GetInvalidation",
                "cloudfront:CreateOriginAccessControl", "cloudfront:GetOriginAccessControl",
                "cloudfront:UpdateOriginAccessControl", "cloudfront:DeleteOriginAccessControl",
                "cloudfront:CreateFunction", "cloudfront:UpdateFunction",
                "cloudfront:DeleteFunction", "cloudfront:DescribeFunction",
                "cloudfront:GetFunction", "cloudfront:PublishFunction",
                "cloudfront:TagResource", "cloudfront:ListTagsForResource",
              ]
              Resource = "*"
            },
            {
              Sid    = "Route53Management"
              Effect = "Allow"
              Action = [
                "route53:ChangeResourceRecordSets", "route53:GetHostedZone",
                "route53:GetChange", "route53:ListResourceRecordSets",
                "route53:ListHostedZonesByName", "route53:ListHostedZones",
              ]
              Resource = "*"
            },
            {
              Sid      = "ACMRead"
              Effect   = "Allow"
              Action   = ["acm:DescribeCertificate", "acm:ListCertificates"]
              Resource = "*"
            },
          ]
        })
      }
    }
  }

  tags = { app = "applied-paranoia.com" }
}
