output "quickbasket_img_fetch_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.quickbasket_cdn.domain_name
}

output "quickbasket_img_fetch_cloudfront_arn" {
  value = aws_cloudfront_distribution.quickbasket_cdn.arn
}