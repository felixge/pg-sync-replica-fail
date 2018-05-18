# How to not setup sync replication w/ Postgres

This repo contains a proof of concept that shows that it's possible for a WAL
segment to be removed from a primary server, despite having configured a sync
replica using `synchronous_standby_names` that hasn't received that WAL segment
yet:

```bash
./test.bash
```
```
standby_1  | 2018-05-18 15:43:49.703 UTC [87] FATAL:  could not receive data from WAL stream: ERROR:  requested WAL segment 000000010000000000000003 has already been removed
standby_1  | 2018-05-18 15:43:49.711 UTC [83] LOG:  invalid magic number 0000 in log segment 000000010000000000000003, offset 1794048
```

This caught me by surprise because I assumed that `synchronous_commit = on`
would guarantee that WAL segments are transferred in a synchronous fashion, and
that a slow standby would block the writing of new WAL segments on the primary.
However, it turns out that the shipping of WAL segments is async, and
`synchronous_commit` just causes the primary to delay the COMMIT acknowledgment
to the client until the standby has written the relevant WAL segment(s). But
for big transactions spawning multiple WAL segments with a slow standby, the
primary will remove WAL according to its own config (e.g. `max_wal_size`)
even if the standby hasn't received them yet.

This repo simulates this scenario by performing a large insert (5.000.000 rows)
in a single transaction while simulating a poor network link between the
primary and standby.

Of course the proper solution is to use replication slots, which avoid this
problem.

```bash
SLOT_NAME=abc ./test.bash
```
```
(no WAL errors occur)
```
