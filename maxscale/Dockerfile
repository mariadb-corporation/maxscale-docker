# vim:set ft=dockerfile:
FROM rockylinux:8

ENV MXS_VERSION=23.08.4

# Add MariaDB Enterprise Repo
RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | \
    bash -s -- --mariadb-maxscale-version=${MXS_VERSION} --apply

# Update System
RUN dnf -y install epel-release && \
    dnf -y upgrade

# Install Some Basic Dependencies & MaxScale
RUN dnf clean expire-cache && \
    dnf -y install bind-utils \
    findutils \
    less \
    maxscale \
    monit \
    nano \
    ncurses \
    net-tools \
    openssl \
    procps-ng \
    rsyslog \
    tini \
    vim \
    wget

# Copy Files To Image
COPY config/maxscale.cnf /etc/

COPY config/monit.d/ /etc/monit.d/

COPY scripts/maxscale-start \
    scripts/maxscale-stop \
    scripts/maxscale-restart \
    /usr/bin/

# Chmod Some Files
RUN chmod +x /usr/bin/maxscale-start \
    /usr/bin/maxscale-stop \
    /usr/bin/maxscale-restart

# Expose MariaDB Port
EXPOSE 3306

# Expose REST API port
EXPOSE 8989

# Create Persistent Volume
VOLUME ["/var/lib/maxscale"]

# Copy Entrypoint To Image
COPY scripts/docker-entrypoint.sh /usr/bin/

# Make Entrypoint Executable & Create Legacy Symlink
RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Clean System & Reduce Size. The greps ensure that rsyslog.conf contents are as expected.
RUN dnf clean all && \
    rm -rf /var/cache/dnf && \
    grep '^[[:blank:]]*SysSock.Use="off"' /etc/rsyslog.conf && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    grep '^module(load="imjournal"' /etc/rsyslog.conf && \
    sed -i 's|^module(load="imjournal"|#module(load="imjournal"|' /etc/rsyslog.conf && \
    grep '^[[:blank:]]*UsePid="system"' /etc/rsyslog.conf && \
    sed -i 's|^\([[:blank:]]*\)UsePid="system"|#\1UsePid="system"|' /etc/rsyslog.conf && \
    grep '^[[:blank:]]*StateFile="imjournal.state")' /etc/rsyslog.conf && \
    sed -i 's|^\([[:blank:]]*\)StateFile="imjournal.state")|#\1StateFile="imjournal.state")|' /etc/rsyslog.conf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c

# Start Up
ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]

CMD maxscale-start && monit -I
