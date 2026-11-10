#!/bin/bash
# attack-simulation.sh — Scenario 2: Unauthorized Sudo Escalation
# Simulates privilege escalation attempts by a non-sudoer user

echo "[*] Simulating unauthorized sudo escalation as 'testuser'"
echo "[!] Requires 'testuser' to exist and NOT be in sudoers (see setup guide)"
echo ""

su - testuser -c "sudo cat /etc/shadow" 2>/dev/null || true
echo "  [1/4] sudo cat /etc/shadow — attempted"

su - testuser -c "sudo /bin/bash" 2>/dev/null || true
echo "  [2/4] sudo /bin/bash — attempted"

su - testuser -c "sudo systemctl stop ssh" 2>/dev/null || true
echo "  [3/4] sudo systemctl stop ssh — attempted"

su - testuser -c "sudo useradd backdoor" 2>/dev/null || true
echo "  [4/4] sudo useradd backdoor — attempted"

echo ""
echo "[+] Simulation complete. Open Wazuh Dashboard → Security Events."
echo "    Expected rule: 5401 (unauthorized sudo), Level 9+"
