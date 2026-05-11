# Hetzner Deployment Guide — Apartments Portorož

---

## Step 1 — Create a server on Hetzner

1. Go to https://console.hetzner.cloud
2. Click **New Project** → name it `apartments-portoroz`
3. Click **Add Server** and choose:
   - **Location:** Nuremberg or Helsinki (closest to Slovenia)
   - **Image:** Ubuntu 24.04
   - **Type:** CX22 (2 vCPU, 4GB RAM) — ~€4/month, plenty for a static site
   - **SSH Key:** Add your public key (recommended) or use a root password
   - **Name:** `apartments-portoroz`
4. Click **Create & Buy**
5. Note the **public IPv4 address** shown after creation (e.g. `65.21.x.x`)

---

## Step 2 — Point your domain to the server

In your domain registrar's DNS settings, add:

| Type | Name | Value              | TTL  |
|------|------|--------------------|------|
| A    | @    | YOUR_SERVER_IP     | 300  |
| A    | www  | YOUR_SERVER_IP     | 300  |

Wait 5–30 minutes for DNS to propagate before Step 5.

---

## Step 3 — SSH into the server

```bash
ssh root@YOUR_SERVER_IP
```

---

## Step 4 — Install Docker

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose plugin
apt install docker-compose-plugin -y

# Verify
docker --version
docker compose version
```

---

## Step 5 — Upload your project files

On your **local machine** (not the server), run:

```bash
# Unzip the project
unzip apartments-portoroz-docker.zip -d apartments-portoroz
cd apartments-portoroz

# Upload to server
scp -r . root@YOUR_SERVER_IP:/opt/apartments-portoroz
```

Or use an FTP client like **FileZilla** / **Cyberduck**:
- Host: `YOUR_SERVER_IP`
- Username: `root`
- Port: `22` (SFTP)
- Upload to: `/opt/apartments-portoroz/`

---

## Step 6 — Add HTTPS with Caddy (free SSL)

Back on the **server**, install Caddy as a reverse proxy:

```bash
# Create the Caddy config
cat > /opt/apartments-portoroz/Caddyfile << 'EOF'
yourdomain.com, www.yourdomain.com {
    reverse_proxy web:80
    encode gzip
}
EOF
```

Replace `yourdomain.com` with your actual domain.

Then update `docker-compose.yml` to add Caddy:

```bash
cat > /opt/apartments-portoroz/docker-compose.yml << 'EOF'
version: "3.9"

services:
  web:
    build: .
    container_name: apartments-portoroz
    restart: unless-stopped
    environment:
      - TZ=Europe/Ljubljana
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3

  caddy:
    image: caddy:alpine
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - web

volumes:
  caddy_data:
  caddy_config:
EOF
```

---

## Step 7 — Launch the site

```bash
cd /opt/apartments-portoroz

# Build and start everything
docker compose up --build -d

# Check it's running
docker compose ps
```

Your site should now be live at:
- https://yourdomain.com
- https://www.yourdomain.com

Caddy automatically handles SSL — no manual certificate setup needed.

---

## Step 8 — Set up a firewall (recommended)

```bash
# Allow SSH, HTTP and HTTPS only
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw enable
```

---

## Useful commands after deployment

```bash
# View live logs
docker compose -f /opt/apartments-portoroz/docker-compose.yml logs -f

# Restart after updating index.html
cd /opt/apartments-portoroz
docker compose up --build -d

# Check SSL certificate status
docker exec caddy caddy certificates
```

---

## Updating the site later

Whenever you make changes to `index.html`:

```bash
# On local machine — upload the new file
scp index.html root@YOUR_SERVER_IP:/opt/apartments-portoroz/index.html

# On the server — rebuild
cd /opt/apartments-portoroz && docker compose up --build -d
```

---

## Cost summary

| Item | Cost |
|---|---|
| Hetzner CX22 server | ~€4/month |
| SSL certificate (Caddy/Let's Encrypt) | Free |
| Domain (if purchased separately) | ~€10–15/year |
| **Total** | **~€4/month** |

---

## Support

- Hetzner docs: https://docs.hetzner.com
- Caddy docs: https://caddyserver.com/docs
- Docker docs: https://docs.docker.com
