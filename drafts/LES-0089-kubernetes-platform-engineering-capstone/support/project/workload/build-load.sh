#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kind_bin="${project_root}/.tools/bin/kind"
image="atlas-platform-demo:1.0.0"
docker build --check "${project_root}/workload"
docker build --tag "${image}" "${project_root}/workload"
"${kind_bin}" load docker-image --name "${CLUSTER_NAME}" "${image}"
docker image inspect "${image}" --format 'image={{.Id}} user={{.Config.User}}'
echo "workload=build-load-pass image=${image} cluster=${CLUSTER_NAME}"
