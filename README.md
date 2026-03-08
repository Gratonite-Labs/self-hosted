# Gratonite Self-Hosted

Deploy your own Gratonite instance using Docker Compose.

## Prerequisites

- A Linux server (Ubuntu 22.04+ recommended) with at least 2 GB RAM
- [Docker Engine](https://docs.docker.com/engine/install/) and Docker Compose
- Node.js 20+ and pnpm (for building)
- A domain name with DNS pointing to your server

## Quick Start

```bash
# 1. Clone the main repo
git clone https://github.com/CoodayeA/Gratonite.git
cd Gratonite

# 2. Configure environment
cp deploy/.env.example .env
# Edit .env — set DB_PASSWORD, JWT secrets, SMTP, domain, LiveKit credentials

# 3. Build
cd apps/api && pnpm install && pnpm run build && cd ../..
cd apps/web && pnpm install && pnpm run build && cd ../..

# 4. Update deploy/Caddyfile with your domain

# 5. Start
cd deploy
docker compose -f docker-compose.production.yml up -d

# 6. Run migrations
docker exec gratonite-api sh -c "cd /app && node dist/db/migrate.js"

# 7. Visit https://yourdomain.com
```

## What Gets Deployed

| Service    | Container            | Description                          |
|------------|----------------------|--------------------------------------|
| PostgreSQL | `gratonite-postgres` | Primary database                     |
| Redis      | `gratonite-redis`    | Cache and real-time state            |
| API        | `gratonite-api`      | Node.js backend (port 4000)          |
| Web        | `gratonite-web`      | Nginx serving React build            |
| Caddy      | `gratonite-caddy`    | Reverse proxy with automatic HTTPS   |

## Environment Variables

```env
DB_PASSWORD=             # PostgreSQL password
JWT_SECRET=              # Generate: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
JWT_REFRESH_SECRET=      # Generate a different one
SMTP_HOST=               # SMTP server (e.g. smtp.sendgrid.net)
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_FROM=noreply@yourdomain.com
APP_URL=https://yourdomain.com
CORS_ORIGIN=https://yourdomain.com
LIVEKIT_URL=             # For voice/video
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=
```

## Updating

```bash
cd Gratonite && git pull
cd apps/api && pnpm install && pnpm run build && cd ../..
cd apps/web && pnpm install && pnpm run build && cd ../..
cd deploy && docker compose -f docker-compose.production.yml up -d --force-recreate api web
docker exec gratonite-api sh -c "cd /app && node dist/db/migrate.js"
```

## Backups

```bash
docker exec gratonite-postgres pg_dump -U gratonite gratonite > backup_$(date +%Y%m%d).sql
```

## Full Documentation

For detailed deployment guides, DNS setup, and SMTP configuration, see the [main repository docs](https://github.com/CoodayeA/Gratonite/tree/main/docs):

- [Self-Hosting Guide](https://github.com/CoodayeA/Gratonite/blob/main/docs/DEPLOY-TO-OWN-SERVER.md)
- [VPS Deployment](https://github.com/CoodayeA/Gratonite/blob/main/docs/DEPLOY-TO-HETZNER.md)
- [DNS Configuration](https://github.com/CoodayeA/Gratonite/blob/main/docs/DNS-CONFIGURATION.md)
- [SMTP Configuration](https://github.com/CoodayeA/Gratonite/blob/main/docs/SMTP-CONFIGURATION.md)

## Source of Truth

The deployment configuration lives in the [main Gratonite repo](https://github.com/CoodayeA/Gratonite) under `deploy/`. This repo provides a quick-start reference.

## License

See the [main repository](https://github.com/CoodayeA/Gratonite) for license information.
