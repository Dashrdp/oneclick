#!/bin/bash
set -e

# Color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN}            N8N Configuration Setup Script                        ${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e "${YELLOW}This script will help you configure your N8N installation.${NC}"
echo ""

# Create necessary directories
mkdir -p local-files
mkdir -p backups

# Domain configuration
configure_ssl() {
    echo -e "${BLUE}Domain and SSL Configuration:${NC}"
    read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
    read -p "Enter subdomain for N8N (e.g., n8n): " SUBDOMAIN
    read -p "Enter your email address (for SSL certificates): " SSL_EMAIL

    cat > ssl.env << EOF
# SSL Configuration

# Domain Settings
DOMAIN_NAME=${DOMAIN_NAME}
SUBDOMAIN=${SUBDOMAIN}

# SSL Email (used for Let's Encrypt certificates)
SSL_EMAIL=${SSL_EMAIL}
EOF

    echo -e "${GREEN}SSL configuration saved to ssl.env${NC}"
}

# N8N configuration
configure_n8n() {
    echo -e "${BLUE}N8N Configuration:${NC}"
    read -p "Enter your timezone (default: America/New_York): " TIMEZONE
    TIMEZONE=${TIMEZONE:-America/New_York}

    # Authentication
    read -p "Do you want to enable user authentication? (y/n): " ENABLE_AUTH
    
    if [[ "$ENABLE_AUTH" =~ ^[Yy]$ ]]; then
        read -p "Enter admin username (default: admin): " N8N_ADMIN_USER
        N8N_ADMIN_USER=${N8N_ADMIN_USER:-admin}
        
        read -s -p "Enter admin password: " N8N_ADMIN_PASSWORD
        echo ""
        
        # Generate a random encryption key
        N8N_ENCRYPTION_KEY=$(openssl rand -base64 24)
        AUTH_SETTINGS="# Authentication 
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=${N8N_ADMIN_USER}
N8N_BASIC_AUTH_PASSWORD=${N8N_ADMIN_PASSWORD}
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}"
    else
        AUTH_SETTINGS="# Authentication (uncomment to enable)
#N8N_BASIC_AUTH_ACTIVE=true
#N8N_BASIC_AUTH_USER=admin
#N8N_BASIC_AUTH_PASSWORD=securepassword
#N8N_ENCRYPTION_KEY=generatedsecretkey"
    fi

    cat > n8n.env << EOF
# N8N Configuration

# Application Settings
N8N_HOST=\${SUBDOMAIN}.\${DOMAIN_NAME}
N8N_PORT=5678
N8N_PROTOCOL=https
NODE_ENV=production
WEBHOOK_URL=https://\${SUBDOMAIN}.\${DOMAIN_NAME}/

# Timezone
GENERIC_TIMEZONE=${TIMEZONE}

${AUTH_SETTINGS}
EOF

    echo -e "${GREEN}N8N configuration saved to n8n.env${NC}"
}

