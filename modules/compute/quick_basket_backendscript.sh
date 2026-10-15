#!/bin/bash
# 1. Update and install Docker if not present
dnf update -y
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

# #  Prepare app directory ---->update this code when we build pipeline to build docker using pipeline 
# mkdir -p /app/backend
# cd /app/backend

mkdir -p /app
cd /app

git clone --depth 1 https://github.com/SrikanthThirumala/QuickBasket.git
shopt -s dotglob
shopt -u dotglob

cd QuickBasket/Backend


# 3. Write out the dynamic .env file
cat <<'EOT' > .env
# Server Config
FLASK_ENV=production
PORT=5000

# AWS Config
AWS_REGION=${aws_region}
DB_SECRET_NAME=${rds_secret_name}
MAIL_SECRET_NAME=${mail_secret_name}



# RDS Networking variables
RDS_HOSTNAME=${db_endpoint}
DB_NAME=quickbasket_db
DB_PORT=3306

# Storage & CDN
S3_BUCKET_NAME=${products_img_bucket_name}
CLOUDFRONT_DOMAIN=${products_img_cldfrnt_name}
EOT

docker build -t quickbasket-backend:latest .

# 4. Launch the container
docker run -d \
  --restart always \
  -p 5000:5000 \
  --env-file .env \
  --name quickbasket-api \
  quickbasket-backend:latest