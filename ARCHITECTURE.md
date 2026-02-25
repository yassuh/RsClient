# Architecture

## Purpose

`RsClient` packages RealityScan Linux into a containerized deployment pattern that supports GPU acceleration and repeatable execution across Linux hosts.

## Inputs and Outputs

### Inputs

- RealityScan installer package at `installers/RealityScan.deb`
- Host GPU driver stack (NVIDIA proprietary drivers + Vulkan runtime)
- Docker + NVIDIA Container Toolkit runtime on host
- Optional `.env` overrides for host mounts and image naming

### Outputs

- Built Docker image tagged as `RS_IMAGE`
- Container runtime with mounted X11 socket and host working directory
- GPU/Vulkan diagnostics from host and container verification scripts

## Components

### `Dockerfile`

- Builds from Ubuntu 22.04
- Installs system dependencies required for RealityScan/Wine GUI + Vulkan
- Installs RealityScan from `.deb`
- Uses `scripts/container-entrypoint.sh` to run optional startup checks

### `docker-compose.yml`

- Primary service definition for same-distro deployment
- Configures GPU access (`gpus: all`) and `/dev/dri`
- Mounts X11 socket and host working directory
- Mounts Vulkan ICD path configurable via `RS_HOST_VULKAN_ICD_PATH`
- Attaches `realityscan` service to external Docker network `studio-network`

### `docker-compose.cross-distro.yml`

- Overlay for mixed distro host/container setups
- Adds explicit NVIDIA library mounts when autodiscovery fails

### `scripts/host-preflight.sh`

- Verifies host has `nvidia-smi`, `vulkaninfo`, and Docker
- Prints current GPU and runtime status

### `scripts/build-image.sh`

- Loads `.env` automatically when present
- Validates installer presence
- Builds image with configurable tag and installer filename

### `scripts/run-realityscan.sh`

- Enables local Docker X11 access (`xhost +local:docker` when available)
- Runs compose service with `up` in same-distro or cross-distro mode for restartable sessions

### `scripts/verify-gpu.sh`

- Runs `nvidia-smi` and `vulkaninfo --summary` inside container
- Used to confirm GPU passthrough and Vulkan availability post-build

### `scripts/container-entrypoint.sh`

- Executes container preflight checks unless `RS_SKIP_PREFLIGHT=1`
- Starts RealityScan process (`CMD`) after diagnostics

## Runtime Flow

1. Host preflight validates GPU/Vulkan/Docker state.
1. Image build installs RealityScan and runtime dependencies.
1. Compose `up` starts container with GPU + X11 + Vulkan mounts.
1. Entry point validates GPU/Vulkan in-container.
1. RealityScan executable is launched.

## Configuration Surface

Environment values are controlled through `.env` (copy from `.env.example`):

- `RS_IMAGE`, `RS_CONTAINER_NAME`
- `REALITYSCAN_DEB`
- `RS_HOST_DOWNLOADS`
- `RS_SKIP_PREFLIGHT`
- `RS_HOST_VULKAN_ICD_PATH`
- `RS_HOST_LIBGLX_NVIDIA_PATH`
- `RS_HOST_LIBNVIDIA_GLCORE_PATH`
