![logo](https://mariadb.com/wp-content/uploads/2019/11/mariadb-logo_blue-transparent.png)

# MariaDB MaxScale Docker image

This Docker image runs MariaDB MaxScale. Two image variants can be built:

1. [Tini](https://github.com/krallin/tini)-based image running on [Rocky Linux 8](https://rockylinux.org/)
2. Minimal image running on [Red Hat Universal Base Image 8 Minimal](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8?q=Red%20Hat%20Unive&architecture=amd64&image=660383f31ba64b6bd44df0a7)

## Building

```
make build-image MXS_VERSION=<mxs-version>
```

The resulting image type depends on the Git branch used: *rocky8* for Tini-based images,
*rhel-ubi8* for RHEL-UBI-based images.

For example, to build an image with MaxScale 24.02.1 run `make build-image MXS_VERSION=24.02.1`.

## Running

Pull the latest MaxScale image from docker hub:
```
docker pull mariadb/maxscale:latest
```

Run the MaxScale container as "mxs":
```
docker run -d --rm --name mxs mariadb/maxscale:latest
```

The default configuration for the container is minimal and only enables the
REST API.

The REST API by default listens on port 8989. The default user is "admin" with
password "mariadb". Accessing it from the docker host requires a port mapping
specified on container startup. The example below shows general information via
curl.
```
docker run -d --rm -p 8989:8989 --name mxs mariadb/maxscale:latest
curl -u admin:mariadb http://localhost:8989/v1/maxscale
```

See [MaxScale documentation](https://mariadb.com/kb/en/mariadb-maxscale-2208-rest-api/)
for more information about the REST API.

## Configure via configuration file

Custom configuration can be given in an additional configuration file (e.g.
`my-maxscale.cnf`). The file needs to be mounted into `/etc/maxscale.cnf.d/`:
```
docker run -d --rm -p 8989:8989 --name mxs -v $PWD/my-maxscale.cnf:/etc/maxscale.cnf.d/my-maxscale.cnf mariadb/maxscale:latest
```

If the `[maxscale]`-section of the configuration file needs to be altered, the
new file should override the default configuration file.
```
docker run -d --rm -p 8989:8989 --name mxs -v $PWD/my-maxscale.cnf:/etc/maxscale.cnf mariadb/maxscale:latest
```

## MaxScale 25.10 trial version

The MaxScale 25.10 trial image (25.10.2-trial) requires a licence key to run. Generate a
[licence key](https://mariadb.com/download-confirmation/maxscale-trial/),
and write it to the maxscale-section in a MaxScale configuration file:

```
[maxscale]
license_key=<license key contents>
```

Then, start the MaxScale container with the config file by running
`docker run -d --rm -p 8989:8989 --name mxs -v $PWD/my-maxscale.cnf:/etc/maxscale.cnf mariadb/maxscale:25.10.2-trial`.

## Commandline Access

`docker exec -it mxs bash`
