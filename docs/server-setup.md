# Server setup (Docker)

The Hashtopolis server runs on one machine. It needs Docker + the Compose
plugin and a stable IP the lab PCs can reach.

## 1. Prerequisites

```bash
# Docker Engine + Compose plugin (Ubuntu/Debian)
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker

# let your user run docker without sudo (log out/in after)
sudo usermod -aG docker "$USER"
```

## 2. Configure

```bash
git clone https://github.com/flexxtasy/TSTC-Hashtopilis-project.git
cd TSTC-Hashtopilis-project
cp .env.example .env
# edit .env and set real passwords
```

## 3. Bring it up

```bash
docker compose up -d
docker compose ps        # both services should be "running"/"healthy"
docker compose logs -f server   # watch first-run DB init
```

The web UI is then at:

```
http://<SERVER-IP>:8080
```

Log in with the `HASHTOPOLIS_ADMIN_USER` / `HASHTOPOLIS_ADMIN_PASSWORD` you set
in `.env`.

## 4. Create an agent voucher

In the UI: **Agents → New voucher**. Agents use this one-time code to register.
Create one voucher the class can reuse, or one per machine — your call.

## 5. Note the server address

Agents need the full base URL, e.g. `http://192.168.x.x:8080`. Write it on the
whiteboard — every lab PC types it during agent registration.

## Networking notes

- The server and all lab PCs must be on the **same LAN / subnet** (the lab
  switch is easiest).
- Open/allow TCP **8080** on the server host firewall if one is active:
  `sudo ufw allow 8080/tcp`.
- If you later want HTTPS, put a reverse proxy (Caddy/Nginx) in front — not
  required for a closed lab.

## Useful ops

```bash
docker compose down            # stop (keeps data volumes)
docker compose down -v         # stop AND wipe DB/files — fresh start
docker compose pull && docker compose up -d   # update images
```
