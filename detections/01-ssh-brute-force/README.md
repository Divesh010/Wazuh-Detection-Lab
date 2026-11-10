# Scenario 1: SSH Brute Force Detection

**MITRE ATT&CK:** [T1110.001](https://attack.mitre.org/techniques/T1110/001/) — Brute Force: Password Guessing  
**Wazuh Rules:** 5710, 5712, 5720  
**Severity:** Critical

---

## What This Detects

Repeated failed SSH login attempts from a single IP address — a hallmark of automated password spraying or dictionary attacks against remote services.

Wazuh's default ruleset fires:
- **Rule 5710** — `sshd: Attempt to login using a non-existent user`
- **Rule 5712** — `sshd: More than 8 authentication failures` (brute force threshold)
- **Rule 5720** — `sshd: Multiple authentication failures for root`

---

## Attack Simulation

Run this on the **Ubuntu Agent VM** (simulates an attacker from localhost):

```bash
# attack-simulation.sh
#!/bin/bash

TARGET_IP="127.0.0.1"
TARGET_USER="root"
ATTEMPTS=15

echo "[*] Simulating SSH brute force: $ATTEMPTS failed attempts against $TARGET_USER@$TARGET_IP"

for i in $(seq 1 $ATTEMPTS); do
    sshpass -p "wrongpassword$i" ssh -o StrictHostKeyChecking=no \
      -o ConnectTimeout=2 $TARGET_USER@$TARGET_IP 2>/dev/null
    echo "  Attempt $i sent"
    sleep 0.5
done

echo "[*] Simulation complete. Check Wazuh dashboard for alerts."
```

Install `sshpass` first:
```bash
sudo apt install -y sshpass
```

Run the simulation:
```bash
chmod +x attack-simulation.sh
./attack-simulation.sh
```

---

## Expected Wazuh Alert

Within ~30 seconds you should see in the dashboard:

| Field | Value |
|---|---|
| Rule ID | 5712 |
| Rule Description | `sshd: More than 8 authentication failures` |
| MITRE Technique | T1110.001 |
| Severity | Critical (12) |
| Source IP | 127.0.0.1 |
| Agent | wazuh-agent |

> **Screenshot checkpoint:** Screenshot of the brute force alert in Wazuh Security Events — save as `screenshots/04-ssh-brute-force-alert.png`

---

## Custom Enhancement Rule

Add this to the **Wazuh Server** at `/var/ossec/etc/rules/local_rules.xml` for a more descriptive alert:

```xml
<!-- Custom SSH Brute Force rule with MITRE tagging -->
<group name="ssh,authentication_failed,">
  <rule id="100001" level="14" frequency="10" timeframe="60">
    <if_matched_sid>5710</if_matched_sid>
    <same_source_ip />
    <description>SSH Brute Force Attack: $(attempt_count) failed attempts from $(srcip)</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
    <group>attack,brute_force,</group>
  </rule>
</group>
```

Restart Wazuh Manager to apply:
```bash
sudo systemctl restart wazuh-manager
```

---

## Remediation

```bash
# Block attacker IP with iptables
sudo iptables -A INPUT -s <ATTACKER_IP> -j DROP

# Or use fail2ban (recommended for automated blocking)
sudo apt install fail2ban
sudo systemctl enable fail2ban --now
```

Verify fail2ban is protecting SSH:
```bash
sudo fail2ban-client status sshd
```

---

## Next Scenario

→ [Scenario 2: Privilege Escalation via Sudo](../02-privilege-escalation/README.md)
