# How to not setup sync replication w/ Postgres

This repo contains a proof of concept that shows that it's possible for WAL
segments to be removed from a primary server, despite having configured a sync
replica using `synchronous_standby_names` that hasn't received the WAL segment
yet:

```bash
./test.bash
```
```
standby_1  | 2018-05-18 15:43:49.703 UTC [87] FATAL:  could not receive data from WAL stream: ERROR:  requested WAL segment 000000010000000000000003 has already been removed
standby_1  | 2018-05-18 15:43:49.711 UTC [83] LOG:  invalid magic number 0000 in log segment 000000010000000000000003, offset 1794048
```

Of course the proper solution is to use replication slots, which avoid this
problem.

```bash
SLOT_NAME=abc ./test.bash
```
```
(no WAL errors occur)
```
