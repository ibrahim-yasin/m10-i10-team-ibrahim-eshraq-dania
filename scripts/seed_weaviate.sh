#!/usr/bin/env bash
# Seed the running Weaviate container with the chunked-docs fixture.
#
# Idempotent — the Python seeder skips chunk_ids already present.
#
# TODO (Infra-Integration lead): implement this script.
# Required:
# - Read WEAVIATE_URL from the environment (default http://localhost:8080).
# - Run the seed **inside the api container** via
#   `docker compose exec -T api python seed_weaviate.py`. The seeder needs
#   `sentence-transformers`, `weaviate-client`, and the rest of the api
#   requirements — those live in the api image, not on the host.
#   `seed_weaviate.py` is at `api/seed_weaviate.py` (the api Dockerfile
#   sets WORKDIR to /app, so `python seed_weaviate.py` resolves there).


set -euo pipefail
# Run the pre-implemented Python seeder script inside the running api container
docker compose exec -T api python seed_weaviate.py
# - Print a one-line confirmation.
echo "Weaviate database has been successfully seeded with vector embeddings."

