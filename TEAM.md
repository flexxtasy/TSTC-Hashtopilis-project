# Team & Credits

**TSTC Hashtopolis Project** — a self-hosted distributed password-cracking
cluster for authorized cybersecurity lab work and CTF / NCL practice. A
Hashtopolis coordination server runs in Docker and drives a fleet of USB
live-booted Ubuntu agents running hashcat, so a room of ordinary lab PCs
behaves like one larger cracking rig.

## Project lead

- **Ramiro Resendiz** — project lead, architect, and builder. Designed the
  cluster and set it up end to end: the Hashtopolis server + MariaDB stack in
  Docker, the USB live-boot Ubuntu agent workflow, the hashcat/agent install,
  and the lab networking that ties the agents to the server.
  [GitHub](https://github.com/flexxtasy) ·
  [LinkedIn](https://www.linkedin.com/in/ramiro-resendiz-404a603a3/)

## Contributors

- **Carlos Leal** — co-author. Helped stand up and verify the agent fleet.
  [GitHub](https://github.com/Prodigy7363)
