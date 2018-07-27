# Dockerfile for the 2.2 GA version of MariaDB MaxScale
FROM ubuntu:16.04

COPY maxscale.list /etc/apt/sources.list.d
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "0x135659e928c12247" && \
    apt-get -y update && \
    apt-get -y install maxscale && \
    rm -rf /var/lib/apt/lists/*
COPY maxscale.cnf /etc/
ENTRYPOINT ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]
