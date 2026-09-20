#!/bin/bash
# Description: Installs Grafana and an S3-backed Loki database.
# Prerequisite: Attach an IAM Role with S3 permissions to the EC2 instance before running.

echo "Installing Grafana..."
cd /tmp
wget https://dl.grafana.com/oss/release/grafana-11.1.0-1.x86_64.rpm
sudo dnf install -y grafana-11.1.0-1.x86_64.rpm
sudo systemctl enable --now grafana-server
rm grafana-11.1.0-1.x86_64.rpm

echo "Installing Loki..."
wget https://github.com/grafana/loki/releases/download/v2.9.4/loki-linux-amd64.zip
sudo dnf install -y unzip
unzip loki-linux-amd64.zip
sudo mv loki-linux-amd64 /usr/local/bin/loki
sudo chmod a+x /usr/local/bin/loki
rm loki-linux-amd64.zip

echo "Configuring Loki for S3 storage..."
sudo mkdir -p /etc/loki
sudo tee /etc/loki/loki-config.yaml > /dev/null <<'EOF'
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /tmp/loki
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

storage_config:
  aws:
    bucketnames: sri-quickbasket-loki-logs-production
    region: us-west-2
  boltdb_shipper:
    active_index_directory: /tmp/loki/boltdb-shipper-active
    cache_location: /tmp/loki/boltdb-shipper-cache
    cache_ttl: 24h
    shared_store: s3

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: s3
      schema: v11
      index:
        prefix: index_
        period: 24h
EOF

echo "Creating Loki systemd service..."
sudo tee /etc/systemd/system/loki.service > /dev/null <<'EOF'
[Unit]
Description=Loki log database
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/loki -config.file /etc/loki/loki-config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now loki

echo "Installation complete. Grafana is on port 3000, Loki is on port 3100."