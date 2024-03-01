#!/bin/bash

function exitMaxScale {
    /usr/bin/monit unmonitor all
    /usr/bin/maxscale-stop
    /usr/bin/monit quit
}

waitForLogFile() {
    local file="$1"
    while [[ ! -r "$file" ]]; do
        sleep 1
    done
}

rm -f /var/run/*.pid
rsyslogd
chown -R maxscale:maxscale /var/lib/maxscale

trap exitMaxScale SIGTERM

exec "$@" &

# Wait for the maxscale.log to be readable
waitForLogFile /var/log/maxscale/maxscale.log

tail -f /var/log/maxscale/maxscale.log


wait
