#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  set -a
  # Load project environment defaults for build args like REALITYSCAN_DEB.
  source "${ROOT_DIR}/.env"
  set +a
fi

IMAGE_TAG="${RS_IMAGE:-ubuntu-realityscan:v2.2.0.119039}"
DEB_NAME="${REALITYSCAN_DEB:-RealityScan.deb}"
DEB_PATH="${ROOT_DIR}/installers/${DEB_NAME}"

if [[ ! -f "${DEB_PATH}" ]]; then
  echo "Expected installer at ${DEB_PATH}"
  echo "Place the RealityScan .deb in installers/ and optionally set REALITYSCAN_DEB."
  exit 1
fi

docker build \
  --build-arg REALITYSCAN_DEB="${DEB_NAME}" \
  -t "${IMAGE_TAG}" \
  "${ROOT_DIR}"
