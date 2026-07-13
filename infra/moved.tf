# Records the address change from adding `count = local.is_app ? 1 : 0` to
# every existing site resource (see main.tf). Without these, terraform plan
# against the real prod/dev state shows 2 "will be updated in-place" changes
# (the CloudFront distribution's origin block and the S3 bucket policy) that
# are pure plan-time "known after apply" artifacts of the address change,
# not real infrastructure drift - AWS would receive an update call with
# identical content. These moved blocks make the migration a true no-op.
moved {
  from = aws_s3_bucket.site
  to   = aws_s3_bucket.site[0]
}

moved {
  from = aws_s3_bucket_public_access_block.site
  to   = aws_s3_bucket_public_access_block.site[0]
}

moved {
  from = aws_cloudfront_origin_access_control.site
  to   = aws_cloudfront_origin_access_control.site[0]
}

moved {
  from = aws_cloudfront_function.rewrite_pretty_urls
  to   = aws_cloudfront_function.rewrite_pretty_urls[0]
}

moved {
  from = aws_s3_bucket_policy.site
  to   = aws_s3_bucket_policy.site[0]
}

moved {
  from = aws_cloudfront_distribution.site
  to   = aws_cloudfront_distribution.site[0]
}

moved {
  from = aws_route53_record.site_a
  to   = aws_route53_record.site_a[0]
}
