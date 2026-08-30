# /workspaces/AWS-Examples/modules/compute/main.tf

resource "aws_security_group" "sri_quickbasket_Frontend_EC2_SG" {
  vpc_id = var.vpc_id # Uses the variable passed from root
  name   = "sri_quickbasket_Frontend_EC2_SG_${var.config.environment}"
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "Allow"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "allow all outbound traffic"
  }
}


resource "aws_security_group" "sri_quickbasket_Backend_EC2_SG" {
  vpc_id = var.vpc_id # Uses the variable passed from root
  name   = "sri_quickbasket_Backend_EC2_SG_${var.config.environment}"
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "Allow"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "allow all outbound traffic"
  }
}


resource "aws_security_group" "sri_quickbasket_RDS_SG" {
  vpc_id = var.vpc_id # Uses the variable passed from root
  name   = "sri_quickbasket_RDS_SG_${var.config.environment}"
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "Allow"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "allow all outbound traffic"
  }
}


resource "aws_security_group" "sri_Frontend_ALB_SG" {
  vpc_id = var.vpc_id # Uses the variable passed from root
  name   = "sri_Frontend_ALB_SG_${var.config.environment}"
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "Allow"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "allow all outbound traffic"
  }
}

resource "aws_security_group" "sri_Backend_ALB_SG" {
  vpc_id = var.vpc_id # Uses the variable passed from root
  name   = "sri_Backend_ALB_SG_${var.config.environment}"
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "Allow"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "allow all outbound traffic"
  }
}


resource "aws_instance" "sri_quickbasket_front_end_server" {
  ami                    = var.config.ami
  instance_type          = var.config.instance_type
  subnet_id              = var.FE_subnet_ids[0] # Deploys into the first FE subnet
  vpc_security_group_ids = [aws_security_group.sri_quickbasket_Frontend_EC2_SG.id]
  availability_zone = var.FE_subnet_azs[0]
  # Ensure the IAM role and userdata script actually exist in your environment
  iam_instance_profile = "sri-custom-role" 
   user_data_base64     = filebase64("quick_basket_frontendscript.sh")
   private_ip = "10.0.3.100"
  
  tags = {
    Name = "sri_quickbasket_Frontend_server_${var.config.environment}"
  }
}

resource "aws_instance" "sri_quickbasket_back_end_server" {
  ami                    = var.config.ami
  instance_type          = var.config.instance_type
  subnet_id              = var.BE_subnet_ids[0] # Deploys into the first BE subnet
  vpc_security_group_ids = [aws_security_group.sri_quickbasket_Backend_EC2_SG.id]
  availability_zone = var.BE_subnet_azs[0]
  # Ensure the IAM role and userdata script actually exist in your environment
   iam_instance_profile = "sri-custom-role" 
  user_data_base64     = filebase64("quick_basket_backendscript.sh")
  private_ip = "10.0.5.99"
  tags = {
    Name = "sri_quickbasket_Backend_server_${var.config.environment}"
  }
}