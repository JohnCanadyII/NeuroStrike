#!/bin/bash
# NeuroStrike Health Check Script
# Run on AiSOC VM to verify all services are healthy

echo "============================================"
echo "  NeuroStrike SOC Lab - Health Check"
echo "============================================"

echo ""
echo "📦 Container Status:"
docker ps -a --format "{{.Names}}\t{{.Status}}" | grep aisoc | \
  awk '{printf "  %-30s %s\n", $1, $2}'

echo ""
echo "🗄️  Database Status:"
docker exec aisoc-postgres psql -U aisoc -d aisoc -t -c \
  "SELECT 'Alerts: ' || count(*) FROM alerts;" 2>/dev/null
docker exec aisoc-postgres psql -U aisoc -d aisoc -t -c \
  "SELECT 'Connectors: ' || count(*) || ' (' || string_agg(health_status, ', ') || ')' FROM connectors;" 2>/dev/null

echo ""
echo "📨 Kafka Topics:"
docker exec aisoc-kafka sh -c \
  "find / -name 'kafka-topics*' 2>/dev/null | head -1 | xargs -I{} {} --bootstrap-server localhost:9092 --list 2>/dev/null"

echo ""
echo "🔗 Network Connectivity:"
KAFKA_IP=$(docker inspect aisoc-kafka --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
echo "  Kafka IP: $KAFKA_IP"
POSTGRES_IP=$(docker inspect aisoc-postgres --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
echo "  Postgres IP: $POSTGRES_IP"

echo ""
echo "🌐 Web UI:"
echo "  AiSOC Dashboard: http://192.168.56.50:3001"
echo "  Splunk Web:      http://192.168.56.30:8000"

echo ""
echo "============================================"
echo "  Health check complete!"
echo "============================================"
