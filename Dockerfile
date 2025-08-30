FROM alpine:3.20

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

# Install WireGuard and dependencies (Alpine 3.22.1 compatible)
RUN chmod 755 /srv/* \
    && apk update \
    && apk add --no-cache \
       wireguard-tools \
       iptables \
       inotify-tools \
       qrencode \
       openresolv \
       procps \
       curl \
       iproute2 \
       bash

# Healthcheck to ensure wg0 exists
HEALTHCHECK --interval=10s --timeout=5s CMD ip link show wg0 || exit 1

# Entrypoint
CMD ["/srv/start"]
