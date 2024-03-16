#syntax=docker/dockerfile:1

ARG BUILDKIT_SBOM_SCAN_CONTEXT=true

FROM debian:stable-slim

ARG BUILDKIT_SBOM_SCAN_STAGE=true

ARG TARGETPLATFORM

ARG VERSION
ENV VERSION=${VERSION}

ENV DEBIAN_FRONTEND=noninteractive

COPY --chown=root:root ["docker-install.sh", "/root"]

RUN --mount=type=cache,id=ser2net-apt-lists-${TARGETPLATFORM},target=/var/lib/apt/lists \
    --mount=type=cache,id=ser2net-apt-cache-${TARGETPLATFORM},target=/var/cache/apt \
    --mount=type=cache,id=ser2net-cache,target=/ser2net/cache,sharing=shared \
    set -ex \
    && bash /root/docker-install.sh \
    && rm /root/docker-install.sh

ENTRYPOINT ["tini", "--", "ser2net", "-d", "-l", "-c", "/etc/ser2net/ser2net.yaml"]

ARG BUILD_DATE

LABEL org.opencontainers.image.authors="Christian 'Jippi' Winther <github-ser2net@jippi.dev>"
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.description="Easy way to run ser2net on Docker"
LABEL org.opencontainers.image.documentation="https://github.com/jippi/docker-ser2net"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/jippi/docker-ser2net"
LABEL org.opencontainers.image.title="ser2net on Docker"
LABEL org.opencontainers.image.url="https://github.com/jippi/docker-ser2net"
LABEL org.opencontainers.image.vendor="Christian 'Jippi' Winther <github-ser2net@jippi.dev>"
LABEL org.opencontainers.image.version=${VERSION}
