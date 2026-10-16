#!/usr/bin/env bash
# One-shot GPU driver + hashcat setup for a fresh RTX 50-series worker (Ubuntu 24.04).
# Run on the worker itself. Reboot required afterwards.
set -euo pipefail

# Purge the proprietary 550 branch if present (never binds Blackwell GPUs).
if dpkg -l 2>/dev/null | grep -q 'nvidia-driver-550'; then
  echo "Purging proprietary 550 driver set..."
  sudo apt purge -y 'nvidia-driver-550' 'nvidia-*550*' 'libnvidia-*550*' 'linux-*-nvidia-550*'
  sudo apt autoremove -y
fi

echo "Installing open kernel-module driver 580 + utils + hashcat..."
sudo apt install -y nvidia-driver-580-open nvidia-utils-580 hashcat

echo "Done. Reboot, then verify with: nvidia-smi && hashcat -I"
