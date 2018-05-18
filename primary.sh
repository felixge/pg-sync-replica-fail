#!/usr/bin/env bash
set -eu

cat >> "$PGDATA/pg_hba.conf" <<EOF
host    replication     postgres             0.0.0.0/0        md5
host    postgres     postgres             0.0.0.0/0        md5
EOF

cat >> "$PGDATA/postgresql.conf" <<EOF
max_wal_size = 64MB
EOF

#pg_ctl -m fast -w restart
