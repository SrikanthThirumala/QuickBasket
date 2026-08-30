#!/bin/bash

# 1. Update and install system dependencies
yum update -y
yum install -y mariadb105 nodejs python3-pip amazon-cloudwatch-agent git
npm install -g pm2

# # 2. Go to /root and set up CloudWatch Agent
# cd /root
# mkdir sri-cloud-json
# cd /root/sri-cloud-json

# cat<<'EOF'>/root/sri-cloud-json/amazon-cloudwatch-agent-cloud-init.json
# {
#   "logs": {
#     "logs_collected": {
#       "files": {
#         "collect_list": [
#           {
#             "file_path": "/var/log/cloud-init-output.log",
#             "log_group_name": "cloud-init-output-logs",
#             "log_stream_name": "{instance_id}-all-logs"
#           }
#         ]
#       }
#     }
#   }
# }
# EOF

# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/root/sri-cloud-json/amazon-cloudwatch-agent-cloud-init.json

# --- CRITICAL FIX: Return to /root before cloning ---
cd /root

# 3. Clone the repository
git clone --no-checkout --depth 1 https://github.com/SrikanthThirumala/Aws-Fullstack-3-Tier-Python-Projects.git

# 4. Enter the newly cloned repository folder
cd Aws-Fullstack-3-Tier-Python-Projects

# 5. Configure sparse-checkout and pull the files
git sparse-checkout init --cone
git sparse-checkout set 3-tier-Python-project-with-secret-manager/Back-end-api
git checkout main

# 6. Create the requirements.txt file 
cat <<'EOF' > /root/Aws-Fullstack-3-Tier-Python-Projects/3-tier-Python-project-with-secret-manager/Back-end-api/requirements.txt
Flask
Requests
Boto3
pymysql
EOF

# 7. Install Python dependencies
pip3 install -r /root/Aws-Fullstack-3-Tier-Python-Projects/3-tier-Python-project-with-secret-manager/Back-end-api/requirements.txt

# 8. Create SQL file
cat<<'EOF'> /root/Aws-Fullstack-3-Tier-Python-Projects/3-tier-Python-project-with-secret-manager/Back-end-api/test.sql
Create Database testsridb;
use testsridb;
CREATE TABLE IF NOT EXISTS items ( id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(255) NOT NULL,email VARCHAR(255) NOT NULL,country VARCHAR(100) NOT NULL );
EOF

# replace second part 


mysql -h sri-netf-rds.c3kc0282gen0.us-west-2.rds.amazonaws.com -u admin -p'h$*[HfO>G1dZx7GU[|fnNfZ36seO'<test.sql

sed -i 's/sri-rds-main.c10c4oay0c39.us-west-2.rds.amazonaws.com/sri-netf-rds.c3kc0282gen0.us-west-2.rds.amazonaws.com'/  /root/Aws-Fullstack-3-Tier-Python-Projects/3-tier-Python-project-with-secret-manager/Back-end-api/main.py

sed -i 's/rds!db-146a62f0-5b44-4baa-b67c-4d5eb94ab11d/rds!db-59ded51a-3fc0-497b-ae8e-d60d372c4734'/  /root/Aws-Fullstack-3-Tier-Python-Projects/3-tier-Python-project-with-secret-manager/Back-end-api/main.py

pm2 start /root/Aws-Fullstack-3-Tier-Python-Projects/3-tier-Python-project-with-secret-manager/Back-end-api/main.py --interpreter python3 --name "Flash-Backend"