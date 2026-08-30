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