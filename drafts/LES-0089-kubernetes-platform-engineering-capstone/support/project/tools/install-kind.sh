#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
target="${project_root}/.tools/bin/kind"
url="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"

[[ "${EUID}" -ne 0 ]] || { echo "refusal=run-as-normal-user" >&2; exit 2; }
[[ "$(uname -m)" == "x86_64" ]] || { echo "unsupported_arch=$(uname -m) expected=x86_64" >&2; exit 2; }
mkdir -p "${project_root}/.tools/bin"

if [[ -x "${target}" ]] && [[ "$(sha256sum "${target}" | awk '{print $1}')" == "${KIND_LINUX_AMD64_SHA256}" ]]; then
  echo "kind_install=present version=${KIND_VERSION} checksum=pass"
  exit 0
fi

tmp="${target}.download"
trap 'rm -f "${tmp}"' EXIT
if ! curl --fail --location --silent --show-error --output "${tmp}" "${url}"; then
  echo "kind_install=retry transport=docker-pinned-python-tls" >&2
  rm -f "${tmp}"
  command -v docker >/dev/null || { echo "missing=docker-fallback" >&2; exit 1; }
  docker run --rm \
    --user "$(id -u):$(id -g)" \
    --env "KIND_DOWNLOAD_URL=${url}" \
    --volume "${project_root}/.tools/bin:/out" \
    python:3.12.11-slim-bookworm@sha256:519591d6871b7bc437060736b9f7456b8731f1499a57e22e6c285135ae657bf7 \
    python -c 'import os, urllib.request; urllib.request.urlretrieve(os.environ["KIND_DOWNLOAD_URL"], "/out/kind.download")'
fi
echo "${KIND_LINUX_AMD64_SHA256}  ${tmp}" | sha256sum --check --status ||
  { echo "kind_install=rejected reason=checksum" >&2; exit 1; }
chmod 0755 "${tmp}"
mv "${tmp}" "${target}"
trap - EXIT
"${target}" version
echo "kind_install=pass version=${KIND_VERSION} checksum=pass path=${target}"
