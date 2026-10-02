
resource "aws_db_subnet_group" "sri-rds-subnet-group" {
  name = "sri-rds-subnet-group"
  subnet_ids = [ var.DB_private_subnets_ids[0],var.DB_private_subnets_ids[1] ]
  tags = {
    Name="sri-rds-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "sri-rds" {
    identifier = "sri-rds"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    publicly_accessible = false
    manage_master_user_password = true
    username = "admin"
    allocated_storage = 20
    storage_type = "gp2"
    vpc_security_group_ids = [ var.sri_quickbasket_RDS_SG_id ]
    db_subnet_group_name = aws_db_subnet_group.sri-rds-subnet-group.id   

}

resource "aws_db_instance" "sri-rds-replica" {
  identifier = "sri-rds-replica"
  instance_class = "db.t3.micro"
  replicate_source_db = aws_db_instance.sri-rds.identifier
  depends_on = [aws_db_instance.sri-rds]
}

data "aws_secretsmanager_secret" "rds_secret_name" {
  arn = aws_db_instance.sri-rds.master_user_secret[0].secret_arn
  
  }

