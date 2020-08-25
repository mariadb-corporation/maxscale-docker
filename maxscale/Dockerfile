# vim:set ft=dockerfile:
FROM centos:8

ENV TINI_VERSION=v0.18.0
ENV MXS_VERSION=2.5.2

# Add Tini Init Process
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini

# Add Repo Setup script
ADD https://downloads.mariadb.com/MariaDB/mariadb_repo_setup /tmp/mariadb_repo_setup

# Install MariaDB Repositories
RUN chmod +x /tmp/mariadb_repo_setup && \
    /tmp/mariadb_repo_setup --mariadb-maxscale-version=${MXS_VERSION}

# Update System
RUN dnf -y install epel-release && \
    dnf -y upgrade

# Install Some Basic Dependencies & MaxScale
RUN dnf -y install bind-utils \
    less \
    maxscale \
    monit \
    nano \
    ncurses \
    net-tools \
    openssl \
    rsyslog \
    sudo \
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
RUN chmod +x /usr/bin/tini \
    /usr/bin/maxscale-start \
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

# Clean System & Reduce Size
RUN dnf clean all && \
    rm -rf /var/cache/dnf && \
    rm /tmp/mariadb_repo_setup && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state"\)|g' /etc/rsyslog.conf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c

# Start Up
ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]

CMD maxscale-start && monit -I
