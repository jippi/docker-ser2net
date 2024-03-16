# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

# source optional env file
if [[ -e ".env" ]]; then
    source ".env"
fi

if [[ "${DEBUG:?}" -eq "2" ]]; then
    set -x
fi

function print() {
    echo "${OUTPUT_PREFIX:?}" "$@"
}

function debug() {
    if [[ "${DEBUG:?}" -gt "0" ]]; then
        echo "${OUTPUT_PREFIX}" "$@"
    fi
}

function debug_begin() {
    debug "🚧" "$@"
}

function debug_complete() {
    debug "✅" "$@"
}

function debug_fail() {
    debug "❌" "$@"
}

function has_tag() {
    if [[ "${REBUILD_TAGS:?}" -eq "1" ]]; then
        return 1
    fi

    check=$(echo "${DOCKER_TAGS:?}" | grep "^$1$")

    if [[ "${check}" == "" ]]; then
        return 1
    fi

    return 0
}

function docker_args_reset() {
    DOCKER_ARGS=()
}

function docker_args_append_tag_flags() {
    DOCKER_ARGS+=(--tag "${REPO_NAME_DOCKER_HUB}:$1")
    DOCKER_ARGS+=(--tag "ghcr.io/${REPO_NAME_GITHUB}:$1")
    DOCKER_ARGS+=(--tag "public.ecr.aws/${REPO_NAME_ECR}:$1")
}

function docker_args_append_build_flags() {
    DOCKER_ARGS+=(--pull)
    DOCKER_ARGS+=(--push)
    DOCKER_ARGS+=(--builder "${DOCKER_BUILDX_NAME}")
    DOCKER_ARGS+=(--sbom true)
    DOCKER_ARGS+=(--attest "type=provenance,mode=max")
    DOCKER_ARGS+=(--platform "$(array::join "," "${BUILD_PLATFORMS[@]}")")
    DOCKER_ARGS+=(--cache-to "type=local,dest=${DOCKER_CACHE_FOLDER}")
    DOCKER_ARGS+=(--cache-from "type=local,src=${DOCKER_CACHE_FOLDER}")

    if [[ "${DEBUG}" -gt "0" ]]; then
        DOCKER_ARGS+=(--progress=plain)
    else
        DOCKER_ARGS+=(--quiet)
    fi

    DOCKER_ARGS+=(--build-arg "BUILD_DATE=${BUILD_DATE:?}")
    DOCKER_ARGS+=(--build-arg "VERSION=$1")
}

function array::join() {
    local separator="$1"
    shift

    joined=$(printf "${separator}%s" "$@")
    echo "${joined#"${separator}"}"
}
