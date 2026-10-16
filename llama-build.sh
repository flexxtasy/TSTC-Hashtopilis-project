#!/usr/bin/env bash
# Build llama.cpp with CUDA for RTX 50-series (sm_120). Ubuntu 24.04.
# Requires the NVIDIA driver already installed and working (nvidia-smi OK).
set -euo pipefail

# CUDA Toolkit 12.8+ is REQUIRED for sm_120 (RTX 50-series).
if ! command -v nvcc >/dev/null 2>&1 || ! nvcc --version | grep -qE 'release 1[2-9]\.([89]|[1-9][0-9])'; then
  echo "Installing CUDA Toolkit 12.8 from the NVIDIA apt repo..."
  wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
  sudo dpkg -i cuda-keyring_1.1-1_all.deb && sudo apt update
  sudo apt install -y cuda-toolkit-12-8
fi
export PATH=/usr/local/cuda/bin:$PATH
nvcc --version

sudo apt install -y build-essential cmake ninja-build ccache git

if [ ! -d llama.cpp ]; then
  git clone https://github.com/ggml-org/llama.cpp
fi
cd llama.cpp

cmake -B build -G Ninja \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES=120a-real \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DLLAMA_BUILD_SERVER=ON

# The configure output MUST mention 120a-real — if it doesn't, stop before compiling.
echo "Configured. Building (nvcc is RAM-hungry: -j6, not -j$(nproc))..."
cmake --build build --config Release -j6

echo "Done. Binaries in llama.cpp/build/bin/"
