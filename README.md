# Linux Infra Intern Assignment

#2nd Milestone

##Objective
Set up python health service and install a systemd service to connect to it.

##Environment

ubuntu 24.04

##Developed Components

-Provision.sh skeleton
-app.py for python health service
-infra-demo.service for systemd management
-infra-demo.env for environment variables like Port

##Repository Structure
-linux-infra-intern-assignment
|-README.md
|-scripts/
  |-provision.sh
|-systemd/
  |-infra-demo.service
|-config/
  |-infra-demo.env
|-docs/
|-evidence/


## Planned Packages

|Package | Purpose           |
|--------|-------------------|
|python3 |Demo Health Service|
|curl    |Service Validation |
|git     |Version Control    |
ufw      |Firewall Management|
