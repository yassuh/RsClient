#!/usr/bin/env bash
set -euo pipefail

if [[ "${RS_SKIP_PREFLIGHT:-0}" != "1" ]]; then
  echo "[rsclient] Running container GPU preflight checks"

  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi || echo "[rsclient] nvidia-smi failed. Check NVIDIA toolkit and --gpus all."
  else
    echo "[rsclient] nvidia-smi not found in PATH"
  fi

  if command -v vulkaninfo >/dev/null 2>&1; then
    vulkaninfo --summary || echo "[rsclient] vulkaninfo failed. Check Vulkan/NVIDIA library mounts."
  else
    echo "[rsclient] vulkaninfo not found in PATH"
  fi
fi

exec "$@"