# MariaDB MaxScale Docker image

This Docker image runs the latest 2.4 version of MariaDB MaxScale.

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

## MaxScale docker-compose setup

[The MaxScale docker-compose setup](maxscale/docker-compose.yml) contains
MaxScale configured with a three node master-slave cluster. To start it, run the
following commands in the `maxscale` directory.
```
docker-compose build
docker-compose up -d
```

After MaxScale and the servers have started (takes a few seconds), you can find
the ReadWriteSplit-router on port 4006 and the ReadConnRoute on port 4008. The
user `maxuser` with the password `maxpwd` can be used to test the cluster.
Assuming the mariadb client is installed on the host machine:
```
$ mysql -umaxuser -pmaxpwd -h 127.0.0.1 -P 4006 test
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 10.2.12 2.2.9-maxscale mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [test]>
```

You can edit the [`maxscale.cnf.d/example.cnf`](maxscale/maxscale.cnf.d/example.cnf)
file and recreate the MaxScale container to change the configuration.

Run *maxctrl* in the container to see the status of the cluster:
```
$ docker-compose exec maxscale maxctrl list servers
┌─────────┬─────────┬──────┬─────────────┬─────────────────┬──────────┐
│ Server  │ Address │ Port │ Connections │ State           │ GTID     │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server1 │ master  │ 3306 │ 0           │ Master, Running │ 0-3000-5 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server2 │ slave1  │ 3306 │ 0           │ Slave, Running  │ 0-3000-5 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server3 │ slave2  │ 3306 │ 0           │ Slave, Running  │ 0-3000-5 │
└─────────┴─────────┴──────┴─────────────┴─────────────────┴──────────┘
```

The cluster is configured to utilize automatic failover. To illustrate this you
can stop the master container and watch for MaxScale to failover to one of the
slaves (may take a few seconds). If the server recovers, it is rejoined.

```
$ docker-compose stop master
Stopping maxscaledocker_master_1 ... done
$ docker-compose exec maxscale maxctrl list servers
┌─────────┬─────────┬──────┬─────────────┬─────────────────┬─────────────┐
│ Server  │ Address │ Port │ Connections │ State           │ GTID        │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼─────────────┤
│ server1 │ master  │ 3306 │ 0           │ Down            │ 0-3000-5    │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼─────────────┤
│ server2 │ slave1  │ 3306 │ 0           │ Master, Running │ 0-3001-7127 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼─────────────┤
│ server3 │ slave2  │ 3306 │ 0           │ Slave, Running  │ 0-3001-7127 │
└─────────┴─────────┴──────┴─────────────┴─────────────────┴─────────────┘
$ docker-compose start master
Starting master ... done
$ docker-compose exec maxscale maxctrl list servers
┌─────────┬─────────┬──────┬─────────────┬─────────────────┬─────────────┐
│ Server  │ Address │ Port │ Connections │ State           │ GTID        │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼─────────────┤
│ server1 │ master  │ 3306 │ 0           │ Slave, Running  │ 0-3001-7127 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼─────────────┤
│ server2 │ slave1  │ 3306 │ 0           │ Master, Running │ 0-3001-7127 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼─────────────┤
│ server3 │ slave2  │ 3306 │ 0           │ Slave, Running  │ 0-3001-7127 │
└─────────┴─────────┴──────┴─────────────┴─────────────────┴─────────────┘

```

Finally, remove the containers:
```
docker-compose down -v
```
