# Step 2: Ubuntu Agent VM Setup

This VM acts as the monitored endpoint — the machine a Wazuh agent runs on and that attack simulations target.

---

## 1. Create the Ubuntu VM in VirtualBox

**Download Ubuntu 22.04 LTS ISO:**
```
https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso
```

**VirtualBox settings:**

| Setting | Value |
|---|---|
| Name | `wazuh-agent` |
| OS Type | Ubuntu 64-bit |
| RAM | **2048 MB** (2 GB) |
| Disk | 20 GB (dynamically allocated) |
| Network Adapter 1 | **Host-only Adapter** → `vboxnet0` |

**Install Ubuntu Server:**
1. Boot from ISO
2. Choose minimal install, no extra packages
3. Set username: `labuser`, password: `Lab@12345`
4. After install, eject the ISO and reboot

---

## 2. Get the Agent VM IP

```bash
ip a | grep inet
# Note your 192.168.56.x address
```

---

## 3. Install OpenSSH Server

```bash
sudo apt update && sudo apt install -y openssh-server auditd
sudo systemctl enable ssh auditd
sudo systemctl start ssh auditd
```

Verify SSH is running:
```bash
sudo systemctl status ssh
```

---

## 4. Create a Non-Privileged Test User

This user will be used to simulate unauthorized sudo attempts in Scenario 2.

```bash
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser
# Set password: TestPass123
# Do NOT add testuser to sudoers
```

---

## Next Step

→ [Step 3: Agent Enrollment](03-agent-enrollment.md)
