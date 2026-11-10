# Step 1: Wazuh Server Setup (OVA — Fastest Method)

This guide sets up the Wazuh all-in-one server using the official pre-built OVA. This includes Wazuh Manager, Indexer, and Dashboard in a single VM.

---

## System Requirements

| Component | Minimum | This Lab |
|---|---|---|
| RAM (Wazuh VM) | 4 GB | **6 GB** (recommended for smooth dashboard) |
| Disk space | 50 GB | 50 GB |
| CPU cores | 2 | 2 |
| VirtualBox version | 6.1+ | Latest |

---

## 1. Download the Wazuh OVA

Download the latest official OVA from Wazuh:

```
https://packages.wazuh.com/4.x/vm/wazuh-4.9.1.ova
```

> File size: ~3.5 GB. This is the official Wazuh all-in-one appliance — no manual installation required.

---

## 2. Import the OVA into VirtualBox

1. Open **VirtualBox** → Click **File** → **Import Appliance**
2. Select the downloaded `.ova` file → Click **Next**
3. Set the following settings before importing:

   | Setting | Value |
   |---|---|
   | RAM | **6144 MB** (6 GB) |
   | CPUs | **2** |
   | Network Adapter 1 | **Host-only Adapter** (`vboxnet0`) |

4. Click **Import** and wait (~2 minutes)

---

## 3. Configure the Network

You need a Host-only network so the agent VM and your host browser can reach the Wazuh server.

**Create the Host-only network (if not exists):**
1. VirtualBox → **File** → **Host Network Manager**
2. Click **Create**
3. Set IPv4 Address: `192.168.56.1`, Mask: `255.255.255.0`
4. Enable DHCP Server

**Assign to the Wazuh VM:**
1. Right-click Wazuh VM → **Settings** → **Network**
2. Adapter 1: **Host-only Adapter** → `vboxnet0`

---

## 4. Start the Wazuh VM

1. Start the imported Wazuh VM
2. Login with default credentials:
   ```
   Username: wazuh-user
   Password: wazuh
   ```
3. Find the IP address:
   ```bash
   ip a | grep inet
   ```
   Note the `192.168.56.x` address — this is your **Wazuh Server IP**

---

## 5. Access the Wazuh Dashboard

1. On your **host machine**, open a browser
2. Navigate to:
   ```
   https://192.168.56.x     (use your Wazuh VM IP)
   ```
3. Accept the self-signed certificate warning
4. Login:
   ```
   Username: admin
   Password: admin
   ```

You should see the Wazuh Dashboard. 

> **Screenshot checkpoint:** Take a screenshot of the Wazuh Dashboard home page — save as `screenshots/01-dashboard-home.png`

---

## 6. Change Default Passwords (Security Best Practice)

```bash
# On the Wazuh VM terminal:
sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -u admin -p YourNewPassword123!
```

---

## Next Step

→ [Step 2: Ubuntu Agent VM Setup](02-ubuntu-agent-setup.md)
