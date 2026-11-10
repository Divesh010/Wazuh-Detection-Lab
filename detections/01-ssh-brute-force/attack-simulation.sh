#!/bin/bash
# attack-simulation.sh — Scenario 1: SSH Brute Force
# Simulates 15 failed SSH login attempts against localhost root account

TARGET_IP="127.0.0.1"
TARGET_USER="root"
ATTEMPTS=15

echo "[*] Simulating SSH brute force: $ATTEMPTS failed attempts against $TARGET_USER@$TARGET_IP"
echo "[!] Requires sshpass: sudo apt install -y sshpass"
echo ""

for i in $(seq 1 $ATTEMPTS); do
    sshpass -p "wrongpassword$i" ssh \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=2 \
        "$TARGET_USER@$TARGET_IP" 2>/dev/null
    echo "  [attempt $i/$ATTEMPTS] failed login sent"
    sleep 0.5
done

echo ""
echo "[+] Simulation complete. Open Wazuh Dashboard → Security Events to view alerts."
echo "    Expected rule: 5712 (brute force threshold), Level 10+"
