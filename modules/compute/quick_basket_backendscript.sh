#!/bin/bash
# 1. System Updates & Docker Installation
dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# 2. Create the environment file using Terraform variables
mkdir -p /app
cat <<'EOT' > /app/.env
FLASK_ENV=production
PORT=5000
AWS_REGION=${aws_region}
DB_SECRET_NAME=${rds_secret_name}
MAIL_SECRET_NAME=${mail_secret_name}
RDS_HOSTNAME=${db_endpoint}
S3_BUCKET_NAME=${products_img_bucket_name}
CLOUDFRONT_DOMAIN=${products_img_cldfrnt_name}
EOT

# 3. Authenticate with Amazon ECR
# Using Terraform variables to dynamically construct the ECR URL
ECR_URL="${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"

aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin $ECR_URL

# 4. Pull the latest image and run the container
docker pull $ECR_URL/quickbasket-backend:latest

docker run -d \
  --restart always \
  -p 5000:5000 \
  --env-file /app/.env \
  --name quickbasket-api \
  $ECR_URL/quickbasket-backend:latest

  #just temporary
  
  sleep 5m

  docker exec -it quickbasket-api python init_db.py