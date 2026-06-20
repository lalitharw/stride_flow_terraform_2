#!/bin/bash

set -e

# Update packages
apt update -y

# Install dependencies
apt install -y \
    ca-certificates \
    curl \
    unzip

# Docker repository
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y

# Install Docker
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

# Login to ECR
aws ecr get-login-password --region us-east-1 \
| docker login \
    --username AWS \
    --password-stdin 962765735019.dkr.ecr.us-east-1.amazonaws.com

# Create application directory
mkdir -p /stride_flow

cat > /stride_flow/docker-compose.yaml << 'EOF'
services:
  backend:
    container_name: stride_flow_backend
    image: 962765735019.dkr.ecr.us-east-1.amazonaws.com/stride_flow_backend_ecr:1f59d6a9a4bbb0256cbb80ad13f26c7a3f81136a
    restart: unless-stopped

  caddy:
    container_name: stride_flow_caddy
    image: 962765735019.dkr.ecr.us-east-1.amazonaws.com/stride_flow_caddy_ecr:1f59d6a9a4bbb0256cbb80ad13f26c7a3f81136a
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - caddy_data:/data

volumes:
  caddy_data:
EOF

cd /stride_flow

docker compose pull
docker compose up -d