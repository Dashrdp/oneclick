# One-Click Uptime Kuma Deployment (Linux)

Easily deploy [Uptime Kuma](https://github.com/louislam/uptime-kuma) with automatic HTTPS using [Caddy](https://caddyserver.com/) as a reverse proxy, following Docker best practices.

---

## Features

- 🚀 One-command install for Linux servers
- 🔒 Automatic HTTPS via Caddy and Let's Encrypt
- 🛡️ Secure HTTP headers and modern reverse proxy setup
- 📦 Persistent data storage with Docker volumes
- 🔄 Uses latest images for Uptime Kuma and Caddy
- 📝 Simple configuration, easy updates, and backups

---

## Prerequisites

- **Linux server** with a public IP address
- **Domain name** pointed to your server (e.g., `uptime.dashrdp.com`)
- **Ports 80 and 443 open** in your firewall
- **Root or sudo access**

> **Note:** Docker and Docker Compose will be installed automatically if missing.

---

## Quick Start

1. **Clone this repository and enter the deploy directory:**
   ```bash
   git clone https://github.com/Dashrdp/oneclick.git
   cd oneclick/uptime/docker-deploy
   ```

2. **Make the install script executable and run it:**
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

3. **Wait for setup to complete.**

4. **Access Uptime Kuma:**
   - Visit: [https://uptime.dashrdp.com](https://uptime.dashrdp.com)

---

## How It Works

- **Uptime Kuma** runs in a Docker container, storing data in a persistent volume.
- **Caddy** acts as a reverse proxy, automatically obtaining and renewing SSL certificates for your domain (`uptime.dashrdp.com`) using the email `dashrdp@gmail.com`.
- All configuration is handled by `docker-compose.yml` and `caddy/Caddyfile`.

---

## File Structure

```
uptime/docker-deploy/
  ├── caddy/
  │   └── Caddyfile
  ├── docker-compose.yml
  └── install.sh
```

---

## Management Commands

- **View logs:**
  ```bash
  docker compose logs uptime-kuma
  docker compose logs caddy
  ```
- **Stop services:**
  ```bash
  docker compose down
  ```
- **Start services:**
  ```bash
  docker compose up -d
  ```
- **Restart services:**
  ```bash
  docker compose restart
  ```
- **Update to latest version:**
  ```bash
  docker compose pull
  docker compose up -d
  ```

---

## Backup and Restore

- **Backup Uptime Kuma data:**
  ```bash
  docker run --rm -v uptime-kuma-data:/data -v $(pwd):/backup alpine tar -czf /backup/uptime-kuma-backup.tar.gz -C /data ./
  ```
- **Restore from backup:**
  ```bash
  docker run --rm -v uptime-kuma-data:/data -v $(pwd):/backup alpine sh -c "rm -rf /data/* && tar -xzf /backup/uptime-kuma-backup.tar.gz -C /data"
  ```

---

## Customization

- **Change domain or email:**
  - Edit `caddy/Caddyfile` and update the domain/email.
  - Restart Caddy:
    ```bash
    docker compose restart caddy
    ```
- **Change Uptime Kuma or Caddy settings:**
  - Edit `docker-compose.yml` as needed.
  - Restart stack:
    ```bash
    docker compose up -d
    ```

---

## Troubleshooting

### SSL/Certificate Issues
- Ensure your domain points to your server's public IP.
- Make sure ports 80 and 443 are open.
- Check Caddy logs:
  ```bash
  docker compose logs caddy
  ```

### Container Not Starting
- View logs:
  ```bash
  docker compose logs
  ```
- Check for typos in `docker-compose.yml` or `Caddyfile`.
- Rebuild containers:
  ```bash
  docker compose down
  docker compose up -d
  ```

---

## Security Notes
- Caddy is configured with strong security headers by default.
- Always keep your server and Docker images up to date.
- Use strong passwords for your Uptime Kuma admin account.

---

## References
- [Docker Compose Best Practices](https://docs.docker.com/build/building/best-practices/)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Caddy](https://caddyserver.com/)

---

## License
MIT License. See LICENSE file for details. 