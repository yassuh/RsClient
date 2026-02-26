#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-same-distro}"
COMPOSE_FILES=(-f "${ROOT_DIR}/docker-compose.yml")

if [[ "${MODE}" == "cross-distro" ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.cross-distro.yml")
elif [[ "${MODE}" == "wsl-wayland" ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.wslg.yml")
elif [[ "${MODE}" != "same-distro" ]]; then
  echo "Usage: bash scripts/verify-gpu.sh [same-distro|cross-distro|wsl-wayland]"
  exit 1
fi
if [[ -e /dev/dri ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.dri.yml")
fi

docker compose "${COMPOSE_FILES[@]}" run --rm --entrypoint /bin/bash realityscan -lc "nvidia-smi && vulkaninfo --summary"
