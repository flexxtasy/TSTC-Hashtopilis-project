# GPU driver fix — RTX 50-series (Blackwell) on Ubuntu 24.04

**Found the hard way on all four worker PCs (Oct 16).** Worth reading before
touching a fresh worker.

## Symptom

`nvidia-smi` → *"couldn't communicate with the NVIDIA driver"*, but `lspci -nn`
**does** show the GPU (RTX 5060 = `10de:2d05`). The giveaway: `lspci -nnk` shows
**no `Kernel driver in use:` line** on the NVIDIA device.

## Root cause

The stock Ubuntu image shipped **`nvidia-driver-550` (proprietary)**. RTX
50-series (Blackwell) GPUs only work with NVIDIA's **open** kernel modules. The
550 module loads in `lsmod` but never binds the GPU — so it looks "installed"
and isn't.

## Fix (per box)

```bash
sudo apt purge -y 'nvidia-driver-550' 'nvidia-*550*' 'libnvidia-*550*' 'linux-*-nvidia-550*'
sudo apt autoremove -y
sudo apt install -y nvidia-driver-580-open nvidia-utils-580 hashcat
sudo reboot
```

On a clean box, skip the purge and install `nvidia-driver-580-open` from the
start. `ubuntu-drivers list` shows the exact installable names (HWE kernel-module
pairs) — use those rather than guessing package names.

## Verify after reboot

```bash
nvidia-smi     # must show the RTX 5060
hashcat -I     # must list the GPU
```

## Diagnostic order that found it

1. `lspci -nn | grep -i nvidia` — is the GPU on the bus?
2. `lsmod | grep -E 'nouveau|nvidia'` — module loaded? nouveau conflict?
3. `mokutil --sb-state` — Secure Boot blocks unsigned DKMS modules
4. `cat /proc/driver/nvidia/version` — which NVRM is actually live
5. `dpkg -l | grep -i nvidia` — which variant/version is installed

(`dmesg` needs `sudo` on Ubuntu 24.04 — "Operation not permitted" otherwise.)

## Related worker gotchas from the same day

- Boxes imaged from the same USB can each end up running a copy of the *server*
  stack — check `docker ps --format "{{.Names}}"` on each worker; keep exactly
  one server and `docker compose down` the copies, or agents join competing DBs.
- The Docker agent image is a ~2.5 GB CUDA base and can die mid-extract with
  `no space left on device` — native install is smaller and faster.
- Minimal images often lack `curl` and `git` — install them before following
  any setup doc.
