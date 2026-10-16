# Server setup (Docker) — verified layout

> Updated after the real deploy. The repo's original scaffold assumed a
> single-container server on port 8080 — that layout is stale.

Target: an Ubuntu 24.04 box with Docker + Compose v2. This box hosts the DB,
API and web UI — it does **not** crack (no GPU/driver needed here).

## 1. Deploy with the current upstream files

The old root `docker-compose.yml` / `env.example` are gone from the upstream
repo. Current files:

```bash
mkdir -p ~/hashtopolis && cd ~/hashtopolis
curl -O https://raw.githubusercontent.com/hashtopolis/server/master/docker-compose.mysql.yml
curl -O https://raw.githubusercontent.com/hashtopolis/server/master/env.mysql.example
mv docker-compose.mysql.yml docker-compose.yml
mv env.mysql.example .env
```

Edit `.env`:

- `HASHTOPOLIS_BACKEND_URL=http://<SERVER_IP>:8080/api/v2` — the server's LAN
  IP, not localhost: agents on other machines register against it, and the web
  frontend bakes this URL in at startup.
- Admin username/password.

## 2. Start and verify

```bash
docker compose up -d && docker compose ps
```

- Stack = **3 containers**: backend (API `:8080/api/v2`), MySQL, web UI on
  **`:4200`** — the UI is NOT on 8080 (that's the API).
- Health check: UI returns 200 and backend log shows "Hashtopolis is now ready
  to use!".
- Do not judge API health by probing old agent endpoints (`/api/v2/agent/...`):
  the current backend is OpenAPI-based REST v2 and those paths 404 even on a
  healthy server.
- Compose ships with `restart: always` — the stack self-heals after reboots.

## 3. Vouchers

Log in, change the default admin password, then create one voucher per worker
(Agents → New Agent). Vouchers are single-use and auto-delete on registration.

## 4. If the server's IP changes

Update `HASHTOPOLIS_BACKEND_URL` in `.env`, run `docker compose up -d`
(containers recreate), hard-refresh the browser. Get a **DHCP reservation or
static IP** — address drift breaks agents, the UI's baked-in backend URL, and
bookmarks all at once (learned this the hard way).
