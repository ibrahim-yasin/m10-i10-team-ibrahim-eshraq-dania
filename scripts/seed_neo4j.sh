#!/usr/bin/env bash
# Seed the running Neo4j container with the recipe fixture.
#
# Idempotent — `MERGE` and `CREATE CONSTRAINT IF NOT EXISTS` in seed.cypher
# mean repeat runs do not duplicate nodes.
#
#  (Infra-Integration lead): implement this script.
# Required:
# - Read NEO4J_USER and NEO4J_PASSWORD from the environment (loaded
#   from .env by docker compose).
# - Pipe seed.cypher into the neo4j container via
#   `docker compose exec -T neo4j cypher-shell -u $NEO4J_USER -p $NEO4J_PASSWORD`.


set -euo pipefail


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/.env"

# Execute cypher-shell inside the running neo4j container in non-TTY mode
# and pipe the seed.cypher fixture file into the database using the loaded credentials
docker compose exec -T neo4j \
  cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" \
  < "$ROOT_DIR/api/seed.cypher"
# - Print a one-line confirmation.
echo "Neo4j database has been successfully seeded with recipe fixture."