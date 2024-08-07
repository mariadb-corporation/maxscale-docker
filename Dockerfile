FROM registry.access.redhat.com/ubi8/ubi-minimal:8.10-1018

ARG MXS_VERSION

COPY --chmod=500 mariadb_repo_setup /tmp/mariadb_repo_setup
RUN /tmp/mariadb_repo_setup --mariadb-maxscale-version=${MXS_VERSION} --skip-check-installed

# Install MaxScale
RUN microdnf -y install maxscale shadow-utils && microdnf clean all
COPY maxscale.cnf /etc/

# Copy licenses. Required for OpenShift container certification.
COPY LICENSE /licenses/

# Expose REST API port.
EXPOSE 8989

# Create maxscale user
RUN useradd -r maxscale && \
  chown maxscale:maxscale /var/{lib,run,log,cache}/maxscale

# Run as non root. Required for OpenShift container certification.
USER maxscale

ENTRYPOINT ["maxscale","--nodaemon", "--user=maxscale", "--log=stdout"]

