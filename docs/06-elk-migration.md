# 06 — ELK Stack Migration (Phase 2)

## Status: 🔄 In Progress

---

## Overview

Phase 2 migrates the SIEM from Splunk to the open-source ELK Stack (Elasticsearch, Logstash, Kibana), providing a fully open-source detection pipeline.

---

## Target Architecture

```
Kali Linux (attacker)
    ↓ attacks
Target Linux Server (victim)
    ↓ Filebeat agent ships logs
Logstash (log processing & enrichment)
    ↓
Elasticsearch (storage & search)
    ↓ Kibana (visualization & alerting)
    ↓ AiSOC OpenSearch connector
AiSOC (AI triage & investigation)
```

---

## Why ELK Over Splunk

| Feature | Splunk | ELK Stack |
|---------|--------|-----------|
| Cost | Licensed (free trial) | Open Source |
| Scalability | Enterprise | Highly scalable |
| Customization | Limited | Fully customizable |
| Community | Large | Very large |
| Job Market | High demand | High demand |

---

## Planned Components

### Elasticsearch
- Version: 8.x
- Purpose: Log storage and full-text search
- Port: 9200

### Logstash
- Purpose: Log ingestion, parsing, enrichment
- Receives: Filebeat agents, syslog
- Outputs: Elasticsearch

### Kibana
- Purpose: Visualization, dashboards, alerting
- Port: 5601
- Detection rules: SIGMA rules converted to Kibana alerts

### Filebeat
- Deployed on: Target Linux Server
- Ships: `/var/log/auth.log`, `/var/log/syslog`
- Detects: SSH brute force, failed logins, sudo usage

---

## AiSOC Integration

AiSOC supports OpenSearch (Elasticsearch-compatible) as a connector:

1. AiSOC → Connectors → Add → OpenSearch/Elasticsearch
2. Configure endpoint: `http://192.168.56.40:9200`
3. Set index pattern: `filebeat-*`
4. Configure alert query for security events

---

## Coming Soon

- [ ] ELK Stack deployment guide
- [ ] Filebeat configuration for target server
- [ ] Kibana detection rules (SSH brute force, port scan)
- [ ] AiSOC OpenSearch connector configuration
- [ ] Comparison: Splunk vs ELK alert quality

---

## Follow Progress

Watch this repo for Phase 2 updates!
