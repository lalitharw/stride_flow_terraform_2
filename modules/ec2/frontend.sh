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

sudo usermod -aG docker ubuntu


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


apt install -y jq

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id strideflow \
  --region eu-north-1 \
  --query SecretString \
  --output text
)

FRONTEND_IMAGE_TAG=$(echo $SECRET_JSON | jq -r '.FRONTEND_IMAGE_TAG')

# Create application directory
mkdir -p /stride_flow

cat > /stride_flow/docker-compose.yaml << EOF
services:
  frontend:
    container_name: stride_flow_frontend
    image: 962765735019.dkr.ecr.us-east-1.amazonaws.com/stride_flow_frontend_ecr:${FRONTEND_IMAGE_TAG}
    restart: unless-stopped
EOF

cd /stride_flow

docker compose pull
docker compose up -d

