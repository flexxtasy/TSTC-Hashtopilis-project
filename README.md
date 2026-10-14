# TSTC Hashtopolis Distributed Cracking Lab

A class project for building a small **distributed password-cracking cluster**
using [Hashtopolis](https://github.com/hashtopolis/server) as the coordination
server and a set of lab PCs as cracking agents.

The lab PCs are **live-booted into Ubuntu Server from USB** (nothing is
installed to their internal drives), and each one runs the Hashtopolis agent to
pull jobs from a central server. The server itself runs in **Docker**.

> This is a lab/educational exercise for a TSTC security course. All hashes
> cracked here are our own lab-provided or self-generated hashes used for
> coursework — not third-party data.

## What is Hashtopolis?

Hashtopolis is a wrapper/coordinator around [hashcat](https://hashcat.net/).
Instead of running hashcat on one machine, you point many machines ("agents")
at one server. The server:

- stores the hashlists, wordlists, rules, and masks,
- splits a cracking task into **chunks**,
- hands chunks out to whichever agents are free,
- collects cracked results back in one place.

That lets a room full of average PCs behave like one bigger cracking rig.

## Architecture

```
            ┌─────────────────────────────┐
            │   Hashtopolis Server (Docker)│
            │   - web UI + API             │
            │   - MariaDB backend          │
            │   - stores hashlists/files   │
            └──────────────┬──────────────┘
                           │  HTTP(S) API
          ┌────────────────┼────────────────┐
          │                │                │
   ┌──────┴─────┐   ┌──────┴─────┐   ┌──────┴─────┐
   │  Lab PC 1  │   │  Lab PC 2  │   │  Lab PC N  │
   │ USB → Ubuntu│   │ USB → Ubuntu│  │ USB → Ubuntu│
   │  + agent    │   │  + agent    │  │  + agent    │
   │  + hashcat  │   │  + hashcat  │  │  + hashcat  │
   └─────────────┘   └─────────────┘  └─────────────┘
```

- **Server**: one machine (or a VM) running Docker. Hosts the web UI and the
  agent API. This is the only machine that needs a stable IP.
- **Agents**: the live-booted lab PCs. Each registers with the server using a
  voucher, then pulls work.

## Rundown — how we stand it up

1. **Server up (Docker).** Bring up Hashtopolis + its database with
   `docker compose up -d`. See [`docs/server-setup.md`](docs/server-setup.md).
2. **Live-boot the agents.** Flash Ubuntu Server to USB, boot each lab PC off
   it. See [`docs/agent-setup.md`](docs/agent-setup.md).
3. **Install the agent.** On each booted PC, install hashcat + dependencies and
   download the agent from the server, then register it with a voucher.
4. **Group the agents.** Put all lab PCs in one agent group in the UI.
5. **Load work.** Upload a hashlist + wordlist/rules, create a task, assign it
   to the group.
6. **Watch it crack.** The server chunks the task across all agents and
   collects cracks centrally.

## Repo layout

| Path | What it is |
|------|-----------|
| `docker-compose.yml` | Hashtopolis server + MariaDB stack |
| `.env.example` | Template for server/DB credentials (copy to `.env`) |
| `docs/server-setup.md` | Standing up the Docker server |
| `docs/agent-setup.md` | USB live-boot + agent install on each PC |
| `TEAM.md` | Who's on the project |

## Status

Scaffold / planning stage. Compose file and docs are a starting point — verify
versions and env vars against the current
[upstream Hashtopolis repo](https://github.com/hashtopolis/server) before the
live run, since their Docker setup changes between releases.
