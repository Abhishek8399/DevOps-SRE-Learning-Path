#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

fail() {
  printf 'cleanup: refusal: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -u)" -ne 0 ]] || fail "run as a normal user, not root"
for name in certs evidence var backups; do
  target="$PROJECT_ROOT/$name"
  [[ ! -L "$target" ]] || fail "$name must not be a symlink"
  [[ ! -e "$target" || -d "$target" ]] || fail "$name must be a directory"
done

if [[ -d "$PROJECT_ROOT/certs" ]]; then
  unexpected="$(find "$PROJECT_ROOT/certs" -mindepth 1 -maxdepth 1 \
    ! -name localhost.crt ! -name localhost.key -print -quit)"
  [[ -z "$unexpected" ]] || fail "unknown certificate artifact: $unexpected"
fi

rm -f -- "$PROJECT_ROOT/certs/localhost.crt" "$PROJECT_ROOT/certs/localhost.key"
rmdir -- "$PROJECT_ROOT/certs" 2>/dev/null || true
for name in evidence var backups; do
  target="$PROJECT_ROOT/$name"
  if [[ -d "$target" ]]; then
    unexpected="$(find "$target" -mindepth 1 -print -quit)"
    [[ -z "$unexpected" ]] || fail "preserving unknown local artifact: $unexpected"
    rmdir -- "$target"
  fi
done
printf 'cleanup=pass generated_state=absent\n'
