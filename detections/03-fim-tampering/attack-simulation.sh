#!/bin/bash
# attack-simulation.sh — Scenario 3: File Integrity Tampering
# Simulates a post-exploitation attacker modifying sensitive system files
# All changes are automatically cleaned up at the end.

echo "[*] Simulating file integrity tampering..."
echo ""

echo "[1/3] Backdoor entry in /etc/passwd..."
sudo bash -c 'echo "backdoor:x:0:0:backdoor:/root:/bin/bash" >> /etc/passwd'
sleep 2

echo "[2/3] Dropping rogue binary in /usr/bin..."
sudo bash -c 'printf "#!/bin/bash\necho pwned\n" > /usr/bin/sysupdate'
sudo chmod +x /usr/bin/sysupdate
sleep 2

echo "[3/3] Rogue /etc/hosts entry..."
sudo bash -c 'echo "10.0.0.1 malicious.example.com" >> /etc/hosts'

echo ""
echo "[+] Tampering done — Wazuh FIM alert should appear within ~60 seconds."
echo "    Waiting 10 seconds before cleanup..."
sleep 10

echo ""
echo "[*] Reverting all changes..."
sudo sed -i '/^backdoor:/d' /etc/passwd
sudo rm -f /usr/bin/sysupdate
sudo sed -i '/malicious.example.com/d' /etc/hosts
echo "[+] Cleanup complete."
echo ""
echo "[!] Check Wazuh Dashboard → Security Events for Rule 550/554 alerts."
