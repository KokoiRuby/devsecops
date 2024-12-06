#!/usr/bin/env bash

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

JSONNET=${JSONNET:-jsonnet}
GOJSONTOYAML=${GOJSONTOYAML:-gojsontoyaml}

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir manifests

# optional, but we would like to generate yaml, not json
${JSONNET} -J vendor -m manifests "${1-example.jsonnet}" | xargs -I{} sh -c "cat {} | ${GOJSONTOYAML} > {}.yaml; rm -f {}" -- {}
find manifests -type f ! -name '*.yaml' -delete

# The following script generates all components, mostly used for testing

# rm -rf all/manifests
# rm -rf development-minio
# mkdir -p all/manifests
# mkdir development-minio

# ${JSONNET} -J vendor -m ./all/manifests "${1-all.jsonnet}" | xargs -I{} sh -c "cat {} | ${GOJSONTOYAML} > {}.yaml; rm -f {}" -- {}
# find all/manifests -type f ! -name '*.yaml' -delete

# ${JSONNET} -J vendor -m ./development-minio "${1-minio.jsonnet}" | xargs -I{} sh -c "cat {} | ${GOJSONTOYAML} > {}.yaml; rm -f {}" -- {}
# find development-minio -type f ! -name '*.yaml' -delete