#!/usr/bin/env bash
# Poll `docker compose ps` until all four services report healthy or
# until the 90s budget expires.
#
# TODO (Infra-Integration lead): implement this script.
# - Loop with 2s sleep, up to 45 iterations.
# - Use `docker compose ps --format json` and check Health=="healthy"
#   for api, web, neo4j, weaviate.
# - Exit 0 on all healthy; exit 1 on timeout.

set -euo pipefail

echo "Starting stack healthcheck polling (90s budget)..."


for i in {1..45}; do
  STATUS_JSON="$(docker compose ps --format json)"

  COUNT="$(
    printf '%s\n' "$STATUS_JSON" | python -c '
import sys, json

raw = sys.stdin.read().strip()
if not raw:
    print(0)
    raise SystemExit

services = {"api", "web", "neo4j", "weaviate"}
healthy_services = set()

# docker compose ps --format json can appear in different shapes:
# 1) JSON array: [{"Service":"api","Health":"healthy",...}, ...]
# 2) newline-delimited JSON objects: {"Service":"api",...}\n{"Service":"web",...}
# so we support both.

items = []
try:
    parsed = json.loads(raw)
    if isinstance(parsed, list):
        items = parsed
    elif isinstance(parsed, dict):
        items = [parsed]
except json.JSONDecodeError:
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            items.append(json.loads(line))
        except json.JSONDecodeError:
            pass

for item in items:
    service = str(item.get("Service", "")).strip()
    health = str(item.get("Health", "")).strip().lower()
    if service in services and health == "healthy":
        healthy_services.add(service)

print(len(healthy_services))
'
  )"

  if [ "$COUNT" -eq 4 ]; then
    echo "Attempt $i/45: $COUNT/4 healthy"
    echo "All services healthy"
    exit 0
  fi

  echo "Attempt $i/45: $COUNT/4 healthy"
  sleep 2
done

echo "FAILED: timeout"
exit 1