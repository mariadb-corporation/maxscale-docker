# Dockerfile for the 2.4 GA version of MariaDB MaxScale
FROM centos:7

ARG VERSION
ARG GIT_COMMIT
ARG GIT_TREE_STATE
ARG BUILD_TIME
ARG REMOVE_MAXSCALE_REPOSITORY=no
ADD https://downloads.mariadb.com/MariaDB/mariadb_repo_setup /tmp/mariadb_repo_setup

# Install MariaDB repositories
RUN chmod +x /tmp/mariadb_repo_setup && \
    /tmp/mariadb_repo_setup --mariadb-maxscale-version=2.4.11 && \
    yum -y list updates && \
    # Install MaxScale
    yum -y install maxscale && yum -y clean metadata && \
    if [ $REMOVE_MAXSCALE_REPOSITORY = yes ]; then rm /etc/yum.repos.d/mariadb.repo ; fi && \
    if [ ! -z $VERSION ] && [ ! -z $GIT_COMMIT ] && [ ! -z $BUILD_TIME ]; then \
       printf "Version:    $VERSION\nGit commit: $GIT_COMMIT$GIT_TREE_STATE\nBuilt:      $BUILD_TIME\n" > /opt/image_details; fi

COPY maxscale.cnf /etc/
ENTRYPOINT ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]
