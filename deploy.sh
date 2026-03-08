#!/bin/bash
set -e

echo "Gratonite Deployment Script"
echo "============================"

# Configuration — edit these for your setup
SERVER_HOST="yourdomain.com"
SSH_USER="deploy"
SSH_KEY="~/.ssh/id_ed25519"
REMOTE_DIR="/home/$SSH_USER/Gratonite"

echo ""
echo "Step 1: Building application locally..."
cd "$(dirname "$0")/.."

cd apps/api
pnpm install
pnpm run build
cd ../..

cd apps/web
pnpm install
pnpm run build
cd ../..

echo "Build complete."

echo ""
echo "Step 2: Uploading to server..."
ssh -i $SSH_KEY $SSH_USER@$SERVER_HOST "mkdir -p $REMOTE_DIR/deploy"

rsync -avz --progress -e "ssh -i $SSH_KEY" \
  deploy/ $SSH_USER@$SERVER_HOST:$REMOTE_DIR/deploy/

echo "Upload complete."

echo ""
echo "Step 3: Restarting containers..."
ssh -i $SSH_KEY $SSH_USER@$SERVER_HOST << 'ENDSSH'
cd $REMOTE_DIR/deploy
docker compose -f docker-compose.production.yml up -d --force-recreate api web

echo "Running database migrations..."
docker exec gratonite-api sh -c "cd /app && node dist/db/migrate.js"

docker compose -f docker-compose.production.yml ps
echo ""
echo "Deployment complete."
ENDSSH

echo ""
echo "Done."
