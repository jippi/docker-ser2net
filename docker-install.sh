#!/bin/bash

set -e

if [[ "${DEBUG}" -gt "1" ]]; then
    set -x
fi

function begin() {
    echo "🚧 $@"
}

function ok() {
    echo "✅ $@"
}

function error() {
    echo "❌ $@"
}

function run_cmd() {
    begin $1

    ${@:2}

    if [[ "$?" -eq "0" ]]
    then
        ok $1
        return
    fi

    error $1
}

TEMP_PACKAGES="build-essential wget automake libtool openipmi make pkg-config"

# command shortcuts
APT_UPDATE="apt-get update --quiet"
APT_INSTALL="apt-get install --no-install-recommends --yes"
WGET="wget"

# keep APT packages so buildkit can cache them instead
rm -f /etc/apt/apt.conf.d/docker-clean

# install basic packages needed
run_cmd "apt-update" $APT_UPDATE
run_cmd "apt-install" $APT_INSTALL $TEMP_PACKAGES tini ca-certificates

ser2net_archive="/ser2net/cache/ser2net_${VERSION}.tar.gz"
if [ ! -e "${ser2net_archive}" ]
then
    download_url="https://github.com/cminyard/ser2net/archive/refs/tags/v${VERSION}.tar.gz"
    run_cmd "Downloading ser2net tar.gz archive from ${download_url}" $WGET --output-document="${ser2net_archive}" ${download_url}
else
    ok "ser2net tar.gz archive file already exsist in ${ser2net_archive}"
fi

run_cmd "untar archive" tar zxfv ${ser2net_archive} -C /tmp
cd /tmp/ser2net-${VERSION}
run_cmd "run reconf" ./reconf
run_cmd "configure" ./configure --sysconfdir=/etc
run_cmd "make" make
run_cmd "make install" make install

run_cmd "remove temp packages" apt-get remove -y $TEMP_PACKAGES
run_cmd "remove unused packages" apt-get autoremove -y
run_cmd "clean cache" apt-get clean
run_cmd "remove tmp files" rm -rf /tmp/*