# Database configuration
configure_database() {
    echo -e "${BLUE}Database Configuration:${NC}"
    echo "1. SQLite (default, easier setup)"
    echo "2. PostgreSQL (recommended for production)"
    read -p "Select database type [1-2]: " DB_CHOICE
    
    if [ "$DB_CHOICE" = "2" ]; then
        read -p "PostgreSQL database name (default: n8n): " DB_POSTGRESDB_DATABASE
        DB_POSTGRESDB_DATABASE=${DB_POSTGRESDB_DATABASE:-n8n}
        
        read -p "PostgreSQL user (default: n8n): " DB_POSTGRESDB_USER
        DB_POSTGRESDB_USER=${DB_POSTGRESDB_USER:-n8n}
        
        read -s -p "PostgreSQL password: " DB_POSTGRESDB_PASSWORD
        echo ""
        
        read -p "PostgreSQL schema (default: public): " DB_POSTGRESDB_SCHEMA
        DB_POSTGRESDB_SCHEMA=${DB_POSTGRESDB_SCHEMA:-public}
        
        cat > db.env << EOF
# Database Configuration

# Database Type: sqlite or postgresdb
DB_TYPE=postgresdb

# PostgreSQL Configuration
DB_POSTGRESDB_DATABASE=${DB_POSTGRESDB_DATABASE}
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=${DB_POSTGRESDB_USER}
DB_POSTGRESDB_PASSWORD=${DB_POSTGRESDB_PASSWORD}
DB_POSTGRESDB_SCHEMA=${DB_POSTGRESDB_SCHEMA}

# PostgreSQL Admin Credentials (for initial setup)
POSTGRES_DB=${DB_POSTGRESDB_DATABASE}
POSTGRES_USER=${DB_POSTGRESDB_USER}
POSTGRES_PASSWORD=${DB_POSTGRESDB_PASSWORD}
EOF

        # Uncomment PostgreSQL section in docker-compose.yml
        sed -i 's/# Uncomment for PostgreSQL/# PostgreSQL enabled/g' docker-compose.yml
        sed -i 's/# - postgres/- postgres/g' docker-compose.yml
        sed -i 's/# PostgreSQL Database (uncomment to use)/# PostgreSQL Database/g' docker-compose.yml
        sed -i 's/#   image: postgres:13/  postgres:\n    image: postgres:13/g' docker-compose.yml
        sed -i 's/#   restart: always/    restart: always/g' docker-compose.yml
        sed -i 's/#   env_file:/    env_file:/g' docker-compose.yml
        sed -i 's/#     - db.env/      - db.env/g' docker-compose.yml
        sed -i 's/#   environment:/    environment:/g' docker-compose.yml
        sed -i 's/#     - POSTGRES_DB=\${DB_POSTGRESDB_DATABASE}/      - POSTGRES_DB=\${DB_POSTGRESDB_DATABASE}/g' docker-compose.yml
        sed -i 's/#     - POSTGRES_USER=\${DB_POSTGRESDB_USER}/      - POSTGRES_USER=\${DB_POSTGRESDB_USER}/g' docker-compose.yml
        sed -i 's/#     - POSTGRES_PASSWORD=\${DB_POSTGRESDB_PASSWORD}/      - POSTGRES_PASSWORD=\${DB_POSTGRESDB_PASSWORD}/g' docker-compose.yml
        sed -i 's/#   volumes:/    volumes:/g' docker-compose.yml
        sed -i 's/#     - .\/postgres_data:\/var\/lib\/postgresql\/data/      - .\/postgres_data:\/var\/lib\/postgresql\/data/g' docker-compose.yml
        sed -i 's/#   networks:/    networks:/g' docker-compose.yml
        sed -i 's/#     - n8n-network/      - n8n-network/g' docker-compose.yml
        
        mkdir -p postgres_data
    else
        cat > db.env << EOF
# Database Configuration

# Database Type: sqlite or postgresdb
DB_TYPE=sqlite

# PostgreSQL Configuration (only used if DB_TYPE=postgresdb)
# ----------------------------------------------------------
# Uncomment and configure if using PostgreSQL
#DB_POSTGRESDB_DATABASE=n8n
#DB_POSTGRESDB_HOST=postgres
#DB_POSTGRESDB_PORT=5432
#DB_POSTGRESDB_USER=n8n
#DB_POSTGRESDB_PASSWORD=securepassword
#DB_POSTGRESDB_SCHEMA=public

# PostgreSQL Admin Credentials (for initial setup)
# ------------------------------------------------
#POSTGRES_DB=n8n
#POSTGRES_USER=n8n
#POSTGRES_PASSWORD=securepassword
EOF
    fi

    echo -e "${GREEN}Database configuration saved to db.env${NC}"
}

# Create backup script
create_backup_script() {
    cat > backup.sh << 'EOF'
#!/bin/bash
# N8N Backup Script

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backups/${DATE}"

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Back up the Docker volumes
echo "Backing up n8n data..."
docker run --rm -v n8n_data:/source -v $(pwd)/${BACKUP_DIR}:/backup alpine tar -czf /backup/n8n_data.tar.gz -C /source ./

# Back up the config files
echo "Backing up configuration files..."
cp docker-compose.yml ${BACKUP_DIR}/
cp Caddyfile ${BACKUP_DIR}/
cp *.env ${BACKUP_DIR}/

# Back up PostgreSQL database if used
if grep -q "DB_TYPE=postgresdb" db.env; then
    echo "Backing up PostgreSQL database..."
    DB_USER=$(grep DB_POSTGRESDB_USER db.env | cut -d '=' -f2)
    DB_NAME=$(grep DB_POSTGRESDB_DATABASE db.env | cut -d '=' -f2)
    docker exec $(docker ps -qf "name=postgres") pg_dump -U ${DB_USER} ${DB_NAME} | gzip > ${BACKUP_DIR}/database.sql.gz
fi

echo "Backup completed: ${BACKUP_DIR}"
EOF

    chmod +x backup.sh
}

# Create update script
create_update_script() {
    cat > update.sh << 'EOF'
#!/bin/bash
# N8N Update Script

# Pull the latest images
echo "Pulling latest Docker images..."
docker compose pull

# Stop and remove current containers
echo "Stopping current containers..."
docker compose down

# Start containers with new images
echo "Starting updated containers..."
docker compose up -d

echo "Update completed. N8N is now running the latest version."
EOF

    chmod +x update.sh
}

# Main function
main() {
    configure_ssl
    configure_n8n
    configure_database
    create_backup_script
    create_update_script
    
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${GREEN}Configuration completed successfully!${NC}"
    echo -e "${BLUE}You can now start N8N using: ${GREEN}docker compose up -d${NC}"
    echo -e "${BLUE}Your N8N instance will be available at: ${GREEN}https://${SUBDOMAIN}.${DOMAIN_NAME}${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    echo ""
    echo -e "${YELLOW}NOTE: Please ensure your domain is pointed to this server's IP address.${NC}"
}

# Run the main function
main 