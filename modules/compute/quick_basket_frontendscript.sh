#!/bin/bash
# 1. Update and install Docker & Git
dnf update -y
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

# 2. Prepare app directory
mkdir -p /app
cd /app

# 3. Clone the code efficiently
git clone --depth 1 https://github.com/SrikanthThirumala/QuickBasket.git

# Navigate into the frontend folder (Ensure casing matches your repo: frontend or Frontend)
cd QuickBasket/Frontend 

# 4. Write out the dynamic .env.production file for Next.js
cat <<'EOT' > .env.production
# Add any environment variables your Next.js app needs here
NEXT_PUBLIC_API_URL=http://${backend_alb_dns}
EOT

# 5. Build the Docker image locally (This uses the .env.production we just created)
docker build -t quickbasket-frontend:latest .

# 6. Launch the frontend container (Next.js typically runs on port 3000)
docker run -d \
  --restart always \
  -p 3000:3000 \
  --env-file .env.production \
  --name quickbasket-web \
  quickbasket-frontend:latest