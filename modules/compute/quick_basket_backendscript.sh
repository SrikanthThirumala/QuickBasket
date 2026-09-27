#!/bin/bash 

sudo dnf update -y
sudo dnf install -y python3 python3-pip python3-devel nginx mariadb105 git
sudo systemctl enable nginx

# Disable default Nginx server on port 80 to prevent conflicts
sudo sed -i 's/listen       80;/listen       8080;/' /etc/nginx/nginx.conf
sudo sed -i 's/listen       \[::\]:80;/listen       \[::\]:8080;/' /etc/nginx/nginx.conf

# Create directory and assign permissions using sudo
sudo mkdir -p /var/www/quickbasket/backend
sudo chown -R ec2-user:ec2-user /var/www/quickbasket/backend

# Create separated log directories and files
sudo mkdir -p /var/log/quickbasket/backend
sudo mkdir -p /var/log/quickbasket/frontend
sudo touch /var/log/quickbasket/backend/access.log /var/log/quickbasket/backend/error.log
sudo touch /var/log/quickbasket/frontend/access.log /var/log/quickbasket/frontend/error.log

# Enforce application permissions on all logs
sudo chown -R ec2-user:ec2-user /var/log/quickbasket

cd /var/www/quickbasket/backend
python3 -m venv venv
source venv/bin/activate

pip install flask flask-cors pymysql cryptography boto3 pyjwt gunicorn python-dotenv

# Standard clone to tmp directory
git clone --depth 1 https://github.com/SrikanthThirumala/QuickBasket.git /tmp/QuickBasket

# Enable dotglob to ensure hidden files are moved, copy files, and clean up
shopt -s dotglob
cp -r /tmp/QuickBasket/Backend/* /var/www/quickbasket/backend/
shopt -u dotglob
rm -rf /tmp/QuickBasket

mysql -h ${db_endpoint} -u admin -p'0G>11J|LIYHy$9m_?7Dzxz$td68|' < /var/www/quickbasket/backend/db.sql

cd /var/www/quickbasket/backend

truncate -s 0 /var/www/quickbasket/backend/.env

cat<<'EOF'> /var/www/quickbasket/backend/.env
# Server Config
FLASK_ENV=production
PORT=5000

# AWS Config
AWS_REGION=us-west-2
DB_SECRET_NAME=${rds_secret_name}

# Email Config (Use a Google App Password, not your standard password)
MAIL_USERNAME=sanjayreddy5866@gmail.com
MAIL_PASSWORD=


# RDS Networking variables
RDS_HOSTNAME=${db_endpoint}
DB_NAME=quickbasket_db
DB_PORT=3306


#also create sri-quickbasket-loki-logs-production bucket to access logs

S3_BUCKET_NAME=${products_img_bucket_name}
CLOUDFRONT_DOMAIN=${products_img_cldfrnt_name}
EOF

# Use sudo tee to safely write to /etc/ protected directories
sudo tee /etc/systemd/system/quickbasket-backend.service > /dev/null <<'EOF'
[Unit]
Description=Gunicorn instance to serve QuickBasket API
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/var/www/quickbasket/backend
Environment="PATH=/var/www/quickbasket/backend/venv/bin"
EnvironmentFile=/var/www/quickbasket/backend/.env
ExecStart=/var/www/quickbasket/backend/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start quickbasket-backend
sudo systemctl enable quickbasket-backend

# Use sudo tee to safely write to /etc/ protected directories
sudo tee /etc/nginx/conf.d/backend.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

sudo nginx -t

# Description: Installs Promtail to ship logs to the Internal ALB.
# Note: Update the INTERNAL_ALB_URL variable if your Load Balancer changes.

# INTERNAL_ALB_URL="http://internal-quickbasket-loki-monitr-prod-ALB-389242717.us-west-2.elb.amazonaws.com:80/loki/api/v1/push"

# echo "Installing Promtail..."
# cd /tmp
# wget https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip
# sudo dnf install -y unzip
# unzip promtail-linux-amd64.zip
# sudo mv promtail-linux-amd64 /usr/local/bin/promtail
# sudo chmod a+x /usr/local/bin/promtail
# rm promtail-linux-amd64.zip

# echo "Configuring Promtail..."
# sudo mkdir -p /etc/promtail
# sudo tee /etc/promtail/promtail-config.yaml > /dev/null <<EOF
# server:
#   http_listen_port: 9080
#   grpc_listen_port: 0

# positions:
#   filename: /tmp/positions.yaml

# remove one $ infront of internal_alb_url 

# clients:
#   - url: $${INTERNAL_ALB_URL} 

# scrape_configs:
#   - job_name: quickbasket-backend
#     static_configs:
#     - targets:
#         - localhost
#       labels:
#         job: backend
#         env: production
#         __path__: /var/log/quickbasket/backend/*.log

#   - job_name: quickbasket-frontend
#     static_configs:
#     - targets:
#         - localhost
#       labels:
#         job: frontend
#         env: production
#         __path__: /var/log/quickbasket/frontend/*.log
# EOF

# echo "Creating Promtail systemd service..."
# sudo tee /etc/systemd/system/promtail.service > /dev/null <<'EOF'
# [Unit]
# Description=Promtail log shipper
# After=network.target

# [Service]
# Type=simple
# User=root
# ExecStart=/usr/local/bin/promtail -config.file /etc/promtail/promtail-config.yaml
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target
# EOF

# sudo systemctl daemon-reload
# sudo systemctl enable --now promtail

# echo "Promtail installation complete. Logs are shipping to the Internal ALB."

sudo systemctl restart nginx

# sudo systemctl status nginx
# sudo journalctl -u quickbasket-backend -n 50 --no-pager
# sudo systemctl restart quickbasket-backend