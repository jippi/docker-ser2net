#!/usr/bin/env bash

set -e
set -o pipefail

MAIN_LOADED=1
ROOT_PATH="$( dirname -- "$0"; )";
OUTPUT_PREFIX="[boot] "

########################################################################
# Config
########################################################################

DEBUG=${DEBUG:-0}
REBUILD_TAGS=${REBUILD_TAGS:-0}
NUMBER_OF_TAGS=${NUMBER_OF_TAGS:-10}

########################################################################
# Load libraries
########################################################################

source "${ROOT_PATH}/lib/bootstrap.sh"

load_file lib/config.sh
load_file lib/setup.sh

debug "Config:"
debug " ROOT_PATH=${ROOT_PATH}"
debug " REBUILD_TAGS=${REBUILD_TAGS}"
debug " NUMBER_OF_TAGS=${NUMBER_OF_TAGS}"

########################################################################
# Build docker images
########################################################################

debug "github tags: $(echo $github_releases | xargs)"
debug "latest tag will be ${latest_release}"

for the_release in $github_releases
do
    the_release="${the_release:1}"

    OUTPUT_PREFIX="[${the_release}/default]"

    debug "Considering release"
    if [[ " ${SKIP[*]} " =~ " ${the_release} " ]]
    then
        print "Skipping ....";
        continue
    fi

    tag="${the_release}"
    suffix=""

    OUTPUT_PREFIX="[${the_release}/default]"
    debug "👷 Processing"

    ####################################################################################
    # Default build
    ####################################################################################

    if ! has_tag $tag
    then
        docker_args_reset
        docker_args_append_build_flags $the_release
        docker_args_append_tag_flags $tag

        if [ "v${the_release}" == "${latest_release}" ]
        then
            OUTPUT_PREFIX="[${the_release}/default/latest]"

            print "🏷️  Tagging as latest"
            docker_args_append_tag_flags "latest${suffix}"
        fi

        print "🚧 Building container image"
        docker buildx build $DOCKER_ARGS $ROOT_PATH
        print "✅ Done"
    else
        print "✅ Already build"
    fi

done

if [ "$DEBUG" != "0" ]
then
    debug_complete "Not flushing caches in debug mode"
    exit 0
fi

print "🚧 Pruning buildx caches"
docker buildx prune --all --force --builder $DOCKER_BUILDX_NAME
print "✅ Done"

if [ -d "${DOCKER_CACHE_FOLDER}" ]
then
    if [ -d "${DOCKER_CACHE_FOLDER}/ingest" ]
    then
        print "🚧 Pruning buildx exports"
        rm -rf -v "${DOCKER_CACHE_FOLDER}"
        print "✅ Done"
    else
        print "❌ \$DOCKER_CACHE_FOLDER [$DOCKER_CACHE_FOLDER] does not have an /ingest subfolder, might not be a cache folder after all?"
    fi
else
    print "❌ \$DOCKER_CACHE_FOLDER [$DOCKER_CACHE_FOLDER] is not a directory"
fi
