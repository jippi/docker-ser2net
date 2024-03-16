#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -x

# Ensure we keep apt cache around in a Docker environment
rm /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache

declare -ar PERSISTENT_PACKAGES=(
    ca-certificates
    libgensio-dev
    libyaml-dev
    tini
)

declare -ar TEMP_PACKAGES=(
    automake
    build-essential
    libtool
    make
    openipmi
    pkg-config
    wget
)

# install basic packages required
apt-get update
apt-get install --no-install-recommends --yes "${TEMP_PACKAGES[@]}" "${PERSISTENT_PACKAGES[@]}"

declare -xr archive="/ser2net/cache/ser2net_${VERSION:?}.tar.gz"
declare -xr download_lock="/ser2net/cache/download.lock"
declare -xr download_url="https://github.com/cminyard/ser2net/archive/refs/tags/v${VERSION}.tar.gz"

# ensure only one builder can download the tar.gz at a time
exec 100>"${download_lock}" || exit 1
flock --exclusive 100

# if file do not exists, or is invalid archive grab it again
if [[ ! -e "${archive}" ]] || ! tar --list -f "${archive}" >/dev/null; then
    wget --output-document="${archive}" "${download_url}"
fi

# release lock
flock --unlock 100

tar zxfv "${archive}" -C /tmp
cd "/tmp/ser2net-${VERSION:?}"

./reconf
./configure --sysconfdir=/etc
make -j
make -j install

apt-get remove -y "${TEMP_PACKAGES[@]}"
apt-get autoremove -y
rm -rf /tmp/*
