set -e

function require_main() {
    if [ "${MAIN_LOADED}" != "1" ]; then
        echo "File should not be loaded or run directly, please use [./update.sh]"
        exit 1
    fi
}

require_main

DEBUG=${DEBUG:0}
REBUILD_TAGS=${REBUILD_TAGS:0}

if [[ "${DEBUG}" -gt "1" ]]; then
    set -x
fi

function print() {
    echo $OUTPUT_PREFIX $@
}

function debug() {
    if [[ "${DEBUG}" -gt "0" ]]; then
        echo $OUTPUT_PREFIX $@
    fi
}

function debug_begin() {
    debug "🚧 $@"
}

function debug_complete() {
    debug "✅ $@"
}

function debug_fail() {
    debug "❌ $@"
}

function load_file() {
    debug_begin "Loading $1"
    . "${ROOT_PATH}/${1}" && debug_complete "Loading $1" || (debug_fail "Loading $1" ; return 1)
}

function has_tag() {
    if [[ "${REBUILD_TAGS}" -eq "1" ]]
    then
        return 1
    fi

    check=$(echo "${DOCKER_TAGS}" | grep "^$1$")
    if [ "${check}" == "" ]; then
        return 1
    fi

    return 0
}

function docker_args_reset() {
    DOCKER_ARGS=""
}

function docker_args_append_tag_flags() {
    DOCKER_ARGS+=" --tag ${REPO_NAME_DOCKER_HUB}:$1"
    DOCKER_ARGS+=" --tag ghcr.io/${REPO_NAME_GITHUB}:$1"
    DOCKER_ARGS+=" --tag public.ecr.aws/${REPO_NAME_ECR}:$1"
}

function docker_args_append_build_flags() {
    DOCKER_ARGS+=" --pull"
    DOCKER_ARGS+=" --push"
    DOCKER_ARGS+=" --builder ${DOCKER_BUILDX_NAME}"
    DOCKER_ARGS+=" --platform linux/amd64,linux/arm64,linux/armhf"

    if [ -e "${DOCKER_CACHE_FOLDER}/index.json" ]
    then
        DOCKER_ARGS+=" --cache-from type=local,src=${DOCKER_CACHE_FOLDER}"
    fi

    DOCKER_ARGS+=" --cache-to   type=local,dest=${DOCKER_CACHE_FOLDER}"

    if [ "${DEBUG}" == "0" ]
    then
        DOCKER_ARGS+=" --quiet"
    else
        DOCKER_ARGS+=" --progress=plain"
        DOCKER_ARGS+=" --build-arg DEBUG=${DEBUG}"
    fi

    DOCKER_ARGS+=" --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    DOCKER_ARGS+=" --build-arg VERSION=$1"
}
