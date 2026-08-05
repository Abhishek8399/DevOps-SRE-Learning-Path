#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
COMPOSE="$DIR/compose.yaml"
UID_NOW="$(id -u)"
STATE="/tmp/reliability-atlas-les0056-postgres-$UID_NOW"
PROJECT="reliabilityatlasles0056$UID_NOW"
SENTINEL="$STATE/.les0056-sentinel"
ALLOWED='^(\.les0056-sentinel|db_password|lock-holder\.txt|lock-waiter\.txt|deadlock-a\.txt|deadlock-b\.txt|connections-[0-9]+\.txt|connection-rejected\.txt|reliability\.dump)$'

die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
compose(){ LAB_STATE_DIR="$STATE" COMPOSE_PROJECT_NAME="$PROJECT" docker compose -f "$COMPOSE" "$@"; }

guard_state(){
  [[ "$STATE" == "/tmp/reliability-atlas-les0056-postgres-$UID_NOW" ]]||die unsafe-root
  [[ -d "$STATE" && ! -L "$STATE" ]]||die state
  [[ "$(stat -c %u "$STATE")" == "$UID_NOW" ]]||die unsafe-owner
  [[ -f "$SENTINEL" && ! -L "$SENTINEL" ]]||die sentinel
  [[ "$(<"$SENTINEL")" == "les0056:$UID_NOW" ]]||die sentinel
  while IFS= read -r -d '' entry; do
    [[ ! -L "$entry" ]]||die child-symlink
    [[ "$(basename -- "$entry")" =~ $ALLOWED ]]||die unexpected-artifact
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  (( UID_NOW > 0 ))||die root
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release||die ubuntu
  grep -Eq '^VERSION_ID="?24\.04' /etc/os-release||die version
  [[ -z "${PGPASSWORD:-}${PGPASSFILE:-}${PGSERVICE:-}${DATABASE_URL:-}${POSTGRES_PASSWORD:-}" ]]||die credential
  command -v docker >/dev/null||die docker
  command -v python3 >/dev/null||die python
  docker compose version >/dev/null||die compose
  docker info >/dev/null 2>&1||die daemon
  grep -Fq 'postgres:18.4-bookworm@sha256:05f40072be9e1568469812836a2dc2780158ba9352a825282e59a1533127d08c' "$COMPOSE"||die image-pin
  printf 'doctor=pass runtime=postgresql-18.4-local-only\n'
}

need(){
  doctor >/dev/null
  guard_state
  [[ "$(compose ps --status running --services)" == "postgres" ]]||die container-state
  compose exec -T postgres pg_isready -U lab_admin -d reliability >/dev/null||die readiness
}

psql_admin(){
  compose exec -T postgres psql -X --set=ON_ERROR_STOP=1 -U lab_admin -d reliability "$@"
}

setup(){
  doctor
  [[ ! -e "$STATE" && ! -L "$STATE" ]]||die exists
  [[ -z "$(docker ps -aq --filter "label=com.docker.compose.project=$PROJECT")" ]]||die project-exists
  mkdir -m 0700 "$STATE"
  printf 'les0056:%s\n' "$UID_NOW" >"$SENTINEL"
  python3 -c 'import secrets; print(secrets.token_urlsafe(36))' >"$STATE/db_password"
  chmod 0600 "$SENTINEL" "$STATE/db_password"
  compose config --quiet
  compose up -d --wait
  need
  printf 'setup=pass project=%s host_ports=none rows=100000\n' "$PROJECT"
}

status(){
  need
  psql_admin --tuples-only --no-align --command \
    "SELECT 'version='||current_setting('server_version')||' orders='||(SELECT count(*) FROM orders)||' connections='||(SELECT count(*) FROM pg_stat_activity);"
}

plan_before(){
  need
  psql_admin --file /dev/stdin <"$DIR/scenarios/plan.sql"
}

add_index(){
  need
  psql_admin --command \
    "CREATE INDEX IF NOT EXISTS orders_customer_created_idx ON orders(customer_id, created_at DESC) INCLUDE(status,total_cents); ANALYZE orders;"
  printf 'index=pass name=orders_customer_created_idx\n'
}

plan_after(){ plan_before; }

lock_wait(){
  need
  (psql_admin --command "BEGIN; SELECT account_id FROM accounts WHERE account_id=1 FOR UPDATE; SELECT pg_sleep(3); COMMIT;" >"$STATE/lock-holder.txt" 2>&1)&
  local holder=$!
  sleep 0.7
  set +e
  psql_admin --command "SET lock_timeout='500ms'; UPDATE accounts SET balance_cents=balance_cents WHERE account_id=1;" >"$STATE/lock-waiter.txt" 2>&1
  local waiter_rc=$?
  set -e
  wait "$holder"
  (( waiter_rc != 0 ))||die lock-not-observed
  grep -Eqi 'lock timeout|canceling statement due to lock timeout' "$STATE/lock-waiter.txt"||die lock-evidence
  printf 'lock_wait=pass waiter_timeout=true holder_committed=true\n'
}

