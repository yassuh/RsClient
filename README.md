# RsClient Docker Deployment

This repository is configured to run **RealityScan for Linux** inside Docker with NVIDIA GPU passthrough.

## What this deployment provides

- Ubuntu 22.04 based container image for the RealityScan `.deb` package
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
- `scripts/`: Helper scripts for build/run/verification
- `installers/`: Place RealityScan installer package here (`.deb`)

## Setup

1. Place your RealityScan installer at `installers/RealityScan.deb`
1. Copy environment template:

```bash
cp .env.example .env
```

1. Adjust `.env` values if needed (image tag, host mounts, optional cross-distro library paths)
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

Restart stopped session:

```bash
docker compose start -a realityscan
```

## Validate GPU inside container

```bash
bash scripts/verify-gpu.sh
```

Inside the running container you can also test:

```bash
/opt/realityscan/bin/realityscan
/opt/realityscan/bin/wine CudaDeviceQuery.exe
```

## Troubleshooting

- `Cannot create Vulkan instance`: map additional NVIDIA `.so` files in `docker-compose.cross-distro.yml`.
- Black dialogs: known Wine behavior; press `Enter`.
- Epic login issues: install browser components inside the container.
