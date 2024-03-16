#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

########################################################################
# Load scripts
########################################################################

source lib/bootstrap.sh
source lib/config.sh
source lib/setup.sh

debug "Config:"
debug " DEBUG=${DEBUG}"
debug " REBUILD_TAGS=${REBUILD_TAGS}"
debug " NUMBER_OF_TAGS=${NUMBER_OF_TAGS}"

########################################################################
# Build docker images
########################################################################

# shellcheck disable=SC2312
debug "github tags: $(echo "${github_releases:?}" | xargs)"
debug "latest tag will be ${latest_release}"

for the_release in ${github_releases}; do
    the_release="${the_release:1}"

    OUTPUT_PREFIX="[${the_release}/default]"

    debug "Considering release"
    if [[ -n "${SKIP[${the_release}]+skip}" ]]; then
        print "🚫 Skipping: ${SKIP[${the_release}]}"
        continue
    fi

    tag="${the_release}"
    suffix=""

    OUTPUT_PREFIX="[${the_release}/default]"
    debug "👷 Processing"

    ####################################################################################
    # Default build
    ####################################################################################

    # shellcheck disable=SC2310
    if ! has_tag "${tag}"; then
        docker_args_reset
        docker_args_append_build_flags "${the_release}"
        docker_args_append_tag_flags "${tag}"

        if [[ "v${the_release}" == "${latest_release}" ]]; then
            OUTPUT_PREFIX="[${the_release}/default/latest]"

            print "🏷️  Tagging as latest"
            docker_args_append_tag_flags "latest${suffix}"
        fi

        print "🚧 Building container image"
        debug "$ docker buildx build ${DOCKER_ARGS[*]}" "."
        docker buildx build "${DOCKER_ARGS[@]}" "."
        print "✅ Done"
    else
        print "✅ Already build"
    fi

done

if [[ "${DEBUG:?}" != "0" ]]; then
    debug_complete "Not flushing caches in debug mode"
    exit 0
fi

print "🚧 Pruning buildx caches"
docker buildx inspect --bootstrap "${DOCKER_BUILDX_NAME}" >/dev/null && docker buildx prune --all --force --builder "${DOCKER_BUILDX_NAME}"
print "✅ Done"

if [[ -d "${DOCKER_CACHE_FOLDER}/ingest" ]]; then
    print "🚧 Pruning buildx exports"
    rm -rf -v "${DOCKER_CACHE_FOLDER}"
    print "✅ Done"
fi

# This might not be needed in once https://github.com/moby/moby/releases/tag/v26.0.0-rc2 is released!
print "🚧 Removing buildx builder to free up disk space"
docker buildx rm --force --builder "${DOCKER_BUILDX_NAME:?}" || :
print "✅ Done"
