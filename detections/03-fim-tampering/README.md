# Scenario 3: File Integrity Monitoring — Sensitive File Tampering

**MITRE ATT&CK:** [T1565.001](https://attack.mitre.org/techniques/T1565/001/) — Data Manipulation: Stored Data Manipulation  
**Wazuh Rules:** 550, 553, 554  
**Severity:** High

---

## What This Detects

Wazuh's File Integrity Monitoring (FIM) engine (`syscheck`) continuously hashes and monitors critical files. Any unauthorized modification to `/etc/passwd`, `/etc/sudoers`, `/usr/bin/` binaries, or similar files triggers an immediate alert.

This simulates a post-exploitation attacker attempting to:
- Add a backdoor user to `/etc/passwd`
- Modify sudoers for persistent privilege escalation

Wazuh fires:
- **Rule 550** — `Integrity checksum changed`
- **Rule 553** — `File deleted`
- **Rule 554** — `File added to the system`

---

## Attack Simulation

Run this on the **Ubuntu Agent VM** as `labuser` (with sudo):

```bash
# attack-simulation.sh
#!/bin/bash

echo "[*] Simulating file integrity tampering — modifying sensitive system files"
echo "[!] This will make real changes. The cleanup section will revert them."
echo ""

# 1. Modify /etc/passwd to add a fake backdoor user entry
echo "[1/3] Appending fake backdoor entry to /etc/passwd..."
sudo bash -c 'echo "backdoor:x:0:0:backdoor:/root:/bin/bash" >> /etc/passwd'
sleep 2

# 2. Create an unexpected file in /usr/bin (attacker dropping a tool)
echo "[2/3] Dropping unexpected file in /usr/bin..."
sudo bash -c 'echo "#!/bin/bash\necho pwned" > /usr/bin/sysupdate'
sudo chmod +x /usr/bin/sysupdate
sleep 2

# 3. Modify /etc/hosts (data manipulation)
echo "[3/3] Appending rogue entry to /etc/hosts..."
sudo bash -c 'echo "10.0.0.1 malicious.example.com" >> /etc/hosts'

echo ""
echo "[+] Tampering simulation complete."
echo "    Wazuh FIM should detect all three changes within ~60 seconds."
echo ""
echo "[*] Running cleanup..."
# Cleanup
sudo sed -i '/^backdoor:/d' /etc/passwd
sudo rm -f /usr/bin/sysupdate
sudo sed -i '/malicious.example.com/d' /etc/hosts
echo "[+] Cleanup complete — files restored to original state."
echo ""
echo "[!] Check Wazuh Dashboard → Security Events for Rule 550/554 alerts."
```

Run the simulation:
```bash
chmod +x attack-simulation.sh
./attack-simulation.sh
```

> Note: Wazuh FIM checks on a frequency (default every 12 hours for non-realtime). We configured `realtime="yes"` for `/etc` in the enrollment step — alerts should fire within 60 seconds.

---

## Expected Wazuh Alert

| Field | Value |
|---|---|
| Rule ID | 550 / 554 |
| Rule Description | `Integrity checksum changed` / `File added to the system` |
| MITRE Technique | T1565.001 |
| Severity | High (7–10) |
| File | `/etc/passwd`, `/usr/bin/sysupdate`, `/etc/hosts` |
| Agent | wazuh-agent |

> **Screenshot checkpoint:** Screenshot of FIM tampering alert in Wazuh — save as `screenshots/06-fim-tampering-alert.png`

---

## Custom Enhancement Rule

Add to `/var/ossec/etc/rules/local_rules.xml` on the **Wazuh Server**:

```xml
<!-- Custom FIM rule: critical file modification -->
<group name="syscheck,fim,">
  <rule id="100003" level="13">
    <if_sid>550</if_sid>
    <match>/etc/passwd|/etc/shadow|/etc/sudoers</match>
    <description>CRITICAL: Sensitive system file modified — $(file). Possible persistence or privilege escalation attempt.</description>
    <mitre>
      <id>T1565.001</id>
      <id>T1548.003</id>
    </mitre>
    <group>attack,persistence,privilege_escalation,</group>
  </rule>
</group>
```

---

## Remediation

```bash
# Check who modified the file and when
sudo ausearch -f /etc/passwd --start today

# Verify /etc/passwd integrity against backup
sudo diff /etc/passwd /etc/passwd-

# Restore from backup if corrupted
sudo cp /etc/passwd- /etc/passwd

# Check for unexpected binaries in system paths
sudo find /usr/bin /usr/sbin -newer /etc/passwd -ls
```
