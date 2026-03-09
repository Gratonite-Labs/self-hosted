# Gratonite Self-Hosted

Deploy your own Gratonite instance using pre-built Docker images. No coding, no build tools — just Docker and a domain name.

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/CoodayeA/Gratonite.git && cd Gratonite

# 2. Configure
cp deploy/self-host/.env.example deploy/self-host/.env
nano deploy/self-host/.env
# Set: INSTANCE_DOMAIN, ADMIN_EMAIL, ADMIN_PASSWORD, DB_PASSWORD

# 3. Launch
docker compose -f deploy/self-host/docker-compose.yml up -d

# 4. Verify
docker compose -f deploy/self-host/docker-compose.yml logs setup
# Should end with: "=== Setup complete! ==="

# 5. Open https://your-domain.com and log in
```

That's it. The setup container automatically runs all database migrations, generates JWT secrets and an Ed25519 instance keypair, and creates your admin account. Caddy handles HTTPS certificates via Let's Encrypt.

## Requirements

- A Linux server with at least **1 GB RAM** (2 GB recommended)
- **Docker Engine 24+** and **Docker Compose v2**
- A **domain name** with an A record pointing to your server
- Ports **80** and **443** open

You do **not** need Node.js, npm, pnpm, or any build tools.

## What Gets Deployed

| Service | Image | Purpose |
|---------|-------|---------|
| **setup** | `ghcr.io/coodayea/gratonite-setup` | First-run init: migrations, keys, admin account |
| **api** | `ghcr.io/coodayea/gratonite-api` | Node.js API + Socket.IO real-time |
| **web** | `ghcr.io/coodayea/gratonite-web` | React SPA served by nginx |
| **postgres** | `postgres:16-alpine` | Database |
| **redis** | `redis:7-alpine` | Cache and rate limiting |
| **caddy** | `caddy:2-alpine` | Reverse proxy with auto-HTTPS |

## Configuration

Only **4 values** are required in your `.env` file:

| Variable | What to set |
|----------|------------|
| `INSTANCE_DOMAIN` | Your domain (e.g. `chat.example.com`) |
| `ADMIN_EMAIL` | Your email address |
| `ADMIN_PASSWORD` | A strong password |
| `DB_PASSWORD` | A random database password (16+ chars) |

Everything else (JWT secrets, APP_URL, CORS_ORIGIN) is auto-generated.

## Updating

```bash
cd Gratonite
git pull
docker compose -f deploy/self-host/docker-compose.yml pull
docker compose -f deploy/self-host/docker-compose.yml up -d
```

Migrations run automatically. Data is preserved.

## Backups

```bash
# Database
docker compose -f deploy/self-host/docker-compose.yml exec postgres \
  pg_dump -U gratonite gratonite | gzip > backup-$(date +%Y%m%d).sql.gz

# Uploads
docker compose -f deploy/self-host/docker-compose.yml cp api:/app/uploads ./uploads-backup
```

## Federation (Optional)

Connect your instance to other Gratonite instances and list your servers on the [Discover](https://gratonite.chat/app/discover) directory:

```bash
# In your .env:
FEDERATION_ENABLED=true
FEDERATION_DISCOVER_REGISTRATION=true
```

Restart the API: `docker compose -f deploy/self-host/docker-compose.yml restart api`

Your public servers sync to gratonite.chat every 30 minutes.

## Full Documentation

- **[Self-Hosting Guide](https://github.com/CoodayeA/Gratonite/blob/main/docs/federation/self-hosting-guide.md)** — Complete setup, configuration, DNS, troubleshooting
- **[Federation Guide](https://github.com/CoodayeA/Gratonite/blob/main/docs/federation/federation-guide.md)** — Connecting to other instances
- **[Protocol Spec](https://github.com/CoodayeA/Gratonite/blob/main/docs/federation/protocol-spec.md)** — Federation protocol technical reference

## Source of Truth

All source code, Docker images, and deployment configuration lives in the [main Gratonite repo](https://github.com/CoodayeA/Gratonite). This repo provides a quick-start reference for self-hosters.
