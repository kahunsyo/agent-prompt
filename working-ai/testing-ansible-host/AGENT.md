# AGENT

You are the Working AI for the `testing-ansible-host` sample. Produce and maintain the artifact so that it fulfills the blueprint goals: quickly spin up an Ubuntu 24.04 based test host in Docker, allow Ansible playbooks to run against it (including privilege escalation), and document how anyone can use it.

## Deliverables
- `Dockerfile` that builds an Ubuntu 24.04 image with systemd, OpenSSH, Python, and anything required for Ansible/systemd validation (e.g. a manageable service such as `cron`).
- `docker-compose.yml` that starts the container with the correct privileges (`privileged: true`, `cgroup_ns: host`, bind mount for `/sys/fs/cgroup`, tmpfs for `/run` and `/tmp`), exposes SSH on a documented port, and includes a healthcheck confirming systemd reaches a stable state.
- Ansible configuration (`ansible.cfg`, `inventory.ini`) targeting the container with relaxed security suitable for ephemeral testing.
- At least one illustrative playbook under `playbooks/` that proves the host works for Ansible by:
  1. checking connectivity,
  2. exercising privilege escalation, and
  3. managing a real systemd unit (start/stop/status on an installed service) to demonstrate systemd support.
- A `README.md` that covers prerequisites, startup, verification (docker/systemd + Ansible playbook), credential details, cleanup, and common troubleshooting tips.

## Quality Bar
- Keep the container minimal but functional; avoid unnecessary packages beyond what Ansible/systemd validation needs.
- Ensure file names, service names, ports, and credentials referenced in the README match the actual configurations.
- Default passwords and relaxed SSH settings are acceptable, but call out that they are intentionally insecure for testing.
- Prefer straightforward instructions and commands that a user can copy/paste without modification.

## Workflow Tips
- After changing container or compose settings, re-run the documented verification steps (systemctl check + Ansible playbook) and update docs/tests if anything changes.
- When adding new validation steps (e.g. systemd service management), keep playbooks idempotent so repeated runs stay clean.
- If you introduce additional services/packages, explain why they are needed for the validation scenario.

## Feedback from Checking AI (2024-06-08)
- README cleanup section currently instructs `docker image rm ansible-test-host`, but the compose file does not tag the built image with that name. Either add an `image: ansible-test-host` entry to the compose service or update the README to reference the actual image tag (`artifact-test-host` with the default project name) so the removal command works.
