# syntax=docker/dockerfile:1.4

FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM

ARG VERSION=4.3.8
ENV VERSION=${VERSION}

ARG DEBUG=0
ENV DEBUG=${DEBUG}

COPY --chown=root:root ["docker-install.sh", "/root"]

RUN --mount=id=apt-lists-${TARGETPLATFORM},target=/var/lib/apt/lists,type=cache \
    --mount=id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,type=cache \
    --mount=id=ser2net-cache-${TARGETPLATFORM},target=/ser2net/cache,type=cache \
    bash /root/docker-install.sh && rm /root/docker-install.sh

ENTRYPOINT ["tini", "--", "ser2net", "-d", "-l", "-c", "/etc/ser2net/ser2net.yaml"]

ARG BUILD_DATE

LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.authors="Christian 'Jippi' Winther <github-ser2net@jippi.dev>"
LABEL org.opencontainers.image.url="https://github.com/jippi/docker-ser2net"
LABEL org.opencontainers.image.documentation="https://github.com/jippi/docker-ser2net"
LABEL org.opencontainers.image.source="https://github.com/jippi/docker-ser2net"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.vendor="Christian 'Jippi' Winther <github-ser2net@jippi.dev>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="ser2net on Docker"
LABEL org.opencontainers.image.description="Easy way to run ser2net on Docker"
