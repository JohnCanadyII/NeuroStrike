# 02 — Splunk Setup

## Overview
Splunk Enterprise serves as the SIEM in Phase 1, ingesting security events via HTTP Event Collector (HEC) and forwarding alerts to AiSOC.

---

## Installation

### Download Splunk Enterprise
```bash
wget -O splunk.deb "https://download.splunk.com/products/splunk/releases/latest/linux/splunk-latest-linux-2.6-amd64.deb"
sudo dpkg -i splunk.deb
sudo /opt/splunk/bin/splunk start --accept-license
sudo /opt/splunk/bin/splunk enable boot-start
```

### Access Splunk Web
- URL: `http://192.168.56.30:8000`
- Default credentials: `admin / changeme`

---

## HTTP Event Collector (HEC) Configuration

HEC allows external sources to send events directly to Splunk via HTTP/HTTPS.

### Enable HEC
1. Splunk Web → Settings → Data Inputs → HTTP Event Collector
2. Click **Global Settings**
3. Enable HEC: **On**
4. HTTP Port: **8088**
5. Save

### Create HEC Token
1. Settings → Data Inputs → HTTP Event Collector → New Token
2. Name: `aisoc-connector`
3. Source type: `_json`
4. Index: `notable`
5. Save → Copy the token

### HEC Token Used in This Lab
```
898de8a7-e7e4-4f96-9044-e2d46d772bd3
```

---

## Test HEC Connectivity

Send a test event:
```bash
curl -k -H "Authorization: Splunk 898de8a7-e7e4-4f96-9044-e2d46d772bd3" \
  -H "Content-Type: application/json" \
  -d '{"event": {"alert_name": "Test Event", "severity": "low", "message": "HEC test"}, "index": "notable"}' \
  https://192.168.56.30:8088/services/collector/event
```

Expected response:
```json
{"text":"Success","code":0}
```

---

## Send SSH Brute Force Events

Simulate SSH brute force detection:
```bash
for i in 1 2 3 4 5; do
  curl -k \
    -H "Authorization: Splunk 898de8a7-e7e4-4f96-9044-e2d46d772bd3" \
    -H "Content-Type: application/json" \
    -d "{\"event\": {
      \"alert_name\": \"SSH Brute Force $i\",
      \"severity\": \"critical\",
      \"src_ip\": \"10.0.0.$i\",
      \"dest_ip\": \"192.168.56.20\",
      \"message\": \"Failed SSH authentication attempt\"
    }, \"index\": \"notable\"}" \
    https://192.168.56.30:8088/services/collector/event
done
```

---

## AiSOC Splunk Connector Configuration

AiSOC connects to Splunk via the connector service. The connector was configured with:

| Setting | Value |
|---------|-------|
| Connector Type | Splunk SIEM |
| Host | 192.168.56.30 |
| HEC Port | 8088 |
| HEC Token | 898de8a7-e7e4-4f96-9044-e2d46d772bd3 |
| Index | notable |
| Connector ID | 3b58a4d6-ce94-4b24-90dc-2fdc2c02132a |

---

## Manual Poll Trigger

Force AiSOC to poll Splunk for new events:
```bash
docker exec aisoc-connectors python3 -c "
import asyncio, logging
logging.basicConfig(level=logging.INFO)
from app.db.engine import get_engine
from app.scheduler import ConnectorScheduler
from app.ingest_client import IngestClient
from app.security.credential_vault import get_vault
import uuid

async def test():
    s = ConnectorScheduler()
    s._engine = get_engine()
    s._ingest_client = IngestClient.from_env()
    s._vault = get_vault()
    from apscheduler.schedulers.asyncio import AsyncIOScheduler
    s._scheduler = AsyncIOScheduler(timezone='UTC')
    s._scheduler.start()
    await s.reload_jobs()
    await s._poll_one(connector_id=uuid.UUID('3b58a4d6-ce94-4b24-90dc-2fdc2c02132a'))
asyncio.run(test())
" 2>&1 | grep -E "accepted|error"
```

Expected output: `accepted=5 rejected=0 dropped=0`

---

## Next Step
→ [03 — AiSOC Deployment](03-aisoc-deployment.md)
