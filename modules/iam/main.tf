data "aws_iam_policy_document" "AssumeRole" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
  
}

resource "aws_iam_role" "sri-img-products-role" {
  name = "sri-img-products-role"  
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
  description = "iam role for ec2 to perform CRUD operations on products  s3 bucket for storing images  "

}

resource "aws_iam_instance_profile" "sri-img-products-profile" {
  name = "sri-img-products-profile"
  role = aws_iam_role.sri-img-products-role.name
}

resource "aws_iam_role_policy_attachment" "sri-img-products-role-policy-attachment-1" {
  role = aws_iam_role.sri-img-products-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "sri-img-products-role-policy-attachment-2" {
  role = aws_iam_role.sri-img-products-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"

}

resource "aws_iam_role_policy_attachment" "sri-img-products-role-policy-attachment-3" {
  role = aws_iam_role.sri-img-products-role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"

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