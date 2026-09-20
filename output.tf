# /workspaces/AWS-Examples/output.tf

output "vpc_id" {
  description = "The ID of the newly created VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "A list of IDs for all public subnets"
  value       = module.network.public_subnet_ids
}

output "FE_private_subnet_ids" {
  description = "A list of IDs for all frontend private subnets"
  value       = module.network.FE_private_subnet_ids
}

output "BE_private_subnet_ids" {
  description = "A list of IDs for all Backend private subnets"
  value       = module.network.BE_private_subnet_ids
}

output "DB_private_subnet_ids" {
  description = "A list of IDs for all DB private subnets"
  value       = module.network.DB_private_subnet_ids
}

output "sri_Rds_endpoint" {
  value = module.database.sri_Rds_endpoint
  description = "sri_Rds_endpoint value"
}

output "frontendserver-id" {
  value = module.compute.frontendserver-id
}


output "backendserver-id" {
  value = module.compute.backendserver-id

}

output "cloudfront-quickbasket_img_fetch_cloudfront_domain_name" {
  value = module.cloudfront.quickbasket_img_fetch_cloudfront_domain_name
}

output "sri-quickbasket-img-production-bucket-name" {
  value = module.storage.sri-quickbasket-img-production-bucket-name
}