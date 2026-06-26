#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "docker-compose.yml" ]; then
  echo "ERROR: run from repo root"
  exit 1
fi

echo "Checking stack healthy state..."

docker compose ps

python - <<'PY'
import json
import subprocess
import sys

expected = {"neo4j", "weaviate", "api", "web"}

result = subprocess.run(
    ["docker", "compose", "ps", "--format", "json"],
    text=True,
    capture_output=True,
    check=True,
)

services = {}
for line in result.stdout.splitlines():
    line = line.strip()
    if not line:
        continue
    item = json.loads(line)
    services[item.get("Service")] = item

missing = expected - set(services)
if missing:
    print(f"Missing services: {sorted(missing)}")
    sys.exit(1)

for name in sorted(expected):
    state = services[name].get("Health") or services[name].get("State") or ""
    status = str(state).lower()
    if "healthy" not in status:
        print(f"{name} is not healthy: {services[name]}")
        sys.exit(1)

print("All services are healthy.")
PY

echo "Checking api /healthz..."
docker compose exec -T api python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz', timeout=5)"

echo "Checking web can reach api via Compose DNS..."
docker compose exec -T web node -e "fetch('http://api:8000/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

echo "Stack healthcheck complete: healthy."
