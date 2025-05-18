#!/bin/bash
set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Generate new secret keys
SECRET_KEY=$(openssl rand -hex 32)
UTILS_SECRET=$(openssl rand -hex 32)

# Replace placeholder keys in docker.env
sed -i "s/replace_with_a_generated_secret_key/$SECRET_KEY/" docker.env
sed -i "s/replace_with_a_generated_utils_secret/$UTILS_SECRET/" docker.env

echo "Generated new secret keys and updated docker.env"
echo ""
echo "Please update the following settings in docker.env before starting Outline:"
echo "1. Database password (POSTGRES_PASSWORD)"
echo "2. URL (set to your domain in production)"
echo "3. Slack authentication details"
echo "4. SMTP server configuration"
echo ""
echo "After updating the configuration, start Outline with:"
echo "docker-compose up -d"
echo ""
echo "Once the services are running, initialize the database with:"
echo "docker-compose exec outline yarn db:migrate"
echo ""
echo "Then access Outline at http://localhost:3000 or your configured domain." 