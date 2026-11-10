# Scenario 2: Privilege Escalation via Sudo

**MITRE ATT&CK:** [T1548.003](https://attack.mitre.org/techniques/T1548/003/) — Abuse Elevation Control Mechanism: Sudo and Sudo Caching  
**Wazuh Rules:** 5401, 5402  
**Severity:** High

---

## What This Detects

An unprivileged user attempting to execute commands as root via `sudo` without being listed in `/etc/sudoers`. This is a common indicator of:
- A compromised low-privilege account attempting to escalate
- An insider threat probing for misconfigured sudo access

Wazuh fires:
- **Rule 5401** — `Attempt to run sudo command by an unauthorized user`
- **Rule 5402** — `Successful sudo to ROOT executed`

---

## Attack Simulation

Run this on the **Ubuntu Agent VM** as `testuser` (created during setup — not in sudoers):

```bash
# attack-simulation.sh
#!/bin/bash

echo "[*] Simulating unauthorized sudo escalation attempts as 'testuser'"

# Switch to testuser and attempt privileged commands
su - testuser -c "sudo cat /etc/shadow" 2>/dev/null || true
su - testuser -c "sudo /bin/bash" 2>/dev/null || true
su - testuser -c "sudo systemctl stop ssh" 2>/dev/null || true
su - testuser -c "sudo useradd backdoor" 2>/dev/null || true

echo "[+] Simulation complete. Check Wazuh dashboard for Rule 5401 alerts."
```

Run the simulation (as `labuser`):
```bash
chmod +x attack-simulation.sh
./attack-simulation.sh
```

You can also confirm manually what's logged:
```bash
sudo grep "not in sudoers" /var/log/auth.log
```

---

## Expected Wazuh Alert

| Field | Value |
|---|---|
| Rule ID | 5401 |
| Rule Description | `Attempt to run sudo command by an unauthorized user` |
| MITRE Technique | T1548.003 |
| Severity | High (9) |
| User | testuser |
| Agent | wazuh-agent |

> **Screenshot checkpoint:** Screenshot of the sudo escalation alert — save as `screenshots/05-sudo-escalation-alert.png`

---

## Custom Enhancement Rule

Add to `/var/ossec/etc/rules/local_rules.xml` on the **Wazuh Server**:

```xml
<!-- Custom sudo abuse rule with MITRE tagging -->
<group name="sudo,privilege_escalation,">
  <rule id="100002" level="12">
    <if_sid>5401</if_sid>
    <description>Privilege Escalation Attempt: Unauthorized sudo by user '$(dstuser)' — command '$(command)'</description>
    <mitre>
      <id>T1548.003</id>
    </mitre>
    <group>attack,privilege_escalation,</group>
  </rule>
</group>
```

---

## Remediation

```bash
# Audit who has sudo access
sudo cat /etc/sudoers
sudo ls /etc/sudoers.d/

# Lock the testuser account if compromised
sudo usermod -L testuser

# Check testuser's recent command history
sudo cat /home/testuser/.bash_history
```

---

## Next Scenario

→ [Scenario 3: File Integrity Monitoring Tampering](../03-fim-tampering/README.md)
