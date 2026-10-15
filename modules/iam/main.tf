data "aws_iam_policy_document" "AssumeRole" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
  
}


#iam role for backend server
resource "aws_iam_role" "sri-img-products-role" {
  name = "sri-img-products-role"  
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
  description = "iam role for ec2 to perform CRUD operations on products  s3 bucket for storing images  "

}

data "aws_iam_policy" "secrets_policy" {
  name = "quickbasket-secrets-access-policy"
}

resource "aws_iam_role_policy_attachment" "sri-img-products-email-secrets-attach" {
  role       = aws_iam_role.sri-img-products-role.name
  policy_arn = data.aws_iam_policy.secrets_policy.arn
}


data "aws_iam_policy_document" "rds-secret-inline-policy" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    
    # RDS manages the password automatically: this value is for ec2 inturn to provide it to db.py to init the connection 
    resources = [var.sri_rds_secret_arn]
    
   
  }
}

resource "aws_iam_role_policy" "sri-rds-secret-custom-policy" {
  name   = "sri-rds-secret-custom-policy"
  role   = aws_iam_role.sri-img-products-role.id
  policy = data.aws_iam_policy_document.rds-secret-inline-policy.json
}

resource "aws_iam_instance_profile" "sri-img-products-profile" {
  name = "sri-img-products-profile"
  role = aws_iam_role.sri-img-products-role.name
}

resource "aws_iam_role_policy_attachment" "sri-img-products-role-policy-attachment-ssm" {
  role = aws_iam_role.sri-img-products-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "sri-img-products-role-policy-attachment-2" {
  role = aws_iam_role.sri-img-products-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"

}



data "aws_iam_policy_document" "img-bucket-inline-policy" {
  statement {
    actions = [ "s3:PutObject","s3:GetObject","s3:DeleteObject" ]
    resources = [ "arn:aws:s3:::sri-quickbasket-img-production/*" ]
    
  }
  statement {
    actions = [ "s3:ListBucket" ]
    resources = [ "arn:aws:s3:::sri-quickbasket-img-production" ]
  }
}

resource "aws_iam_role_policy" "sri-img-bucket-custom-policy" {
  name = "sri-img-bucket-custom-policy"
  role = aws_iam_role.sri-img-products-role.id
  policy = data.aws_iam_policy_document.img-bucket-inline-policy.json
}


data "aws_iam_policy_document" "loki-logs-bucket-inline-policy" {
  statement {
    actions = [ "s3:PutObject","s3:GetObject","s3:DeleteObject" ]
    resources = [ "arn:aws:s3:::sri-quickbasket-loki-logs-production/*" ]
    
  }
  statement {
    actions = [ "s3:ListBucket" ]
    resources = [ "arn:aws:s3:::sri-quickbasket-loki-logs-production" ]
  }
}

resource "aws_iam_role" "sri-loki-logs-role" {
  name = "sri-loki-logs-role"  
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
  description = "iam role for ec2 to perform CRUD operations on loki-logs  s3 bucket for storing logs"

}

resource "aws_iam_instance_profile" "sri-loki-logs-profile" {
  name = "sri-loki-logs-profile"
  role = aws_iam_role.sri-loki-logs-role.name
}

resource "aws_iam_role_policy" "sri-loki-logs-bucket-custom-policy" {
  name = "sri-loki-logs-bucket-custom-policy"
  role = aws_iam_role.sri-loki-logs-role.id
  policy = data.aws_iam_policy_document.loki-logs-bucket-inline-policy.json
}


#IAM Policy for Frontend 


resource "aws_iam_role" "sri-frontend-role" {
  name = "sri-frontend-role"  
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
  description = "iam role for frontend ec2 to ssh into server"

}

resource "aws_iam_instance_profile" "sri-frontend-iam-profile" {
  name = "sri-frontend-iam-profile"
  role = aws_iam_role.sri-frontend-role.name
}

resource "aws_iam_role_policy_attachment" "sri-frontend-role-policy-attachment" {
  role = aws_iam_role.sri-frontend-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


#Iam policy to get mail secrets


