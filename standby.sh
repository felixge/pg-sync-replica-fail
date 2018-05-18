#!/usr/bin/env bash
set -eu

pg_ctl -m fast -w stop
rm -rf "$PGDATA/"*

pg-wait.sh primary

pg_basebackup -D "$PGDATA" -h primary -U postgres -v -P -X stream

cat > "$PGDATA/recovery.conf" <<EOF
standby_mode = 'on'
primary_conninfo = 'host=primary port=5432 user=postgres password=$PGPASSWORD application_name=standby'
recovery_target_timeline = 'latest'
trigger_file = '/tmp/pg.trigger'
EOF

if [ "${SLOT_NAME:-}" != "" ]; then
  echo "-> Setting up SLOT_NAME=${SLOT_NAME}"
  cat >> "$PGDATA/recovery.conf" <<EOF
primary_slot_name = '${SLOT_NAME}'
EOF
fi

cat >> "$PGDATA/postgresql.conf" <<EOF
log_statement = all
hot_standby = on
hot_standby_feedback = on
EOF

pg_ctl -m fast -w start
