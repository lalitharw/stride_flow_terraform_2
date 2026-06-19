#!/bin/bash

set -e

sudo apt update -y
sudo apt upgrade -y

sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker ubuntu

# make folder and write docker compose yaml

mkdir stride_flow && cd stride_flow

cat > docker-compose.yaml << 'EOF'
services:
    backend:
        container_name: stride_flow_backend
        image: 
        restart: unless-stopped
        ports:
            - "8080:8080"
        
    caddy:
        container_name: stride_flow_caddy
        image:
        restart: unless-stopped
        ports:
            - "80:80"
        

EOF
