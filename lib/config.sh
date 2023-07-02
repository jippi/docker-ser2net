set -o errexit -o nounset -o pipefail

require_main

# source optional env file
if [ -e "${ROOT_PATH}/.env" ]
then
    source "${ROOT_PATH}/.env"
fi

########################################################################
# Config
########################################################################
DEBUG=${DEBUG:-0}

DOCKER_TAG_SOURCE=${DOCKER_TAG_SOURCE:-hub}
DOCKER_CACHE_FOLDER=${DOCKER_CACHE_FOLDER:-/data/local/cache/ser2net-build-cache}
DOCKER_BUILDX_NAME=${DOCKER_BUILDX_NAME:-ser2net-builder}
PUBLIC_ECR_REGISTRY=${PUBLIC_ECR_REGISTRY:-jippi}

# Repository names
REPO_NAME_GITHUB=${REPO_NAME_GITHUB:-jippi/docker-ser2net}
REPO_NAME_ECR=${REPO_NAME_ECR:-jippi/ser2net}
REPO_NAME_DOCKER_HUB=${REPO_NAME_DOCKER_HUB:-jippi/ser2net}

# List of releases to skip
SKIP=()
