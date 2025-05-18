#!/bin/bash
set -e

# Check for Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create necessary directories
mkdir -p caddy

# Write Caddyfile if not present
if [ ! -f caddy/Caddyfile ]; then
cat <<EOF > caddy/Caddyfile
uptime.dashrdp.com {
    reverse_proxy uptime-kuma:3001
    encode gzip
    tls dashrdp@gmail.com
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "no-referrer-when-downgrade"
    }
}
EOF
fi

# Write docker-compose.yml if not present
if [ ! -f docker-compose.yml ]; then
cat <<EOF > docker-compose.yml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    volumes:
      - uptime-kuma-data:/app/data
    networks:
      - web

  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
      - caddy-config:/config
    networks:
      - web
    depends_on:
      - uptime-kuma

networks:
  web:
    driver: bridge

volumes:
  uptime-kuma-data:
  caddy-data:
  caddy-config:
EOF
fi

# Start the stack
docker-compose up -d

echo "Deployment complete! Access Uptime Kuma at: https://uptime.dashrdp.com"