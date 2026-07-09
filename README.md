#  NeuroStrike 

> A fully operational Security Operations Center (SOC) lab built from scratch, integrating attack simulation, log ingestion, SIEM alerting, and AI-driven threat investigation.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg)
![Status](https://img.shields.io/badge/AI/ML%20complete-success.svg)


---

##  Architecture

```
┌─────────────────┐
│   Kali Linux    │  ← Attack simulation (SSH brute force, port scans, recon)
│   (Attacker)    │
└────────┬────────┘
         │ attacks
         ▼
┌─────────────────┐
│  Target Linux   │  ← Victim server generating real security logs
│    Server       │
└────────┬────────┘
         │ logs
         ▼
┌─────────────────┐
│  Splunk SIEM    │  ← Log ingestion via HEC, alert correlation
└────────┬────────┘
         │ alerts via Kafka
         ▼
┌─────────────────┐
│     AiSOC       │  ← AI-powered triage, case management, MITRE ATT&CK mapping
└─────────────────┘
```

---

## Project Goals

- Build a realistic home SOC lab simulating enterprise-level threat detection
- Integrate multiple security tools into a unified detection pipeline
- Leverage AI (Claude/Anthropic API) for automated alert triage and investigation
- Develop hands-on experience with tools used in real SOC environments

---

## Tech Stack

| Component | Tool | Purpose |
|-----------|------|---------|
| Attacker | Kali Linux | Attack simulation |
| Victim | Ubuntu Server | Target log generation |
| SIEM | Splunk Enterprise | Log ingestion & alerting |
| AI SOC Platform | AiSOC (open-source) | AI-driven triage |
| Message Bus | Apache Kafka | Event streaming pipeline |
| Database | PostgreSQL | Alert & case storage |
| Graph DB | Neo4j | Entity relationship mapping |
| Vector DB | Qdrant | AI embedding storage |
| Cache | Redis | Session & queue management |
| Containerization | Docker Compose | Service orchestration |
| AI Engine | Anthropic Claude API | Alert correlation & investigation |

---

## Lab Network

| VM | IP Address | Role |
|----|-----------|------|
| Kali Linux | 192.168.56.10 | Attacker |
| Target Server | 192.168.56.20 | Victim |
| Splunk | 192.168.56.30 | SIEM |
| AiSOC | 192.168.56.50 | AI SOC Platform |

---

## What Was Built
- Deployed Splunk Enterprise with HTTP Event Collector (HEC)
- Deployed AiSOC with 15+ Docker microservices
- Configured Kafka message bus for event streaming
- Resolved DNS, networking, and pipeline connectivity issues
- Integrated Anthropic Claude API for AI-powered alert processing
- Achieved end-to-end pipeline: **Attack → Splunk → Kafka → AiSOC → Dashboard**

## Pipeline Flow
```
Kali Attack → Target Server Logs → Splunk HEC → Kafka (aisoc.raw_events)
    → Alert Fusion Service → aisoc.alerts.fused → PostgreSQL → AiSOC Dashboard
```

## Key Achievements
- 5 Critical alerts generated and visible in AiSOC dashboard
-  MITRE ATT&CK tactics mapped automatically
-  AI-powered alert triage with confidence scoring
-  Real-time live feed of security events
-  Full pipeline operational with Splunk SIEM connector



---

## Repository Structure

```
NeuroStrike/
├── README.md                    # This file
├── docs/
│   ├── 01-lab-setup.md         # VM and network setup
│   ├── 02-splunk-setup.md      # Splunk configuration
│   ├── 03-aisoc-deployment.md  # AiSOC Docker deployment
│   ├── 04-pipeline-fixes.md    # Troubleshooting & fixes
│   └── 05-attack-scenarios.md  # Attack simulation guide
├── screenshots/                 # Lab screenshots
└── scripts/
    ├── send-test-events.sh     # Send test events to Splunk
    └── health-check.sh         # Check all services status
```

---

### Prerequisites
- Virtualization software (VirtualBox/VMware)
- Minimum 16GB RAM, 200GB storage
- Anthropic API key (for AiSOC AI features)

### Setup Order
1. [Lab Setup](docs/01-lab-setup.md) — Configure VMs and networking
2. [Splunk Setup](docs/02-splunk-setup.md) — Deploy and configure Splunk
3. [AiSOC Deployment](docs/03-aisoc-deployment.md) — Deploy AiSOC stack
4. [Pipeline Fixes](docs/04-pipeline-fixes.md) — Troubleshooting guide
5. [Attack Scenarios](docs/05-attack-scenarios.md) — Run attack simulations

---

## Results

| Metric | Value |
|--------|-------|
| Active Alerts | 5 |
| Critical Severity | 5 |
| MITRE Tactics Mapped | 6+ |
| Pipeline Services | 15+ |
| Total Build Time | ~3 weeks |

---

## Author

**John Canady II**
- GitHub: [@JohnCanadyII](https://github.com/JohnCanadyII)
- Project: NeuroStrike Home SOC Lab

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Disclaimer

This lab is for **educational purposes only**. All attacks are performed in an isolated virtual environment. Never use these techniques against systems you don't own or have explicit permission to test.
