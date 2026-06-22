# 05 — Attack Scenarios

## Overview
This document covers attack simulations run from Kali Linux against the target server, and how they appear in the AiSOC dashboard.

---

## Attack 1 — SSH Brute Force

**MITRE ATT&CK:** T1110.001 — Brute Force: Password Guessing

**From Kali Linux:**
```bash
# Using Hydra
hydra -l root -P /usr/share/wordlists/rockyou.txt \
  ssh://192.168.56.20 -t 4 -V

# Using Medusa
medusa -h 192.168.56.20 -u admin -P /usr/share/wordlists/rockyou.txt -M ssh
```

**Expected Detection:**
- Multiple failed SSH authentication events on target server
- `/var/log/auth.log` shows repeated failures from 192.168.56.10
- AiSOC generates SSH Brute Force alert with Critical severity

---

## Attack 2 — Network Reconnaissance

**MITRE ATT&CK:** T1046 — Network Service Discovery

**From Kali Linux:**
```bash
# Port scan target
nmap -sV -sC -O 192.168.56.20

# Aggressive scan
nmap -A -T4 192.168.56.20

# Full port scan
nmap -p- 192.168.56.20
```

**Expected Detection:**
- Port scan activity in network logs
- Multiple connection attempts across ports

---

## Attack 3 — Failed Login Attempts (Web)

**MITRE ATT&CK:** T1110 — Brute Force

**From Kali Linux:**
```bash
# Using Burp Suite or manual curl
for i in $(seq 1 20); do
  curl -s -X POST http://192.168.56.20/login \
    -d "username=admin&password=password$i" > /dev/null
  echo "Attempt $i"
done
```

---

## Simulating Events Directly to Splunk

For testing the pipeline without running actual attacks:

```bash
# Send batch of SSH brute force events
for i in 1 2 3 4 5; do
  curl -k \
    -H "Authorization: Splunk 898de8a7-e7e4-4f96-9044-e2d46d772bd3" \
    -H "Content-Type: application/json" \
    -d "{
      \"event\": {
        \"alert_name\": \"SSH Brute Force Attempt $i\",
        \"severity\": \"critical\",
        \"src_ip\": \"192.168.56.10\",
        \"dest_ip\": \"192.168.56.20\",
        \"dest_port\": 22,
        \"message\": \"Multiple failed SSH authentication attempts detected\",
        \"username\": \"root\",
        \"attempt_count\": $((i * 10))
      },
      \"index\": \"notable\"
    }" \
    https://192.168.56.30:8088/services/collector/event
done
```

---

## Viewing Results in AiSOC

After running attacks and polling the connector:

1. Log into AiSOC at `http://192.168.56.50:3001`
2. Navigate to **Alerts** in the left sidebar
3. View generated alerts with:
   - Severity classification (Critical/High/Medium)
   - MITRE ATT&CK tactic mapping
   - Source IP and destination details
   - AI-generated investigation summary
4. Click **AI Copilot** to get automated investigation

---

## Expected Dashboard Metrics

After running attack scenarios:

| Metric | Expected Value |
|--------|---------------|
| Active Alerts | 5+ |
| Critical Severity | 5 |
| MITRE Tactics | Execution, Defense Evasion, Lateral Movement |
| Pipeline Status | All green |

---

## Next Step
→ [06 — ELK Migration (Phase 2)](06-elk-migration.md)
