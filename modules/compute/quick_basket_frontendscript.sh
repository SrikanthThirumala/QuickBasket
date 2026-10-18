#!/bin/bash
# 1. Update and install Docker & Git
dnf update -y
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

# 2. Prepare app directory
mkdir -p /app



cat <<'EOT' > /app/.env.production
# Add any environment variables your Next.js app needs here
NEXT_PUBLIC_API_URL=http://${backend_alb_dns}
EOT


# Using Terraform variables to dynamically construct the ECR URL
ECR_URL="${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"

aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin $ECR_URL

docker pull $ECR_URL/quickbasket-frontend:latest

docker run -d \
  --restart always \
  -p 3000:3000 \
  --env-file /app/.env.production \
  --name quickbasket-web \
  $ECR_URL/quickbasket-frontend:latest