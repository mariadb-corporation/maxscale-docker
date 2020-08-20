# vim:set ft=dockerfile:
FROM centos:8

ENV TINI_VERSION=v0.18.0
ENV MXS_VERSION=2.5.2

# Add Tini Init Process
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini

# Add repo setup script
ADD https://downloads.mariadb.com/MariaDB/mariadb_repo_setup /tmp/mariadb_repo_setup

# Install MariaDB repositories
RUN chmod +x /tmp/mariadb_repo_setup && \
    /tmp/mariadb_repo_setup --mariadb-maxscale-version=${MXS_VERSION}

# Update system
RUN dnf -y install epel-release && dnf -y upgrade

# Install some basic dependencies and MaxScale
RUN dnf -y install \
    bind-utils less monit \
    nano ncurses net-tools \
    openssl rsyslog sudo \
    vim wget maxscale

# Copy files to image
COPY config/maxscale.cnf /etc/
COPY config/monit.d/ /etc/monit.d/

COPY scripts/maxscale-start scripts/maxscale-stop scripts/maxscale-restart \
     /usr/bin/

# Chmod some files
RUN chmod +x /usr/bin/tini /usr/bin/maxscale-start /usr/bin/maxscale-stop /usr/bin/maxscale-restart

# Expose MariaDB port
EXPOSE 3306
# Expose Rest API port
EXPOSE 8989

# Create persistent volumes
VOLUME ["/var/lib/maxscale"]

# Copy entrypoint to image
COPY scripts/docker-entrypoint.sh /usr/bin/

# Make entrypoint executable & create legacy symlink
RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Clean system and reduce size
RUN dnf clean all && \
    rm /tmp/mariadb_repo_setup && \
    rm -rf /var/cache/dnf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state"\)|g' /etc/rsyslog.conf

# Start up
ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]

CMD maxscale-start && monit -I

