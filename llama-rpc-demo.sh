#!/usr/bin/env bash
# Start/stop the distributed llama.cpp RPC demo across the worker fleet.
# Edit WORKERS and MODEL below, then: ./llama-rpc-demo.sh start | stop
# Run from the coordinator box (SSH key access to workers assumed).
set -euo pipefail

WORKERS=(
  # <NODE1_IP>
  # <NODE2_IP>
  # <NODE3_IP>
  # <NODE4_IP>
)
RPC_PORT=50051
MODEL="$HOME/models/qwen2.5-32b-instruct-q4_k_m.gguf"
LLAMA_BIN="$HOME/llama.cpp/build/bin"
UI_PORT=8081

case "${1:-}" in
  start)
    for ip in "${WORKERS[@]}"; do
      echo "Starting RPC server on $ip"
      ssh "labadmin@$ip" "nohup $LLAMA_BIN/llama-rpc-server --host $ip --port $RPC_PORT >/tmp/rpc.log 2>&1 &" &
    done
    wait
    echo "Launching coordinator (chat UI on :$UI_PORT)..."
    "$LLAMA_BIN/llama-server" -m "$MODEL" \
      --rpc "$(IFS=,; echo "${WORKERS[*]/%/:$RPC_PORT}")" \
      -ngl 99 --port "$UI_PORT"
    ;;
  stop)
    for ip in "${WORKERS[@]}"; do
      ssh "labadmin@$ip" 'pkill -f llama-rpc-server' || true
    done
    pkill -f llama-server || true
    echo "Stopped."
    ;;
  *)
    echo "usage: $0 start|stop" >&2; exit 1 ;;
esac
