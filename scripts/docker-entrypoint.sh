#!/bin/bash

function exitMaxScale {
    /usr/bin/monit unmonitor all
    /usr/bin/maxscale-stop
    /usr/bin/monit quit
}

rm -f /var/run/*.pid
rsyslogd
chown -R maxscale:maxscale /var/lib/maxscale

trap exitMaxScale SIGTERM

exec "$@" &

wait
