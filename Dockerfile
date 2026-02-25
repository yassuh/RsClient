FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all \
    DISPLAY=:0

ARG REALITYSCAN_DEB=RealityScan.deb

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl wget bzip2 xz-utils \
      x11-apps xauth \
      libgtk-3-0 libdbus-glib-1-2 libxt6 \
      libx11-xcb1 libxcb-shm0 libxcb-dri3-0 \
      libxcomposite1 libasound2 \
      libvulkan1 vulkan-tools \
      mesa-utils && \
    rm -rf /var/lib/apt/lists/*

COPY installers/${REALITYSCAN_DEB} /tmp/realityscan.deb

RUN set -eux; \
    dpkg -i /tmp/realityscan.deb || true; \
    apt-get update; \
    apt-get install -y -f; \
    dpkg -i /tmp/realityscan.deb; \
    rm -f /tmp/realityscan.deb; \
    rm -rf /var/lib/apt/lists/*

COPY scripts/container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
RUN chmod +x /usr/local/bin/container-entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/container-entrypoint.sh"]
CMD ["/opt/realityscan/bin/realityscan"]