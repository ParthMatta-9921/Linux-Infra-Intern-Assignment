`
#  Infrastructure Test Plan

This document defines the testing for validation of the Infra demo.


#  Test Objectives

- Validate provisioning correctness
- Ensure service reliability
- Verify system security configuration
- Ensure reboot persistence
- Validate monitoring capability


#  Test Categories

## 1. Provisioning Tests

| Test                | Expected Result    |
|---------------------|--------------------|
| Fresh VM install    | Successful setup   |
| Missing dependency  | Script fails fast  |
| Re-run provisioning | Idempotent success |

---

## 2. Service Tests

| Test                     | Expected Result    |
|--------------------------|--------------------|
| infra-demo service start | Active (running)   |
| systemd restart          | Service recovers   |
| boot start               | Service auto-starts|

---

## 3. Timer Tests

| Test                | Expected Result      |
|---------------------|----------------------|
| Timer activation    | Active               |
| Scheduled execution | Runs periodically    |
| Reboot persistence  | Timer survives reboot|

---

## 4. Network Tests

| Test                  | Expected Result|
|-----------------------|----------------|
| HTTP /health endpoint | 200 OK         |
| Port listening        | Active on 8080 |
| Firewall rules        | Enforced       |

---

## 5. Security Tests

| Test                 | Expected Result      |
|----------------------|----------------------|
| User existence       | infraadmin exists    |
| File permissions     | Strict mode enforced |
| Root exposure        | None                 |

---

## 6. Validation Script Tests

| Test              | Expected Result         |
|-------------------|-------------------------|
| validate.sh run   | PASS                      |
| failure detection | Correct error reporting |

---

# 🔁 Reproducibility Test

- Destroy VM
- Recreate VM
- Run provisioning
- Validate identical outcome

---

# 📌 Pass Criteria

System is considered valid if:

- All services active
- Timer scheduled correctly
- HTTP endpoint responds
- No firewall misconfigurations
- validate.sh returns success
