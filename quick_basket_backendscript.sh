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

cd /var/www/quickbasket/backend
python3 -m venv venv
source venv/bin/activate

pip install flask flask-cors pymysql cryptography boto3 pyjwt gunicorn python-dotenv

# Standard clone to tmp directory
git clone --depth 1 https://github.com/SrikanthThirumala/AWS-Examples.git /tmp/AWS-Examples

# Enable dotglob to ensure hidden files are moved, copy files, and clean up
shopt -s dotglob
cp -r /tmp/AWS-Examples/Backend/* /var/www/quickbasket/backend/
shopt -u dotglob
rm -rf /tmp/AWS-Examples

mysql -h quickbasket-rds.cnmios8g6z81.us-west-2.rds.amazonaws.com -u admin -p'E(gl5v-i[tLdL*eB<5C]uI2YW8U)' < /var/www/quickbasket/backend/db.sql

cd /var/www/quickbasket/backend

truncate -s 0 /var/www/quickbasket/backend/.env

cat<<'EOF'> /var/www/quickbasket/backend/.env
# Server Config
FLASK_ENV=production
PORT=5000

# AWS Config
AWS_REGION=us-west-2
DB_SECRET_NAME=rds!db-411e11df-c300-4bcf-adf5-a3d97e16d3a2

# Email Config (Use a Google App Password, not your standard password)
GMAIL_USER=1srikanthdevops@gmail.com
GMAIL_APP_PASSWORD=djzs kzmw zdpb sjnm

# RDS Networking variables
RDS_HOSTNAME=quickbasket-rds.cnmios8g6z81.us-west-2.rds.amazonaws.com
DB_NAME=quickbasket_db
DB_PORT=3306
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
sudo systemctl restart nginx