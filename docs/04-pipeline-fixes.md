# 04 — Pipeline Fixes & Troubleshooting

## Overview
This document covers the major issues encountered during the NeuroStrike lab build and how they were resolved. This is the most valuable section for anyone building a similar lab.

---

## Issue 1 — Demo Banner Stuck on Dashboard

**Symptom:** Yellow banner showing "Demo data resets daily" even after self-hosting.

**Cause:** Browser session holding demo token from tryaisoc.com.

**Fix:**
1. Open browser DevTools (F12)
2. Application → Cookies → Delete all for `192.168.56.50:3001`
3. Clear Local Storage
4. Hard refresh: `Ctrl+Shift+R`
5. Use InPrivate/Incognito window for clean session

---

## Issue 2 — Agents Container Crashing (Missing API Key)

**Symptom:** `aisoc-agents` showing `Restarting` status.

**Cause:** `ANTHROPIC_API_KEY` not set in docker-compose.yml.

**Diagnosis:**
```bash
grep -A30 "container_name: aisoc-agents" ~/AiSOC/docker-compose.yml | grep "ANTHROPIC"
```

**Fix:**
```bash
sed -i 's|ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:-}|ANTHROPIC_API_KEY: your-key|' \
  ~/AiSOC/docker-compose.yml
docker compose up -d agents
```

---

## Issue 3 — Kafka DNS Resolution Failure

**Symptom:** Services failing with `Unable to connect to kafka:29092`.

**Cause:** Docker internal DNS not resolving `kafka` hostname for some containers.

**Diagnosis:**
```bash
docker exec aisoc-fusion cat /etc/hosts | grep kafka
KAFKA_IP=$(docker inspect aisoc-kafka --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo $KAFKA_IP
```

**Fix:** Add `extra_hosts` to affected services in docker-compose.yml:
```yaml
extra_hosts:
  - "kafka:172.18.0.12"
```

Apply to: `aisoc-fusion`, `aisoc-ingest`, `aisoc-ueba`, `aisoc-connectors`, `aisoc-agents`

**Python script to add to all services at once:**
```bash
python3 -c "
import re
with open('/home/johnc/AiSOC/docker-compose.yml', 'r') as f:
    content = f.read()

KAFKA_IP = '$(docker inspect aisoc-kafka --format \"{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}\")'
extra_hosts = '    extra_hosts:\n      - \"kafka:' + KAFKA_IP + '\"\n'
services = ['aisoc-fusion', 'aisoc-ingest', 'aisoc-agents', 'aisoc-connectors', 'aisoc-ueba']

for service in services:
    pattern = r'(container_name: ' + service + r'.*?)(    networks:\n      - aisoc\n)'
    replacement = r'\1' + extra_hosts + r'\2'
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('/home/johnc/AiSOC/docker-compose.yml', 'w') as f:
    f.write(content)
print('Done!')
"
```

**Important:** After any Docker restart, Kafka's IP may change. Update with:
```bash
KAFKA_IP=$(docker inspect aisoc-kafka --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
sed -i "s|kafka:172.18.0.XX|kafka:${KAFKA_IP}|g" ~/AiSOC/docker-compose.yml
docker compose up -d --force-recreate fusion ueba ingest-worker connectors agents
```

---

## Issue 4 — Kafka Not Listening on Port 29092

**Symptom:** `dial tcp 172.18.0.12:29092: connect: connection refused`

**Cause:** `KAFKA_LISTENERS` environment variable missing — Kafka only binding to port 9092.

**Fix:** Add to Kafka service in docker-compose.yml:
```yaml
environment:
  KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:29092,PLAINTEXT_HOST://0.0.0.0:9092
  KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
```

Recreate:
```bash
docker compose up -d --force-recreate kafka
sleep 30
docker logs aisoc-kafka 2>&1 | grep "Awaiting socket"
```

Expected: `Awaiting socket connections on 0.0.0.0:29092`

---

## Issue 5 — Zookeeper Not Running

**Symptom:** Kafka crashes with `Unable to connect to zookeeper:2181`.

**Fix:**
```bash
docker start aisoc-zookeeper
sleep 15
docker restart aisoc-kafka
sleep 20
docker ps | grep -E "kafka|zookeeper"
```

---

## Issue 6 — API 500 Errors (Postgres/Neo4j DNS)

**Symptom:** Login returns 500, API logs show `Temporary failure in name resolution`.

**Fix:** Restart infrastructure services in order:
```bash
docker restart aisoc-postgres aisoc-neo4j aisoc-redis
sleep 20
docker restart aisoc-api
sleep 30
docker logs aisoc-api --tail 5
```

