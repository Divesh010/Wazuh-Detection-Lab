# Wazuh Detection Lab

[![Wazuh](https://img.shields.io/badge/Wazuh-4.x-blue.svg)](https://wazuh.com/)
[![Platform](https://img.shields.io/badge/Platform-VirtualBox-orange.svg)]()
[![MITRE ATT&CK](https://img.shields.io/badge/MITRE%20ATT%26CK-v14-red.svg)](https://attack.mitre.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A hands-on home SOC lab built with Wazuh SIEM on VirtualBox. This lab documents the full setup of a Wazuh server + monitored Linux agent, three real attack simulations, custom detection rules, and MITRE ATT&CK-mapped alerts — all verified with dashboard screenshots.

---

## Lab Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        HOST MACHINE                         │
│                     Windows 11 / VirtualBox                 │
│                                                             │
│   ┌─────────────────────────┐  ┌────────────────────────┐  │
│   │   Wazuh Server VM       │  │   Ubuntu Agent VM      │  │
│   │   (OVA Appliance)       │◄─│   (Attack target)      │  │
│   │                         │  │                        │  │
│   │  • Wazuh Manager        │  │  • Wazuh Agent         │  │
│   │  • Wazuh Indexer        │  │  • OpenSSH Server      │  │
│   │  • Wazuh Dashboard      │  │  • Auditd              │  │
│   │  • RAM: 6 GB            │  │  • RAM: 2 GB           │  │
│   └─────────────────────────┘  └────────────────────────┘  │
│              Internal Network: 192.168.56.0/24              │
└─────────────────────────────────────────────────────────────┘
```

---

## Attack Scenarios & MITRE ATT&CK Coverage

| # | Scenario | MITRE Technique | Rule ID | Severity |
|---|---|---|---|---|
| 1 | SSH Brute Force | [T1110.001](https://attack.mitre.org/techniques/T1110/001/) — Brute Force: Password Guessing | 5712, 5720 | **Critical** |
| 2 | Privilege Escalation via Sudo | [T1548.003](https://attack.mitre.org/techniques/T1548/003/) — Sudo and Sudo Caching | 5401, 5402 | **High** |
| 3 | File Integrity Tampering | [T1565.001](https://attack.mitre.org/techniques/T1565/001/) — Stored Data Manipulation | 550, 553 | **High** |

---

## Setup Guide

- [**Step 1:** Wazuh Server Setup](setup/01-wazuh-server-setup.md)
- [**Step 2:** Ubuntu Agent VM Setup](setup/02-ubuntu-agent-setup.md)
- [**Step 3:** Agent Enrollment & Verification](setup/03-agent-enrollment.md)

## Detection Scenarios

- [**Scenario 1:** SSH Brute Force Detection](detections/01-ssh-brute-force/README.md)
- [**Scenario 2:** Privilege Escalation via Sudo](detections/02-privilege-escalation/README.md)
- [**Scenario 3:** File Integrity Monitoring Tampering](detections/03-fim-tampering/README.md)

---

## Author

**Divesh Gupta** | MTech Cybersecurity, Bennett University  
GitHub: [@Divesh010](https://github.com/Divesh010)
