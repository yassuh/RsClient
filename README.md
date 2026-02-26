# RsClient Docker Deployment

This repository is configured to run **RealityScan for Linux** inside Docker with NVIDIA GPU passthrough.

## What this deployment provides

- Ubuntu 24.04 based container image for the RealityScan `.deb` package
- Docker Compose setup for same-distro and cross-distro host/container scenarios
- Preflight scripts for host and container GPU/Vulkan checks
- Repeatable run path for local, cloud, and CI environments

## Prerequisites on host

1. NVIDIA proprietary driver (not `nouveau`)
1. Vulkan runtime and tools
1. Docker Engine
1. NVIDIA Container Toolkit

### Quick checks

```bash
nvidia-smi
vulkaninfo --summary
docker --version
```

If `nvidia-smi` or `vulkaninfo` fail, fix host drivers/runtime before building this image.

## Repository layout

- `Dockerfile`: Builds RealityScan runtime image
- `docker-compose.yml`: Default same-distro runtime
- `docker-compose.cross-distro.yml`: Extra NVIDIA library mappings for mixed distros
- `docker-compose.wslg.yml`: WSLg Wayland display/runtime overlay
- `docker-compose.dri.yml`: Optional `/dev/dri` passthrough overlay (auto-used when available)
- `docker-compose.rsnode.yml`: RSNode service mode (`RSNode.exe`) with restart policy and published port
- `scripts/`: Helper scripts for build/run/verification
- `installers/`: Place RealityScan installer package here (`.deb`)

## Setup

1. Place your RealityScan installer at `installers/RealityScan.deb`
1. Copy environment template:

```bash
cp .env.example .env
```

1. Adjust `.env` values if needed (image tag, host mounts, optional cross-distro library paths)
1. For WSL/WSLg, keep `RS_HOST_VULKAN_ICD_PATH=/usr/share/vulkan/icd.d`
1. Ensure shared Docker network exists:

```bash
docker network create studio-network
```
1. Run host checks:

```bash
bash scripts/host-preflight.sh
```

## Build image

```bash
bash scripts/build-image.sh
```

Equivalent manual command:

```bash
docker build --build-arg REALITYSCAN_DEB=RealityScan.deb -t ubuntu-realityscan:v2.2.0.119039 .
```

## Run RealityScan

Allow local X11 forwarding:

```bash
xhost +local:docker
```

Same distro host/container:

```bash
bash scripts/run-realityscan.sh
```

Cross-distro host/container:

```bash
bash scripts/run-realityscan.sh cross-distro
```

WSLg Wayland:

```bash
bash scripts/run-realityscan.sh wsl-wayland
```

Direct compose equivalent:

```bash
docker compose -f docker-compose.yml -f docker-compose.wslg.yml up -d realityscan
```

Restart stopped session:

```bash
docker compose start -a realityscan
```

## Run RSNode Server

Start RSNode as the container main process (container exits if RSNode exits, Docker restarts it):

```bash
bash scripts/run-rsnode.sh
```

WSLg Wayland mode:

```bash
bash scripts/run-rsnode.sh wsl-wayland
```

RSNode defaults are controlled via `.env`:

```bash
RSNODE_HOST_ADDRESS=0.0.0.0
RSNODE_PORT=7878
RSNODE_LANDING_PAGE=/static/MyApp.html
```

Access from host at:

```text
http://<host-ip>:7878/static/MyApp.html
```

Watch RSNode logs:

```bash
docker compose -f docker-compose.yml -f docker-compose.rsnode.yml logs -f realityscan
```

## Validate GPU inside container

```bash
bash scripts/verify-gpu.sh
bash scripts/verify-gpu.sh wsl-wayland
```

Inside the running container you can also test:

```bash
/opt/realityscan/bin/realityscan
/opt/realityscan/bin/wine CudaDeviceQuery.exe
```

## Troubleshooting

- `Cannot create Vulkan instance`: map additional NVIDIA `.so` files in `docker-compose.cross-distro.yml`.
- On WSL, ensure `RS_HOST_VULKAN_ICD_PATH=/usr/share/vulkan/icd.d` and rebuild after Dockerfile changes.
- On WSL, `/dev/dxg` is passed through in `docker-compose.wslg.yml` for Vulkan GPU enumeration.
- On WSL, default `RS_WSLG_VK_ICD_FILENAMES` is `lvp_icd.x86_64.json` for reliable startup (CPU Vulkan fallback).
- On WSL, `gfxstream`/`virtio` ICDs may fail physical GPU enumeration in Docker containers.
- Black dialogs: known Wine behavior; press `Enter`.
- Epic login issues: install browser components inside the container.
- `no such service: realityscan/`: use `realityscan` (without the trailing slash).
- `/dev/dri: no such file or directory`: expected on many WSL setups; this project now applies `/dev/dri` only when it exists.
