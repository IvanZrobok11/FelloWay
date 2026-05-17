output "s3_bucket_name" { value = aws_s3_bucket.web.id }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.web.id }
output "cloudfront_domain_name" { value = aws_cloudfront_distribution.web.domain_name }
output "cloudfront_hosted_zone_id" { value = aws_cloudfront_distribution.web.hosted_zone_id }
