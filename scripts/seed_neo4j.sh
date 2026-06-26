#!/usr/bin/env bash
set -euo pipefail

# Run this script from the repo root: the directory containing docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
  echo "ERROR: Run this script from the repo root, not from scripts/."
  exit 1
fi

if [ ! -f "api/seed.cypher" ]; then
  echo "ERROR: api/seed.cypher not found"
  exit 1
fi

# Defaults match the usual Neo4j Compose auth: NEO4J_AUTH=neo4j/password
: "${NEO4J_USER:=neo4j}"
: "${NEO4J_PASSWORD:=Team1234}"

echo "Seeding Neo4j..."
docker compose exec -T neo4j cypher-shell \
  -u "$NEO4J_USER" \
  -p "$NEO4J_PASSWORD" \
  < api/seed.cypher

echo "Neo4j seed complete."
