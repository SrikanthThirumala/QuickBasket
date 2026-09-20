output "sri-quickbasket-img-production-bucket-arn" {
 value=aws_s3_bucket.sri-quickbasket-img-production.arn
 description = "sri-quickbasket-img-production-bucket-arn value" 
}



output "sri-quickbasket-loki-logs-bucket-arn" {
 value=aws_s3_bucket.sri-quickbasket-loki-logs-production.arn
 description = "sri-quickbasket-loki-logs-production-bucket-arn value" 
}

output "sri-quickbasket-img-production-bucket-name" {
    value = aws_s3_bucket.sri-quickbasket-img-production.id
  description = "sri-quickbasket-img-production-bucket-name value"
}

output "sri-quickbasket-img-production-bucket-regional-domain-name" {
  value       = aws_s3_bucket.sri-quickbasket-img-production.bucket_regional_domain_name
  description = "Regional domain name of the product images bucket"
}