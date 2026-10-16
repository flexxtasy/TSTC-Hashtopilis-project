# Agent setup (native, verified)

> Updated after real enrollment of 5 workers. The original scaffold assumed
> USB live-boot PCs and the old agent-zip download flow — both changed.

Workers run Ubuntu installed on the internal drive (the USB is only the
installer — everything persists across reboots) and run the agent **natively**,
no Docker on workers.

Read [`gpu-driver-fix.md`](gpu-driver-fix.md) first: RTX 50-series GPUs need
NVIDIA's open kernel modules or hashcat sees no GPU at all.

## 1. Prereqs per worker

```bash
sudo apt install -y git curl python3-venv hashcat
nvidia-smi && hashcat -I   # both must show the GPU
```

## 2. The real agent is `agent-python`

The `hashtopolis/agent` repo is now just a README signpost — no code. The real
agent is **`hashtopolis/agent-python`**, configured via `config.json` (not
interactive prompts, not CLI flags):

```bash
git clone https://github.com/hashtopolis/agent-python ~/hashtopolis-agent
cd ~/hashtopolis-agent
python3 -m venv venv && ./venv/bin/pip install -r requirements.txt
```

Edit `config.json`:

- `voucher` — one per worker, created in the server UI (single-use)
- `url` — the server's agent endpoint under `http://<SERVER_IP>:8080/...`

```bash
./venv/bin/python hashtopolis.py
# expect: Successfully registered!  then  Login successful!  then a polling loop
```

Common first-run failure: leaving the literal placeholder in the voucher field
→ server replies "Provided voucher does not exist".

## 3. Keep it running across reboots

Install the agent as a **systemd service** so it comes back on its own after
class reboots (see the service example in the agent repo). Verify with:

```bash
systemctl status hashtopolis-agent
```

The worker should then appear **Active** under Agents in the server UI.

## 4. Tasks (first cracking runs)

1. Upload `rockyou.txt` as a file + an MD5 hashlist (mode 0).
2. Dictionary task: `#hashtopolis# -a 0 -m 0 #hashlist# #files#`
3. Mask task: `-a 3 -m 0` with a pattern like `?u?l?l?l?l?l?d?d?d?s`
4. Assign all agents to the task and watch chunks split across the GPUs.
