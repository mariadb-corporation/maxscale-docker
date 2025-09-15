# vim:set ft=dockerfile:
FROM rockylinux:8

ENV MXS_VERSION=23.08.11
ENV CHECKSUM=923eea378be2c129adb4d191f01162c1fe5473f1114d7586f096b5f6b9874efe

# Add MariaDB repository
RUN curl -LsSO https://r.mariadb.com/downloads/mariadb_repo_setup && \
    echo "${CHECKSUM} mariadb_repo_setup" | sha256sum -c - && chmod u+x mariadb_repo_setup && \
    ./mariadb_repo_setup --mariadb-maxscale-version=${MXS_VERSION} --skip-server && rm mariadb_repo_setup

# Update system, install tools and MaxScale. Also, use a recent NodeJS-version to
# avoid some vulnerability warnings.
RUN dnf -y install epel-release && dnf -y upgrade && \
    dnf clean expire-cache && dnf -y install maxscale findutils monit rsyslog tini && \
    dnf -y module switch-to nodejs:20

# Copy Files To Image
COPY config/maxscale.cnf /etc/
COPY config/monit.d/ /etc/monit.d/
COPY scripts/maxscale-start scripts/maxscale-stop scripts/maxscale-restart /usr/bin/

# Chmod Some Files
RUN chmod +x /usr/bin/maxscale-start /usr/bin/maxscale-stop /usr/bin/maxscale-restart

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
