#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

[[ "$(id -u)" -ne 0 ]] || { printf 'verification=skipped reason=root\n' >&2; exit 77; }
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
bash "$script_dir/lab.sh" check >/dev/null
output="$(bash "$script_dir/lab.sh" observe)"
grep -Fq -- 'observation=complete' <<<"$output"
grep -Fq -- 'network_request=none' <<<"$output"
grep -Fq -- 'mutation=none' <<<"$output"
grep -Fq -- 'cleanup_proven=true' < <(bash "$script_dir/lab.sh" cleanup)
printf 'verification=passed\nnetwork_request=none\nmutation=none\ncleanup_proven=true\n'
