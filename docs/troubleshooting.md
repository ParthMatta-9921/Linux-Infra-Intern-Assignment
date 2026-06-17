# 🛠️ Troubleshooting Guide

This document helps diagnose common issues in the Infra Demo system.

---

#  Common Issues

## 1. Service Not Starting

### Symptom:
- inactive(dead)
### Cure
- run `sudo systemctl restart infra-demo.service`

## 2. Timer shows trigger:N/A

### Symptom:
- timer not enabled


### Cure
- if using OnActiveSec in [Timer] then actually run the service first while the timer is on. (for testing only)
- use Oncalendar as it is the standard.

## 3. HTTP endpoint Not Responding

### Symptom:
- health service not started.
- wrong port in config
- endpoint name is input wrong

### Cure:
- start health service by `sudo <repo>/scripts/provision.sh` or `sudo systemctl start infra-demo.service`
- run provision again
- use the readme to get the correct endpoint name

## 4. Firewall blocking access

### Symptom:
- have not run provision
- have not installed ufw therefore have not run provision

### Cure:
- run provision
-check with `sudo ufw status`

## 5. Permission Check Failure

### Symptom:
- have not run provision

### Cure:
-  run provision with the provided command as on 1 and 3.

