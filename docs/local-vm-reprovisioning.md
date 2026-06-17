# 🖥️ Local VM Reprovisioning Guide

This document explains how to fully rebuild and validate the infrastructure from scratch on a local VM.

---

##  Prerequisites

- Ubuntu VM (fresh install recommended)
- sudo access
- Git installed

---

##  Step 1: Clone Repository

```bash
git clone <repo-url>
cd <repo>
```

## Step 2: Run Provisioning Script
- `sudo <repo>/scripts/provision.sh`
- wait till executed
- expected output
  -packages installed
  -user created `infraadmin`
  -systemd services installed and started
  -so health service also started
  -firewall configure and enabled
  -timer activated

## Step 3: Verify System State
- `sudo <repo>/scripts/validate.sh`
- wait till executed
- expected output
   - service acivation check
   - timer activation check
   - health service check
   - port check
   - frewall configured and activated check
   - user existence check
   - file permissions check
   - reboot survival check
   - log validation

## Step 4: Test Application
- `curl http://localhost:8080/health`
-expected output: OK 200

## Step 5: reprovision test
- run `sudo <repo>/scripts/provision.sh`
- be idempotent as
  - no duplicate users
  - no duplicate services
  - clean re run success

