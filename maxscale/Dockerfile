# Dockerfile for the 2.4 GA version of MariaDB MaxScale
FROM ubuntu:bionic

ARG VERSION
ARG GIT_COMMIT
ARG GIT_TREE_STATE
ARG BUILD_TIME
ARG REMOVE_MAXSCALE_REPOSITORY=no

COPY maxscale.list /etc/apt/sources.list.d/maxscale.list.tmp

RUN apt-get -y update && \
    apt-get -y install gnupg2 ca-certificates less sysstat && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "0xE3C94F49" && \
    mv /etc/apt/sources.list.d/maxscale.list.tmp /etc/apt/sources.list.d/maxscale.list && \
    apt-get -y update && \
    apt-get -y install maxscale && \
    rm -rf /var/lib/apt/lists/* && \
    if [ $REMOVE_MAXSCALE_REPOSITORY = yes ]; then \
        rm /etc/apt/sources.list.d/maxscale.list ; \
    fi && \
    if [ ! -z $VERSION ] && [ ! -z $GIT_COMMIT ] && [ ! -z $BUILD_TIME ]; then \
       printf "Version:    $VERSION\nGit commit: $GIT_COMMIT$GIT_TREE_STATE\nBuilt:      $BUILD_TIME\n" > /opt/image_details; fi

COPY maxscale.cnf /etc/
ENTRYPOINT ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]
