# /workspaces/AWS-Examples/modules/network/output.tf
output "vpc_id" {
  description = "The ID of the newly created VPC"
  value       = aws_vpc.sri_quickbasket_vpc.id
}

output "public_subnet_ids" {
  description = "A list of IDs for all public subnets"
  value       = aws_subnet.sri_quickbasket_public[*].id
}

output "FE_private_subnet_ids" {
  description = "A list of IDs for all frontend private subnets"
  value       = aws_subnet.sri_FE_quickbasket_private[*].id
}

output "BE_private_subnet_ids" {
  description = "A list of IDs for all Backend private subnets"
  value       = aws_subnet.sri_BE_quickbasket_private[*].id
}

output "DB_private_subnet_ids" {
  description = "A list of IDs for all DB private subnets"
  value       = aws_subnet.sri_DB_quickbasket_private[*].id
}

output "FE_subnet_azs" {
  description = "A list of AZ IDs Associated with frontend servers"
  value       = aws_subnet.sri_FE_quickbasket_private[*].availability_zone
}

output "BE_subnet_azs" {
  description = "A list of AZ IDs Associated with Backend servers"
  value       = aws_subnet.sri_BE_quickbasket_private[*].availability_zone
}

