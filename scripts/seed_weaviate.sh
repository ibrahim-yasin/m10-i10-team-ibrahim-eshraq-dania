#!/usr/bin/env bash
set -euo pipefail

# Run this script from the repo root: the directory containing docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
  echo "ERROR: Run this script from the repo root, not from scripts/."
  exit 1
fi

if [ ! -f "api/seed_weaviate.py" ]; then
  echo "ERROR: api/seed_weaviate.py not found"
  exit 1
fi

if [ ! -f "api/seed_chunks.json" ]; then
  echo "ERROR: api/seed_chunks.json not found"
  exit 1
fi

echo "Seeding Weaviate from inside the api container..."
echo "Expected runtime: ~10-45 seconds depending on embedding/cache state."

docker compose exec -T api sh -lc 'cd /app/api && python seed_weaviate.py'

echo "Weaviate seed complete."
