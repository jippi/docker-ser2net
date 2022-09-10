require_main

########################################################################
# Config
########################################################################

DOCKER_CACHE_FOLDER=${DOCKER_CACHE_FOLDER:-/tmp/ser2net-build-cache}
DOCKER_BUILDX_NAME=${DOCKER_BUILDX_NAME:-ser2net-builder}
PUBLIC_ECR_REGISTRY=${PUBLIC_ECR_REGISTRY:-i2s8u4z7}

# Repository names
REPO_NAME_GITHUB=${REPO_NAME_GITHUB:-jippi/docker-ser2net}
REPO_NAME_ECR=${REPO_NAME_ECR:-i2s8u4z7/ser2net}
REPO_NAME_DOCKER_HUB=${REPO_NAME_DOCKER_HUB:-jippi/ser2net}

# List of releases to skip
SKIP=()

mkdir -p ${DOCKER_CACHE_FOLDER}
