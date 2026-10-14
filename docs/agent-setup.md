# Agent setup (USB live-boot + Hashtopolis agent)

Each lab PC becomes a cracking **agent**. We boot Ubuntu Server off a USB stick
so nothing touches the machine's internal drive — reboot and the PC is back to
normal.

## 1. Make the live-boot USB

On any machine:

1. Download **Ubuntu Server** ISO (LTS) from ubuntu.com.
2. Flash it to a USB with [balenaEtcher](https://etcher.balena.io/) or
   `Rufus` (Windows). For a persistent live setup, Ventoy also works well and
   lets you keep the ISO + a persistence file on one stick.
3. In each lab PC's BIOS/UEFI: set USB as the first boot device (and disable
   Secure Boot if it blocks booting the stick).

> Live-booting means RAM-only by default. If you want wordlists/agent to
> survive a reboot, use a persistence partition (Ventoy) or just re-run the
> install step each session — it's quick.

## 2. On each booted PC — install dependencies

Hashtopolis agents need hashcat and a runtime. The Python agent is the common
one:

```bash
sudo apt update
sudo apt install -y hashcat python3 python3-pip python3-venv curl p7zip-full
```

Check GPU drivers are present if the lab PCs have discrete GPUs — hashcat needs
OpenCL/CUDA to use them. `hashcat -I` lists the devices it sees. CPU-only still
works, just slower.

## 3. Download + register the agent

In the Hashtopolis UI the server gives you the agent download + a voucher.

```bash
mkdir ~/htp-agent && cd ~/htp-agent
# download the python agent from your server (URL shown in the UI), e.g.:
curl -O http://<SERVER-IP>:8080/agents.php?download=1 -o hashtopolis.zip
# ...follow the UI's exact download instructions for your version...

python3 hashtopolis.zip
```

On first run it asks for:

- the **server URL**: `http://<SERVER-IP>:8080/api/server.php`
- the **voucher** code from the server

After that the agent appears under **Agents** in the UI.

> Agent packaging varies by Hashtopolis version — always use the download
> link/instructions from your own server's UI rather than hard-coding a URL.
> Confirm against https://github.com/hashtopolis/server.

## 4. Group the agents

In the UI: create an **agent group**, add every lab PC to it. Assign tasks to
the group so chunks spread across all machines automatically.

## 5. Per-session checklist (live boot)

Because live boot is ephemeral, each class session on each PC:

- [ ] Boot off the USB
- [ ] Confirm network (same subnet as server, can `ping <SERVER-IP>`)
- [ ] Install deps (step 2) if not persisted
- [ ] Launch the agent (step 3) — it reconnects to the server
- [ ] Verify it shows **active** in the UI

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Agent won't register | Right server URL? Voucher valid/not used up? Firewall on 8080? |
| Agent registers but idle | Is it in the group the task is assigned to? Task active? |
| hashcat sees no GPU | `hashcat -I`; install vendor OpenCL/CUDA drivers |
| Slow cracking | CPU-only fallback; check benchmark `hashcat -b` |
