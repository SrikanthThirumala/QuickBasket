output "sri_Rds_endpoint" {
  value = aws_db_instance.sri-rds.address
  description = "rds endpoint value to send it for backend script in compute module "
}

output "sri_rds_secret_name" {
  value = data.aws_secretsmanager_secret.rds_secret_name.name
  description = "secret name value to send it for backend script in compute module "
}