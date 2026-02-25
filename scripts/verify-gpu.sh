#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-same-distro}"
COMPOSE_FILES=(-f "${ROOT_DIR}/docker-compose.yml")

if [[ "${MODE}" == "cross-distro" ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.cross-distro.yml")
fi

docker compose "${COMPOSE_FILES[@]}" run --rm --entrypoint /bin/bash realityscan -lc "nvidia-smi && vulkaninfo --summary"