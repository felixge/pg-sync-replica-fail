#!/usr/bin/env bash
set -eu

cat >> "$PGDATA/pg_hba.conf" <<EOF
host    replication     postgres             0.0.0.0/0        md5
host    postgres     postgres             0.0.0.0/0        md5
EOF

cat >> "$PGDATA/postgresql.conf" <<EOF
max_wal_size = 64MB
synchronous_standby_names = 'standby'
EOF

if [ "${SLOT_NAME:-}" != "" ]; then
  echo "-> Setting up SLOT_NAME=${SLOT_NAME}"
  psql -c "SELECT * FROM pg_create_physical_replication_slot('${SLOT_NAME}');"
fi
