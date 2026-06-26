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


apt install -y jq

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id strideflow \
  --region eu-north-1 \
  --query SecretString \
  --output text
)

APP_NAME=$(echo $SECRET_JSON | jq -r '.APP_NAME')
APP_ENV=production
APP_KEY=$(echo $SECRET_JSON | jq -r '.APP_KEY')
APP_DEBUG=false
DB_CONNECTION=mysql
DB_HOST=$(echo $SECRET_JSON | jq -r '.DB_HOST')
DB_DATABASE=$(echo $SECRET_JSON | jq -r '.DB_DATABASE')
DB_USERNAME=$(echo $SECRET_JSON | jq -r '.DB_USERNAME')
DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.DB_PASSWORD')
BACKEND_IMAGE_TAG=$(echo $SECRET_JSON | jq -r '.BACKEND_IMAGE_TAG')
CADDY_IMAGE_TAG=$(echo $SECRET_JSON | jq -r '.CADDY_IMAGE_TAG')
REDIS_HOST=$(echo $SECRET_JSON | jq -r '.REDIS_HOST')
FRONTEND_URL=$(echo $SECRET_JSON | jq -r '.FRONTEND_URL')

# Create application directory
mkdir -p /stride_flow

cat > /stride_flow/docker-compose.yaml << EOF
services:
  backend:
    container_name: stride_flow_backend
    image: 962765735019.dkr.ecr.us-east-1.amazonaws.com/stride_flow_backend_ecr:${BACKEND_IMAGE_TAG}
    restart: unless-stopped
    environment:
      - APP_NAME=${APP_NAME}
      - APP_KEY=${APP_KEY}
      - APP_ENV=${APP_ENV}
      - APP_DEBUG=${APP_DEBUG}
      - DB_CONNECTION=${DB_CONNECTION}
      - DB_HOST=${DB_HOST}
      - DB_DATABASE=${DB_DATABASE}
      - DB_USERNAME=${DB_USERNAME}
      - DB_PASSWORD=${DB_PASSWORD}
      - FRONTEND_URL=${FRONTEND_URL}
      

  caddy:
    container_name: stride_flow_caddy
    image: 962765735019.dkr.ecr.us-east-1.amazonaws.com/stride_flow_caddy_ecr:${CADDY_IMAGE_TAG}
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - caddy_data:/data

  stride_flow_queue:
    container_name: stride_flow_queue
    image: 962765735019.dkr.ecr.us-east-1.amazonaws.com/stride_flow_backend_ecr:${BACKEND_IMAGE_TAG}
    restart: unless-stopped
    environment:
      - APP_NAME=${APP_NAME}
      - APP_KEY=${APP_KEY}
      - APP_ENV=${APP_ENV}
      - APP_DEBUG=${APP_DEBUG}
      - DB_CONNECTION=${DB_CONNECTION}
      - DB_HOST=${DB_HOST}
      - DB_DATABASE=${DB_DATABASE}
      - DB_USERNAME=${DB_USERNAME}
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_CLIENT=predis
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PASSWORD=null
      - REDIS_PORT=6379
      - REDIS_PREFIX=""
    command: php artisan queue:work --verbose --tries=3 --timeout=90

volumes:
  caddy_data:
EOF

cd /stride_flow

docker compose pull
docker compose up -d

