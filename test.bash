#!/usr/bin/env bash
set -eu

echo "-> Starting test with SLOT_NAME=${SLOT_NAME} (empty means not replication slot is configured)"
echo "-> Clean up previous run(s)"
docker-compose rm --force --stop -v
echo "-> Starting databases ..."
docker-compose up -d
echo "-> Waiting for dbs to be ready ..."
docker-compose run --rm primary pg-wait.sh primary
docker-compose run --rm primary pg-wait.sh standby
echo "-> Slow down network ..."
docker-compose exec standby bash -c 'iptables -A INPUT -m statistic --mode random --probability 0.1 -j DROP'
echo "-> Perform a big insert ..."
docker-compose run --rm primary psql -h primary -U postgres -c 'DROP TABLE IF EXISTS foo; CREATE TABLE foo AS SELECT * FROM generate_series(1, 5000000);' &
echo "-> Tailing log file, look for "requested WAL segment ... has already been removed" messages"
docker-compose logs -f
