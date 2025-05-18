# One-Click Uptime Kuma Deployment

This project provides a one-click deployment solution for [Uptime Kuma](https://github.com/louislam/uptime-kuma) with automatic HTTPS via [Caddy](https://caddyserver.com/) as a reverse proxy.

## Features

- 🔄 Automatically sets up Uptime Kuma monitoring tool
- 🔒 Configures Caddy reverse proxy with automatic HTTPS via Let's Encrypt
- 🛡️ Includes security headers and best practices
- 📊 Persistent data storage using Docker volumes
- 🚀 Easy installation process for both Linux and Windows

## Prerequisites

- A server with a public IP address
- A domain name pointed to your server's IP address
- Docker and Docker Compose installed (or the script will install them on Linux)

## Installation

### Linux

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/docker-deploy.git
   cd docker-deploy
   ```

2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installation script:
   ```bash
   sudo ./install.sh
   ```

4. Follow the prompts to complete the installation.

### Windows

1. Clone this repository:
   ```powershell
   git clone https://github.com/yourusername/docker-deploy.git
   cd docker-deploy
   ```

2. Run the PowerShell installation script:
   ```powershell
   .\install.ps1
   ```

3. Follow the prompts to complete the installation.

## Accessing Uptime Kuma

Once installation is complete, you can access Uptime Kuma at:

```
https://yourdomain.com
```

## Management Commands

Here are some useful commands for managing your deployment:

### View logs
```bash
docker-compose logs uptime-kuma
docker-compose logs caddy
```

### Stop services
```bash
docker-compose down
```

### Start services
```bash
docker-compose up -d
```

### Restart services
```bash
docker-compose restart
```

### Update to the latest version
```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

## Backup and Restore

Uptime Kuma data is stored in a Docker volume named `uptime-kuma-data`. To back up this data:

```bash
docker run --rm -v uptime-kuma-data:/data -v $(pwd):/backup alpine tar -czf /backup/uptime-kuma-backup.tar.gz -C /data ./
```

To restore from a backup:

```bash
docker run --rm -v uptime-kuma-data:/data -v $(pwd):/backup alpine sh -c "rm -rf /data/* && tar -xzf /backup/uptime-kuma-backup.tar.gz -C /data"
```

## Customization

To customize the Caddy configuration, edit the `caddy/Caddyfile` file and then restart the Caddy service:

```bash
docker-compose restart caddy
```

## Troubleshooting

### Certificate Issues

If you're having problems with the SSL certificate:

1. Check if your domain is correctly pointed to your server's IP address.
2. Ensure port 80 and 443 are open on your server's firewall.
3. Check Caddy logs for any errors:
   ```bash
   docker-compose logs caddy
   ```

### Container Not Starting

If a container isn't starting:

1. Check the logs:
   ```bash
   docker-compose logs
   ```

2. Verify your docker-compose.yml file for any errors.

3. Try rebuilding the containers:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Uptime Kuma](https://github.com/louislam/uptime-kuma) - A fancy self-hosted monitoring tool
- [Caddy](https://caddyserver.com/) - The ultimate server with automatic HTTPS 