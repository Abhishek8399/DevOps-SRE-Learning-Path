#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FIXTURE="$DIR/fixtures/cases.json"; MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0066-validated-ai-$(id -u)"
SENTINEL="$STATE/.les0066"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }
guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${OPENAI_API_KEY:-}${ANTHROPIC_API_KEY:-}${GOOGLE_API_KEY:-}${AZURE_OPENAI_ENDPOINT:-}${KUBECONFIG:-}" ]] || die credential-or-external-endpoint
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0066:$(id -u)" ]] || die sentinel
  fi
}
inventory(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0066|cases.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}
doctor(){ guard; [[ -r "$FIXTURE" && -r "$MODEL" ]] || die source; python3 "$MODEL" validate "$FIXTURE"; printf 'doctor=pass network=none user=%s\n' "$(id -u)"; }
setup(){
  guard; [[ ! -e "$STATE" ]] || die state-exists
  (umask 077; mkdir -- "$STATE"; printf 'LES-0066:%s\n' "$(id -u)" >"$SENTINEL"; cp -- "$FIXTURE" "$STATE/cases.json")
  guard; inventory; python3 "$MODEL" validate "$STATE/cases.json"; printf 'setup=pass state=%s\n' "$STATE"
}
status(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; local count; count="$(python3 "$MODEL" list "$STATE/cases.json" | wc -l | tr -d ' ')"; printf 'status=ready cases=%s state=%s\n' "$count" "$STATE"; }
show(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" show "$STATE/cases.json" "$1"; }
evaluate(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" evaluate "$STATE/cases.json" "$1"; }
inject_unknown(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; printf 'refuse\n' >"$STATE/unknown"; }
clear_unknown(){ guard; [[ -f "$STATE/unknown" && ! -L "$STATE/unknown" ]] || die unknown-missing; rm -- "$STATE/unknown"; }
cleanup(){ guard; [[ -e "$STATE" ]] || { printf 'cleanup=pass already_absent=true\n'; return; }; inventory; rm -- "$STATE/cases.json" "$SENTINEL"; rmdir -- "$STATE"; printf 'cleanup=pass absent=true\n'; }
case "${1:-}" in
  doctor) doctor ;; setup) setup ;; status) status ;;
  show) [[ $# -eq 2 ]] || die usage; show "$2" ;;
  evaluate) [[ $# -eq 2 ]] || die usage; evaluate "$2" ;;
  inject-unknown) inject_unknown ;; clear-unknown) clear_unknown ;; cleanup) cleanup ;;
  *) die usage ;;
esac
