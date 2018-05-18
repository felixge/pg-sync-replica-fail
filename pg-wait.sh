#!/usr/bin/env bash
set -eu
host="$1"

until psql -h "$host" -U postgres -c '\q'; do
  >&2 echo "postgres server $host is unavailable - sleeping"
  sleep 1
done
