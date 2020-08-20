![logo](MDB-HLogo_RGB.jpg)

# MariaDB MaxScale Docker image

This Docker image runs the latest 2.5 version of MariaDB MaxScale.

-	[Travis CI:  
	![build status badge](https://img.shields.io/travis/mariadb-corporation/maxscale-docker/master.svg)](https://travis-ci.org/mariadb-corporation/maxscale-docker/branches)


## Building

Build the image:
```
make build-image
```

## Running

Pull the latest MaxScale image from docker hub:
```
docker pull mariadb/maxscale:latest
```

Run the MaxScale container as "mxs":
```
docker run -d --name mxs mariadb/maxscale:latest
```

## Configuration

The [default configuration](maxscale/maxscale.cnf) for the container is minimal
and only enables the REST API.

The REST API by default listens on port 8989. The default user is "admin" with
password "mariadb". Accessing it from the docker host requires a port mapping
specified on container startup. The example below shows general information via
curl.
```
docker run -d -p 8989:8989 --name mxs mariadb/maxscale:latest
curl -u admin:mariadb http://localhost:8989/v1/maxscale
```

See [MaxScale documentation](https://github.com/mariadb-corporation/MaxScale/blob/2.4/Documentation/REST-API/API.md)
for more information about the REST API.

### Configure via configuration file

Custom configuration can be given in an additional configuration file (e.g.
`my-maxscale.cnf`). The file needs to be mounted into `/etc/maxscale.cnf.d/`:
```
docker run -d --name mxs -v $PWD/my-maxscale.cnf:/etc/maxscale.cnf.d/my-maxscale.cnf mariadb/maxscale:latest
```

### Commandline Access

`docker exec -it mxs bash`

