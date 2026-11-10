# Step 3: Wazuh Agent Enrollment & Verification

Enroll the Ubuntu VM as a monitored agent in Wazuh.

---

## 1. Install the Wazuh Agent on the Ubuntu VM

Run all commands on the **Ubuntu Agent VM**. Replace `WAZUH_SERVER_IP` with your actual Wazuh server IP (e.g., `192.168.56.101`).

```bash
# Add Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && \
  sudo chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ \
  stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

sudo apt update

# Install agent and register it to the Wazuh manager
sudo WAZUH_MANAGER="WAZUH_SERVER_IP" apt install -y wazuh-agent

# Start and enable the agent
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

---

## 2. Verify Agent Connected in Dashboard

1. Open the Wazuh Dashboard in your browser (`https://WAZUH_SERVER_IP`)
2. Navigate to: **Agents** → You should see your Ubuntu agent listed as **Active**

> **Screenshot checkpoint:** Take a screenshot showing the agent listed as Active — save as `screenshots/02-agent-active.png`

---

## 3. Enable File Integrity Monitoring (FIM) for Scenario 3

On the **Ubuntu Agent VM**, edit the Wazuh agent config:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Find the `<syscheck>` block and ensure these directories are monitored:

```xml
<syscheck>
  <frequency>300</frequency>
  <directories check_all="yes" report_changes="yes" realtime="yes">/etc</directories>
  <directories check_all="yes" report_changes="yes" realtime="yes">/usr/bin</directories>
  <directories check_all="yes" report_changes="yes" realtime="yes">/usr/sbin</directories>
</syscheck>
```

Restart the agent to apply:
```bash
sudo systemctl restart wazuh-agent
```

---

## 4. Trigger a Test Alert

Confirm the pipeline is working end-to-end:

```bash
# Simulate a failed sudo attempt to generate a quick alert
su - testuser -c "sudo ls" 2>/dev/null || true
```

Check the Wazuh Dashboard → **Security Events** — you should see a `sudo` related alert within 30 seconds.

> **Screenshot checkpoint:** Screenshot of your first live alert — save as `screenshots/03-first-alert.png`

---

## Next Step

→ [Scenario 1: SSH Brute Force Detection](../detections/01-ssh-brute-force/README.md)
