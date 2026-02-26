#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-same-distro}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required"
  exit 1
fi

if [[ "${MODE}" != "same-distro" && "${MODE}" != "cross-distro" && "${MODE}" != "wsl-wayland" ]]; then
  echo "Usage: bash scripts/run-realityscan.sh [same-distro|cross-distro|wsl-wayland]"
  exit 1
fi

if [[ "${MODE}" != "wsl-wayland" ]] && command -v xhost >/dev/null 2>&1; then
  xhost +local:docker >/dev/null
fi

COMPOSE_FILES=(-f "${ROOT_DIR}/docker-compose.yml")
if [[ "${MODE}" == "cross-distro" ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.cross-distro.yml")
elif [[ "${MODE}" == "wsl-wayland" ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.wslg.yml")
fi
if [[ -e /dev/dri ]]; then
  COMPOSE_FILES+=(-f "${ROOT_DIR}/docker-compose.dri.yml")
fi

docker compose "${COMPOSE_FILES[@]}" up realityscan
