#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

# Print banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║              One-Click Uptime Kuma Installer               ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Check for required software
echo -e "${YELLOW}Checking required software...${NC}"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed.${NC} Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
else
    echo -e "${GREEN}Docker is installed.${NC}"
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed.${NC} Installing Docker Compose..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
else
    echo -e "${GREEN}Docker Compose is installed.${NC}"
fi

# Get user inputs
echo -e "${YELLOW}Please provide the following information:${NC}"

# Get domain name
read -p "Domain name (e.g., monitor.example.com): " DOMAIN
while [[ -z "$DOMAIN" ]]; do
    echo -e "${RED}Domain cannot be empty!${NC}"
    read -p "Domain name (e.g., monitor.example.com): " DOMAIN
done

# Get email for Let's Encrypt
read -p "Email address (for Let's Encrypt notifications): " EMAIL
while [[ -z "$EMAIL" || ! "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
    echo -e "${RED}Please enter a valid email address!${NC}"
    read -p "Email address (for Let's Encrypt notifications): " EMAIL
done

# Update configuration files
echo -e "${YELLOW}Updating configuration files...${NC}"
sed -i "s/{\\$DOMAIN}/$DOMAIN/g" ./caddy/Caddyfile
sed -i "s/{\\$EMAIL}/$EMAIL/g" ./caddy/Caddyfile

# Check DNS configuration
echo -e "${YELLOW}Checking DNS configuration...${NC}"
echo "Attempting to resolve $DOMAIN..."
if host "$DOMAIN" &> /dev/null; then
    echo -e "${GREEN}DNS lookup successful. Domain is correctly configured.${NC}"
else
    echo -e "${RED}DNS lookup failed. Please ensure your domain ($DOMAIN) is pointed to this server's IP address.${NC}"
    read -p "Continue anyway? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
        echo "Installation aborted."
        exit 1
    fi
fi

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p ./logs

# Start the services
echo -e "${YELLOW}Starting services...${NC}"
docker-compose up -d

# Check if services are running
echo -e "${YELLOW}Checking if services are running...${NC}"
sleep 5

if docker ps | grep -q "uptime-kuma"; then
    echo -e "${GREEN}Uptime Kuma is running.${NC}"
else
    echo -e "${RED}Uptime Kuma failed to start. Please check the logs.${NC}"
    docker-compose logs uptime-kuma
fi

if docker ps | grep -q "caddy"; then
    echo -e "${GREEN}Caddy is running.${NC}"
else
    echo -e "${RED}Caddy failed to start. Please check the logs.${NC}"
    docker-compose logs caddy
fi

# Print success message
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    Installation Complete                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Your Uptime Kuma instance is now available at: https://$DOMAIN"
echo ""
echo "To view logs:"
echo "  Uptime Kuma: docker-compose logs uptime-kuma"
echo "  Caddy: docker-compose logs caddy"
echo ""
echo "To stop the services: docker-compose down"
echo "To restart the services: docker-compose restart"
echo ""
echo "Thank you for using this installer!" 