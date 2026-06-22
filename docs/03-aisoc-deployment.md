# 03 — AiSOC Deployment

## Overview
AiSOC is an open-source AI-powered Security Operations Center platform. It uses Claude (Anthropic API) for automated alert triage, correlation, and investigation.

---

## Prerequisites

- Docker and Docker Compose installed
- Minimum 8GB RAM on the AiSOC VM
- Anthropic API key (from console.anthropic.com)
- Port 3001 accessible for web UI

---

## Installation

### Clone AiSOC Repository
```bash
git clone https://github.com/beenuar/AiSOC.git ~/AiSOC
cd ~/AiSOC
```

### Configure Environment
```bash
cp .env.example .env
nano .env
```

Key variables to set:
```env
ANTHROPIC_API_KEY=your-api-key-here
AISOC_VERSION=latest
```

### Deploy Stack
```bash
docker compose up -d
```

This deploys 15+ services including:
- `aisoc-api` — REST API backend
- `aisoc-web` — React frontend
- `aisoc-agents` — AI agent pipeline
- `aisoc-fusion` — Alert fusion service
- `aisoc-ingest` — Event ingestion (Go binary)
- `aisoc-connectors` — SIEM connectors
- `aisoc-ueba` — User behavior analytics
- `aisoc-kafka` — Message bus
- `aisoc-postgres` — Primary database
- `aisoc-neo4j` — Graph database
- `aisoc-redis` — Cache layer
- `aisoc-qdrant` — Vector database
- `aisoc-realtime` — WebSocket service
- `aisoc-zookeeper` — Kafka coordinator
- `aisoc-enrichment` — Threat enrichment

---

## Access AiSOC

- URL: `http://192.168.56.50:3001`
- Default credentials: `admin@aisoc.com / secret`

**Important:** Use a private/incognito browser window to avoid demo session conflicts.

---

## Verify Services

Check all containers are running:
```bash
docker ps -a --format "{{.Names}}\t{{.Status}}" | grep aisoc
```

Expected: All services showing `Up` status.

---

## Add Anthropic API Key

The agents service requires an Anthropic API key:
```bash
sed -i 's|ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:-}|ANTHROPIC_API_KEY: your-key-here|' \
  ~/AiSOC/docker-compose.yml

docker compose up -d agents
```

Verify agents started:
```bash
docker logs aisoc-agents --tail 5
```

Expected: `Playbook store seeded` and `Application startup complete`

---

## Configure Splunk Connector

1. Log into AiSOC web UI
2. Navigate to **Connectors**
3. Click **Add Connector** → Splunk SIEM
4. Configure:
   - Host: `192.168.56.30`
   - HEC Token: `your-hec-token`
   - Index: `notable`
   - Port: `8088`
5. Save and verify **Connected** status

---

## Verify Pipeline Health

Check the Operations Funnel on the dashboard:
- Events of Interest: Should increment after polling
- Alerts Generated: Shows processed alerts
- Analyst Queue: Alerts awaiting review

---

## Next Step
→ [04 — Pipeline Fixes](04-pipeline-fixes.md)
