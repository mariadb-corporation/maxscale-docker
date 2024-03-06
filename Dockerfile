FROM registry.access.redhat.com/ubi8/ubi-minimal:8.9-1137

ARG MXS_VERSION

COPY mariadb_repo_setup /tmp/mariadb_repo_setup
RUN /tmp/mariadb_repo_setup --mariadb-maxscale-version=${MXS_VERSION} --skip-check-installed

# Install MaxScale
RUN microdnf -y install maxscale && microdnf clean all
COPY maxscale.cnf /etc/

# Expose standard MariaDB and REST API ports
EXPOSE 3306
EXPOSE 8989

# Create persistent volumes in case user mounts these.
VOLUME ["/var/lib/maxscale"]
VOLUME ["/var/log/maxscale"]

ENTRYPOINT ["maxscale","--nodaemon", "--user=root", "--log=stdout"]

