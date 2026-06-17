# Infrastructure Hardening Checklist

This document defines and explains the security hardening applied to the Infra demo.

## User & Access Control
- [x] Dedicated service user (`infraadmin`) created
- [x] No root execution of application service
- [x] Least-privilege permissions applied
- [x] Sudo access restricted to provisioning only

---

##  File System Security

- [x] Application files owned by service user
- [x] Config files restricted (`600`)
- [x] Executable scripts restricted (`750`)
- [x] systemd units owned by root
- [x] No global-writable files

---

## Service Hardening

- [x] systemd service enabled at boot
- [x] systemd timer configured for automation
- [x] Restart policies configured (where applicable)
- [x] Services isolated from interactive shells

---

##  Network Security

- [x] UFW enabled
- [x] Default deny incoming traffic
- [x] Only required ports opened (SSH + app port)
- [x] No unrestricted exposure of service ports

---

##  Validation & Monitoring

- [x] Health endpoint implemented
- [x] validate.sh covers:
  - service health
  - port checks
  - firewall rules
  - file permissions
  - user existence
  - log validation
- [x] Logging enabled via file system

---

##  Resilience

- [x] System survives reboot (enabled services)
- [x] Timer persistence enabled
- [x] Provisioning script is idempotent
- [x] Fail-fast execution enabled (`set -euo pipefail`)

---

##  Known Gaps / Future Improvements

- [ ] Centralized logging (journald aggregation)
- [ ] Metrics monitoring (Prometheus)
- [ ] Automated rollback on failure
- [ ] TLS for HTTP endpoint
