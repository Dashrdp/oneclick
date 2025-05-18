# Self-Hosted Outline Wiki Setup

This repository contains configuration files for self-hosting [Outline](https://github.com/outline/outline) Wiki on Ubuntu with local storage, Slack authentication, and SMTP email configuration.

## Requirements

- Ubuntu server
- Docker and Docker Compose
- A domain name (recommended for production)
- Slack App credentials
- SMTP server for emails

## Setup Instructions

### 1. Clone this Repository

```bash
git clone <repository-url>
cd outline
```

### 2. Configure Environment Variables

Edit the `docker.env` file to configure your installation:

```bash
# Generate secret keys
SECRET_KEY=$(openssl rand -hex 32)
UTILS_SECRET=$(openssl rand -hex 32)

# Replace the placeholders in docker.env
sed -i "s/replace_with_a_generated_secret_key/$SECRET_KEY/" docker.env
sed -i "s/replace_with_a_generated_utils_secret/$UTILS_SECRET/" docker.env
```

Update the following variables in `docker.env`:

- Database credentials (`POSTGRES_PASSWORD`)
- URL (set to your domain name in production)
- Slack authentication details
- SMTP server configuration

### 3. Configure Slack Authentication

1. Create a Slack App at https://api.slack.com/apps
2. Under "OAuth & Permissions", add the redirect URL: `https://your-domain.com/auth/slack.callback`
3. Obtain your Client ID and Client Secret
4. Update the `SLACK_CLIENT_ID` and `SLACK_CLIENT_SECRET` in `docker.env`

### 4. Start the Services

```bash
docker-compose up -d
```

### 5. Initialize the Database

```bash
docker-compose exec outline yarn db:migrate
```

### 6. Access Outline

Open your browser and navigate to `http://localhost:3000` or your configured domain.

## Maintenance

### Updating Outline

To update to the latest version:

```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

### Backing Up Data

The following volumes contain your data:
- `postgres-data`: Database
- `redis-data`: Cache and sessions
- `outline-data`: Uploaded files (when using local storage)

To back up the database:

```bash
docker-compose exec postgres pg_dump -U postgres outline > outline_backup.sql
```

## Troubleshooting

If you encounter connection issues:
- Make sure `FORCE_HTTPS` is set to `false` if you're not using HTTPS
- Ensure `PGSSLMODE=disable` is uncommented if you're having database connection issues
- Check `URL` is set correctly with http/https protocol

## Additional Configuration Options

The `docker.env` file contains comments explaining each configuration option. For full documentation, refer to the [official Outline documentation](https://docs.getoutline.com/s/hosting/doc/hosting-outline-nipGaCRBDu). 