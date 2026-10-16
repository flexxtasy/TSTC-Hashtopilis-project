# Bonus: Distributed LLM Inference on the Same Workers

The cracking workers can double as a small distributed LLM cluster using
**llama.cpp** in RPC mode — the model is split (pipeline-style) across all GPUs
over the LAN.

Sizing: each RTX 5060 has 8 GB VRAM. A ~32B Q4 model (~20 GB) spans 4 workers.
Expect ~2-5 tokens/s over 1 GbE — a proof-of-concept, not a daily driver.

## Requirements

- NVIDIA driver already installed (same one used for cracking)
- **CUDA Toolkit 12.8+** — RTX 50-series is `sm_120`; older toolkits don't know
  that architecture and the binary fails at runtime with
  "no kernel image is available for execution on the device".

## Build (every worker + the coordinator)

Use `scripts/llama-build.sh`. The configure log **must** show
`120a-real` before the long compile starts.

## Run a demo

1. Start an RPC server on each worker:
   `~/llama.cpp/build/bin/llama-rpc-server --host <NODE_IP> --port 50051`
2. On the coordinator (the server box works — it contributes no VRAM but runs
   the web UI):
   ```bash
   ~/llama.cpp/build/bin/llama-server \
     -m ~/models/qwen2.5-32b-instruct-q4_k_m.gguf \
     --rpc <NODE1_IP>:50051,<NODE2_IP>:50051,<NODE3_IP>:50051,<NODE4_IP>:50051 \
     -ngl 99 --port 8081
   ```
3. Anyone on the LAN opens `http://<COORDINATOR_IP>:8081` for the chat UI.

Notes:

- Only the coordinator needs the model file; RPC servers receive their layer
  weights over the LAN at load (~3-5 min for 20 GB over 1 GbE). Caching the
  GGUF on each worker speeds up restarts.
- Inference and Hashcat fight for the same GPU — run them on separate schedules.
- Keep RPC servers manually started so class PCs behave normally the rest of the time.
