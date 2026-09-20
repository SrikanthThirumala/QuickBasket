# /workspaces/AWS-Examples/modules/compute/output.tf
output "sri_quickbasket_RDS_SG_id" {
  value = aws_security_group.sri_quickbasket_RDS_SG.id
}

output "frontendserver-id" {
  value = aws_instance.sri_quickbasket_front_end_server.id
}


output "backendserver-id" {
  value = aws_instance.sri_quickbasket_back_end_server.id
}