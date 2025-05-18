# N8N Installation with Docker and Caddy (Single Environment File)

This repository provides a streamlined installation for N8N workflow automation platform using a single consolidated environment file for simplicity, while using Docker and Caddy for SSL support.

## Features

- **N8N:** Latest version of the workflow automation platform
- **Docker:** Containerized deployment for easy management
- **Caddy:** Modern web server with automatic HTTPS
- **PostgreSQL option:** Use either SQLite (default) or PostgreSQL for the database
- **Authentication:** Optional basic authentication for security
- **Backup/Restore:** Scripts for easy backup and restoration
- **Updates:** Simple update process to keep N8N up-to-date
- **Simplified Configuration:** Single environment file for all settings

## Single Configuration File

This setup uses a **single environment file** (`n8n-config.env`) containing all settings:

- Domain and SSL settings
- N8N application settings
- Database configuration 
- Authentication settings

## Requirements

- Linux server with root access
- A domain name pointed to your server
- Open ports 80 and 443
- Docker and Docker Compose installed

## Installation

1. Clone this repository or download the files
2. Make the configuration script executable:
   ```
   chmod +x setup-single-env.sh
   ```
3. Run the configuration script:
   ```
   ./setup-single-env.sh
   ```
4. Follow the prompts to configure your installation
5. Start the services:
   ```
   docker compose up -d
   ```
6. Access N8N at `https://your-subdomain.your-domain.com`

## Windows Installation

If you're on Windows, you'll need to:

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Edit the `n8n-config.env` file with your configuration information
3. Run `docker compose up -d` from a command prompt in the installation directory

## Management

After installation, you'll have:

- `backup.sh`: Creates backups of your N8N data and configurations
- `update.sh`: Updates N8N to the latest version

## Modifying Configuration

To modify your configuration after setup:
1. Edit the `n8n-config.env` file
2. Restart the containers: `docker compose restart`

## Troubleshooting

If you encounter issues:

1. Check the logs: `docker compose logs -f`
2. Make sure your domain is pointed correctly
3. Verify ports 80 and 443 are open
4. Check that Docker and Docker Compose are installed correctly

## Resources

- [N8N Documentation](https://docs.n8n.io/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Docker Documentation](https://docs.docker.com/) 