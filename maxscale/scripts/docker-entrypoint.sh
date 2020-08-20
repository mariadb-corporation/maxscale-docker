#!/bin/bash

function exitMaxScale {
    /usr/bin/monit unmonitor all
    /usr/bin/maxscale-stop
    /usr/bin/monit quit
}

rm -f /var/run/syslogd.pid
rsyslogd

trap exitMaxScale SIGTERM

exec "$@" &

wait
