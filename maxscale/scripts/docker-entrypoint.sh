#!/bin/bash

function exitMaxScale {
    /usr/bin/monit unmonitor all
    /usr/bin/maxscale-stop
    /usr/bin/monit quit
}

rm -f /var/run/*.pid
rsyslogd

chown maxscale:maxscale /etc/maxscale.cnf
chmod o+r /etc/maxscale.cnf

trap exitMaxScale SIGTERM

exec "$@" &

wait
