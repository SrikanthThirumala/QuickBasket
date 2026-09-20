resource "aws_cloudfront_origin_access_control" "quickbasket-img-fetch-s3-oac" {
  name                              = "quickbasket-oac-${var.cldfrnt_config.environment}"
  description                       = "OAC for QuickBasket S3 images"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

resource "aws_cloudfront_distribution" "quickbasket_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  
  origin {
    domain_name              = var.cldfrnt_config.quickbasket_img_fetch_s3_regional_domain_name
    origin_id                = "s3-product-origin" # Local reference label
    origin_access_control_id = aws_cloudfront_origin_access_control.quickbasket-img-fetch-s3-oac.id
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-product-origin" # Must match origin_id above

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}