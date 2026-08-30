#!/bin/bash

# Update packages
sudo dnf update -y

# Install Node.js (v20+ LTS) and Nginx
sudo dnf install -y nodejs nginx

# Install PM2 globally to manage the Next.js process
sudo npm install -g pm2

# Disable default Nginx server on port 80 to prevent conflicts
sudo sed -i 's/listen       80;/listen       8080;/' /etc/nginx/nginx.conf
sudo sed -i 's/listen       \[::\]:80;/listen       \[::\]:8080;/' /etc/nginx/nginx.conf

# Enable Nginx service on boot
sudo systemctl enable nginx

# Create directory and assign permissions correctly
sudo mkdir -p /var/www/quickbasket/frontend
sudo chown -R ec2-user:ec2-user /var/www/quickbasket/frontend

cd /var/www/quickbasket/frontend

git clone --no-checkout --depth 1 --filter=blob:none https://github.com/SrikanthThirumala/AWS-Examples.git

cd AWS-Examples

git sparse-checkout init --no-cone
git sparse-checkout set Frontend/
git checkout main

# Enable dotglob to ensure hidden files (like .env) are moved
shopt -s dotglob
mv Frontend/* /var/www/quickbasket/frontend
shopt -u dotglob

cd /var/www/quickbasket/frontend

truncate -s 0 .env.production
# Explicitly create the production env file for localhost routing via Nginx
cat<<'EOF'> .env.production
NEXT_PUBLIC_API_URL=
EOF

npm install
npm run build

# Start Next.js on default port 3000
pm2 start npm --name "quickbasket-frontend" -- start

# Save PM2 state and configure it to run on server reboot
pm2 save
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Use sudo tee to safely write to /etc/ protected directories
sudo tee /etc/nginx/conf.d/frontend.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    # 1. Route all API traffic to the private Flask backend
    location /api/ {
        proxy_pass http://10.0.5.51;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 2. Route health checks to the private Flask backend
    location /health {
        proxy_pass http://10.0.5.51;
        proxy_set_header Host $host;
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo nginx -t
sudo systemctl restart nginx