deadlock(){
  need
  set +e
  (psql_admin --command "BEGIN; UPDATE accounts SET balance_cents=balance_cents WHERE account_id=1; SELECT pg_sleep(1); UPDATE accounts SET balance_cents=balance_cents WHERE account_id=2; COMMIT;" >"$STATE/deadlock-a.txt" 2>&1)&
  local a=$!
  (psql_admin --command "BEGIN; UPDATE accounts SET balance_cents=balance_cents WHERE account_id=2; SELECT pg_sleep(1); UPDATE accounts SET balance_cents=balance_cents WHERE account_id=1; COMMIT;" >"$STATE/deadlock-b.txt" 2>&1)&
  local b=$!
  wait "$a"; local a_rc=$?
  wait "$b"; local b_rc=$?
  set -e
  (( (a_rc == 0 && b_rc != 0) || (a_rc != 0 && b_rc == 0) ))||die deadlock-outcome
  grep -Eqi 'deadlock detected' "$STATE/deadlock-a.txt" "$STATE/deadlock-b.txt"||die deadlock-evidence
  printf 'deadlock=pass victim_count=1 survivor_committed=true\n'
}

connections(){
  need
  local -a pids=()
  local i
  for i in $(seq 1 25); do
    (compose exec -T postgres psql -X --set=ON_ERROR_STOP=1 -U app_user -d reliability \
      --command "SELECT pg_sleep(4);" >"$STATE/connections-$i.txt" 2>&1)&
    pids+=("$!")
  done
  sleep 1
  set +e
  compose exec -T postgres psql -X --set=ON_ERROR_STOP=1 -U app_user -d reliability \
    --command "SELECT 1;" >"$STATE/connection-rejected.txt" 2>&1
  local rejected=$?
  set -e
  for i in "${pids[@]}"; do wait "$i"||true; done
  (( rejected != 0 ))||die connection-limit-not-observed
  grep -Eqi 'remaining connection slots are reserved|too many clients' "$STATE/connection-rejected.txt"||die connection-evidence
  printf 'connections=pass normal_slots_exhausted=true admin_reserve_preserved=true\n'
}

backup_restore(){
  need
  compose exec -T postgres pg_dump -U lab_admin -d reliability --format=custom >"$STATE/reliability.dump"
  [[ -s "$STATE/reliability.dump" ]]||die dump-empty
  compose exec -T postgres dropdb -U lab_admin --if-exists restore_test
  compose exec -T postgres createdb -U lab_admin restore_test
  compose exec -T postgres pg_restore -U lab_admin -d restore_test --exit-on-error <"$STATE/reliability.dump"
  local result
  result="$(compose exec -T postgres psql -X --tuples-only --no-align -U lab_admin -d restore_test \
    --command "SELECT (SELECT count(*) FROM orders)=100000 AND (SELECT count(*) FROM order_ledger)=1000;")"
  [[ "$result" == "t" ]]||die restore-validation
  compose exec -T postgres dropdb -U lab_admin restore_test
  printf 'backup_restore=pass format=custom business_validation=true\n'
}

inject_unknown(){ need; printf 'unexpected\n' >"$STATE/unexpected"; }
clear_unknown(){
  [[ "$STATE" == "/tmp/reliability-atlas-les0056-postgres-$UID_NOW" && -d "$STATE" && ! -L "$STATE" ]]||die unsafe-clear
  [[ "$(stat -c %u "$STATE")" == "$UID_NOW" ]]||die unsafe-owner
  [[ -f "$STATE/unexpected" && ! -L "$STATE/unexpected" ]]||die unknown-shape
  rm -f -- "$STATE/unexpected"
  need
}

cleanup(){
  need
  compose down --remove-orphans --volumes
  [[ -z "$(docker ps -aq --filter "label=com.docker.compose.project=$PROJECT")" ]]||die resources-remain
  guard_state
  rm -rf -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]]||die state-remains
  printf 'cleanup=pass project_absent=true state_absent=true\n'
}

case "${1:-}" in
  doctor) doctor;;
  setup) setup;;
  status) status;;
  plan-before) plan_before;;
  add-index) add_index;;
  plan-after) plan_after;;
  lock-wait) lock_wait;;
  deadlock) deadlock;;
  connections) connections;;
  backup-restore) backup_restore;;
  inject-unknown) inject_unknown;;
  clear-unknown) clear_unknown;;
  cleanup) cleanup;;
  *) exit 2;;
esac
