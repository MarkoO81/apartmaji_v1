# Apartments Portorož

Static website served via nginx + Docker, with Caddy for HTTPS.

## Quick deploy
See DEPLOY-HETZNER.md for the full step-by-step guide.

## Files
- index.html        — the website
- Dockerfile        — nginx:alpine image
- nginx.conf        — nginx config
- docker-compose.yml — starts nginx + Caddy
- Caddyfile         — HTTPS config (edit your domain here)
- DEPLOY-HETZNER.md — full deployment instructions
