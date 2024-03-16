# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

########################################################################
# Config
########################################################################

declare -gxri DEBUG=${DEBUG:-0}
declare -gxri REBUILD_TAGS=${REBUILD_TAGS:-0}
declare -gxri NUMBER_OF_TAGS=${NUMBER_OF_TAGS:-10}

declare -gx OUTPUT_PREFIX="[boot] "
declare -gx BUILD_DATE
BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

declare -gxr DOCKER_TAG_SOURCE=${DOCKER_TAG_SOURCE:-hub}
declare -gxr DOCKER_CACHE_FOLDER=${DOCKER_CACHE_FOLDER:-/data/local/cache/ser2net-build-cache}
declare -gxr DOCKER_BUILDX_NAME=${DOCKER_BUILDX_NAME:-ser2net-builder}
declare -gxr PUBLIC_ECR_REGISTRY=${PUBLIC_ECR_REGISTRY:-jippi}

# Repository names
declare -gxr REPO_NAME_GITHUB=${REPO_NAME_GITHUB:-jippi/docker-ser2net}
declare -gxr REPO_NAME_ECR=${REPO_NAME_ECR:-jippi/ser2net}
declare -gxr REPO_NAME_DOCKER_HUB=${REPO_NAME_DOCKER_HUB:-jippi/ser2net}

# List of releases to skip
declare -gxrA SKIP=(
    [4.3.13]="doesn't build at all for some reason"
)

# Docker platforms to build the multi-arch image for
declare -gxra BUILD_PLATFORMS=(
    linux/386
    linux/amd64
    linux/amd64/v2
    linux/amd64/v3
    linux/amd64/v4
    linux/arm/v6
    linux/arm/v7
    linux/arm/v8
    linux/arm64
    linux/arm64/v8
)
