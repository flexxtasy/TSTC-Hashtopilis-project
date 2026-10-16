# Fleet status — Oct 16

| Node | GPU | Driver | Agent | Service |
|---|---|---|---|---|
| u1 (also runs server) | RTX 5060 | 580-open | registered | running |
| u2 | RTX 5060 | 580-open | registered | running |
| u3 | RTX 5060 | 580-open | registered | confirm |
| u4 | RTX 5060 | 580-open | registered | running |
| 5090 rig | RTX 5090 | current | registered | pending enable |

## Done today

- Server deployed with the **current upstream** compose files (see
  `docs/server-setup.md` — the old single-container layout is stale).
- GPU driver fix on all four workers (see `docs/gpu-driver-fix.md`).
- Server IP drift repaired: the frontend's baked-in backend URL must match the
  server's current address (`HASHTOPOLIS_BACKEND_URL` in `.env` +
  `docker compose up -d`).
- All agents enrolled natively via `agent-python` + vouchers (see
  `docs/agent-setup.md`).

## Next

- First end-to-end cracking task: MD5 hashlist + `rockyou.txt`, dictionary
  attack (`-a 0 -m 0`), watch chunks split across all 5 GPUs. Then mask and
  brute-force tasks.
- Housekeeping: DHCP reservation for the server box (address drift broke
  agents/UI/bookmarks in one shot), change default admin password, confirm the
  remaining agent services.
