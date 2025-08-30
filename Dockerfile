FROM alpine:3.22.1

LABEL org.opencontainers.image.authors="github.com/denisix <denisix@gmail.com>" \
      org.opencontainers.image.description="Wireguard VPN"

# ENVIRONMENT VARIABLES
ENV \
  NAT=1 \
  INTERFACE=eth0 \
  PORT=55555 \
  PUBLIC_IP=proxy.imzami.com \
  DNS="45.90.28.89 45.90.30.89" \
  SUBNET_IP=10.88.0.1/16 \
  CLIENTCONTROL_NO_LOGS=1 \
  WG_CLIENTS_UNSAFE_PERMISSIONS=0 \
  TCPMSS=1400 \
  PATH="/srv:$PATH"

VOLUME /etc/wireguard

# Copy helper scripts
WORKDIR /srv
COPY start restart addclient clientcontrol /srv/

# Install dependencies
RUN apk update && apk add --no-cache \
    bash \
    iptables \
    iproute2 \
    inotify-tools \
    qrencode \
    openresolv \
    procps \
    curl \
    ca-certificates \
    linux-headers \
    libmnl-dev \
    make \
    gcc \
    musl-dev

# Install WireGuard tools (compile from source)
RUN curl -Lo /tmp/wireguard-tools.tar.xz https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-1.0.20210914.tar.xz \
    && cd /tmp \
    && tar -xf wireguard-tools.tar.xz \
    && cd wireguard-tools-* \
    && make \
    && make install \
    && cd / \
    && rm -rf /tmp/wireguard-tools*

# Make scripts executable
RUN chmod 755 /srv/*

# Healthcheck to ensure wg0 exists
HEALTHCHECK --interval=10s --timeout=5s CMD ip link show wg0 || exit 1

# Entrypoint
CMD ["/srv/start"]
