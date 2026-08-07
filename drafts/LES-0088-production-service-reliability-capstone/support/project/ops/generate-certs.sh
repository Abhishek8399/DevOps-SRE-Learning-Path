#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
CERT_ROOT="$PROJECT_ROOT/certs"

fail() {
  printf 'certs: refusal: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -u)" -ne 0 ]] || fail "run as a normal user, not root"
command -v openssl >/dev/null 2>&1 || fail "openssl is required"
[[ ! -L "$CERT_ROOT" ]] || fail "cert directory must not be a symlink"
if [[ -e "$CERT_ROOT" ]] && [[ -n "$(find "$CERT_ROOT" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  fail "cert directory must be absent or empty"
fi
install -d -m 0700 "$CERT_ROOT"
umask 077
openssl req -x509 -newkey rsa:3072 -sha256 -nodes -days 7 \
  -subj '/CN=localhost' \
  -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1' \
  -keyout "$CERT_ROOT/localhost.key" \
  -out "$CERT_ROOT/localhost.crt" >/dev/null 2>&1
chmod 0600 "$CERT_ROOT/localhost.key"
chmod 0644 "$CERT_ROOT/localhost.crt"
openssl x509 -in "$CERT_ROOT/localhost.crt" -noout -checkend 60 >/dev/null
printf 'certs=pass path=%s lifetime_days=7 trust=local-self-signed\n' "$CERT_ROOT"