Expected: `Application startup complete`

---

## Issue 7 — Kafka Topic Mismatch (Critical Fix)

**Symptom:** Events ingested (accepted=5) but 0 alerts generated.

**Root Cause:** 
- `aisoc-ingest` publishes to: `aisoc.raw_events`
- `aisoc-fusion` was consuming from: `aisoc.alerts.raw` (wrong topic!)

**Diagnosis:**
```bash
# Check what topics exist
docker exec aisoc-kafka sh -c "find / -name 'kafka-topics*' 2>/dev/null | head -3"

# Check fusion's input topic config
docker exec aisoc-fusion grep -r "kafka_topic_alerts_raw" /app --include="*.py" | head -5
```

**Fix:** Set `KAFKA_TOPIC_ALERTS_RAW` env var in fusion service:
```yaml
environment:
  KAFKA_BOOTSTRAP_SERVERS: kafka:29092
  KAFKA_TOPIC_ALERTS_RAW: aisoc.raw_events  # Add this line
```

Apply:
```bash
docker compose up -d --force-recreate fusion
docker exec aisoc-fusion env | grep TOPIC
```

Expected: `KAFKA_TOPIC_ALERTS_RAW=aisoc.raw_events`

---

## Issue 8 — Port 8001 Conflict (socat)

**Symptom:** `aisoc-agents` fails to start with port 8001 already in use.

**Fix:**
```bash
sudo kill $(sudo ss -tlnp | grep 8001 | grep -oP 'pid=\K[0-9]+')
docker compose up -d --force-recreate agents
```

---

## Issue 9 — Alerts Not Persisting to Database

**Symptom:** Fusion processing alerts but `SELECT count(*) FROM alerts` returns 0.

**Root Cause:** `aisoc-ueba` service (which consumes `aisoc.alerts.fused`) failing due to missing Python dependencies.

**Workaround:** Direct DB insertion script:
```bash
POSTGRES_IP=$(docker inspect aisoc-postgres --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

docker exec aisoc-fusion python3 -c "
import asyncio, json, asyncpg
from aiokafka import AIOKafkaConsumer
from datetime import datetime

async def persist():
    db = await asyncpg.connect('postgresql://aisoc:PASSWORD@${POSTGRES_IP}/aisoc')
    consumer = AIOKafkaConsumer('aisoc.alerts.fused', bootstrap_servers='kafka:29092', 
                                 group_id='persist-consumer', auto_offset_reset='earliest')
    await consumer.start()
    count = 0
    try:
        async for msg in consumer:
            d = json.loads(msg.value)
            a = d.get('alert', {})
            created = datetime.fromisoformat(a['created_at'].replace('Z','')) if a.get('created_at') else datetime.utcnow()
            await db.execute(
                'INSERT INTO alerts (id, tenant_id, title, description, severity, status, connector_type, affected_ips, raw_event, created_at) VALUES (\$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10) ON CONFLICT (id) DO NOTHING',
                a['id'], a['tenant_id'], a['title'], a.get('description',''), 
                a.get('severity','medium'), a.get('status','new'), a.get('source','splunk'),
                json.dumps([a.get('src_ip','')]), json.dumps({}), created)
            count += 1
            if count >= 5: break
    finally:
        await consumer.stop()
        await db.close()
    print(f'Inserted {count} alerts!')

asyncio.run(persist())
"
```

---

## Health Check Commands

Quick status check for all services:
```bash
# All container statuses
docker ps -a --format "{{.Names}}\t{{.Status}}" | grep aisoc

# Check alerts in DB
docker exec aisoc-postgres psql -U aisoc -d aisoc -c "SELECT count(*), severity FROM alerts GROUP BY severity;"

# Check Kafka topics
docker exec aisoc-kafka sh -c "find / -name 'kafka-topics*' 2>/dev/null | head -1 | xargs -I{} {} --bootstrap-server localhost:9092 --list"

# Check connector health
docker exec aisoc-postgres psql -U aisoc -d aisoc -c "SELECT name, health_status, events_ingested FROM connectors;"
```

---

## Lessons Learned

1. **Docker DNS is unreliable** — always use `extra_hosts` with static IPs for critical services
2. **Kafka IPs change on restart** — build a startup script to update IPs automatically
3. **Use InPrivate browser** — avoids session contamination from demo mode
4. **Check topic names carefully** — a single topic name mismatch blocks the entire pipeline
5. **Restart order matters** — always start Zookeeper → Kafka → dependent services

---

## Next Step
→ [05 — Attack Scenarios](05-attack-scenarios.md)
