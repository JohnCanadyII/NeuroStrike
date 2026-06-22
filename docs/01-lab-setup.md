# 01 — Lab Setup

## Overview
This document covers the virtual machine setup and network configuration for the NeuroStrike SOC lab.

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 16GB | 32GB |
| Storage | 200GB | 500GB |
| CPU Cores | 4 | 8+ |
| Network | Host-only adapter | Host-only adapter |

---

## Virtual Machines

### VM 1 — Kali Linux (Attacker)
- **OS:** Kali Linux 2024.x
- **RAM:** 2GB
- **Storage:** 40GB
- **IP:** 192.168.56.10
- **Purpose:** Attack simulation, penetration testing tools

### VM 2 — Target Linux Server (Victim)
- **OS:** Ubuntu Server 22.04 LTS
- **RAM:** 2GB
- **Storage:** 40GB
- **IP:** 192.168.56.20
- **Purpose:** Victim machine generating real security logs

### VM 3 — Splunk SIEM
- **OS:** Ubuntu Server 22.04 LTS
- **RAM:** 4GB
- **Storage:** 60GB
- **IP:** 192.168.56.30
- **Purpose:** Log ingestion, SIEM alerting, HEC endpoint

### VM 4 — AiSOC Platform
- **OS:** Ubuntu Server 22.04 LTS
- **RAM:** 8GB
- **Storage:** 100GB
- **IP:** 192.168.56.50
- **Purpose:** AI-powered SOC platform, 15+ Docker services

---

## Network Configuration

All VMs use a **Host-Only Network** adapter for isolated lab communication.

### VirtualBox Host-Only Network Setup
1. Open VirtualBox → File → Host Network Manager
2. Create network: `192.168.56.0/24`
3. Disable DHCP (use static IPs)
4. Assign each VM to this network adapter

### Static IP Configuration (Ubuntu)
Edit `/etc/netplan/00-installer-config.yaml`:
```yaml
network:
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.56.XX/24  # Replace XX with VM IP
      gateway4: 192.168.56.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```

Apply:
```bash
sudo netplan apply
```

---

## Connectivity Verification

Test all VMs can communicate:
```bash
# From Kali, ping all other VMs
ping -c 2 192.168.56.20  # Target
ping -c 2 192.168.56.30  # Splunk
ping -c 2 192.168.56.50  # AiSOC
```

---

## Next Step
→ [02 — Splunk Setup](02-splunk-setup.md)
