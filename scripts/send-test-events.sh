#!/bin/bash
# NeuroStrike - Send Test Events to Splunk HEC
# Simulates SSH brute force attack detection

SPLUNK_IP="192.168.56.30"
SPLUNK_HEC_PORT="8088"
SPLUNK_HEC_TOKEN="898de8a7-e7e4-4f96-9044-e2d46d772bd3"
EVENT_COUNT=${1:-5}

echo "============================================"
echo "  NeuroStrike - Sending Test Events"
echo "============================================"
echo "Target: https://$SPLUNK_IP:$SPLUNK_HEC_PORT"
echo "Events: $EVENT_COUNT"
echo ""

for i in $(seq 1 $EVENT_COUNT); do
  RESPONSE=$(curl -sk \
    -H "Authorization: Splunk $SPLUNK_HEC_TOKEN" \
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
        \"attempt_count\": $((i * 10)),
        \"mitre_tactic\": \"Credential Access\",
        \"mitre_technique\": \"T1110.001\"
      },
      \"index\": \"notable\"
    }" \
    https://$SPLUNK_IP:$SPLUNK_HEC_PORT/services/collector/event)

  if echo "$RESPONSE" | grep -q '"code":0'; then
    echo "  ✅ Event $i sent successfully"
  else
    echo "  ❌ Event $i failed: $RESPONSE"
  fi
done

echo ""
echo "Done! Check AiSOC dashboard for alerts."
echo "Trigger manual poll if needed:"
echo "  docker exec aisoc-connectors python3 -m app.poll"
