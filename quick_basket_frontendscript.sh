#!/bin/bash

# 1. Allocate Swap Space to prevent Next.js Out-of-Memory (OOM) crashes
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 2. Update packages and install dependencies
sudo dnf update -y
sudo dnf install -y nodejs nginx git
sudo npm install -g pm2

# 3. Disable default Nginx server on port 80
sudo sed -i 's/listen       80;/listen       8080;/' /etc/nginx/nginx.conf
sudo sed -i 's/listen       \[::\]:80;/listen       \[::\]:8080;/' /etc/nginx/nginx.conf
sudo systemctl enable nginx

# 4. Create directory structure
sudo mkdir -p /var/www/quickbasket/frontend

# 5. Clone and transfer files
git clone --depth 1 https://github.com/SrikanthThirumala/AWS-Examples.git /tmp/AWS-Examples
shopt -s dotglob
sudo cp -r /tmp/AWS-Examples/Frontend/* /var/www/quickbasket/frontend/
shopt -u dotglob
sudo rm -rf /tmp/AWS-Examples

cd /var/www/quickbasket/frontend

# 6. Generate Environment File
sudo truncate -s 0 .env.production
sudo tee .env.production > /dev/null <<'EOF'
NEXT_PUBLIC_API_URL=
EOF

# 7. CRITICAL: Fix all permissions BEFORE installing or building
sudo chown -R ec2-user:ec2-user /var/www/quickbasket/frontend

# 8. Execute Node tasks explicitly as the ec2-user
sudo -u ec2-user npm install
sudo -u ec2-user npm run build

# 9. Start PM2 explicitly as the ec2-user
sudo -u ec2-user pm2 start npm --name "quickbasket-frontend" -- start
sudo -u ec2-user pm2 save

# 10. Configure PM2 to start on boot for the ec2-user
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# 11. Configure Nginx Reverse Proxy
sudo tee /etc/nginx/conf.d/frontend.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location /api/ {
        proxy_pass http://10.0.5.99;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health {
        proxy_pass http://10.0.5.99;
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

# 12. Restart Nginx to apply changes
sudo nginx -t
sudo systemctl restart nginx