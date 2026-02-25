#!/usr/bin/env bash
set -euo pipefail

for cmd in nvidia-smi docker vulkaninfo; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}"
    exit 1
  fi
done

echo "== nvidia-smi =="
nvidia-smi

echo
echo "== vulkaninfo --summary =="
vulkaninfo --summary

echo
echo "== docker runtimes =="
docker info --format '{{json .Runtimes}}'