# MariaDB MaxScale Docker image

This Docker image runs the latest 2.4 version of MariaDB MaxScale.

-	[Travis CI:  
	![build status badge](https://img.shields.io/travis/mariadb-corporation/maxscale-docker/master.svg)](https://travis-ci.org/mariadb-corporation/maxscale-docker/branches)


## Building

Run the following command in this directory to build the image.

```
make build-image
```

## Running
To pull the latest MaxScale image from docker hub:
```
docker pull mariadb/maxscale:latest
```

To run the MaxScale container overriding the container instance name to 'mxs':
```
docker run -d --name mxs mariadb/maxscale:latest
```

Read on for details of how to configure the MaxScale container.

## Configuration
The default configuration for the container is fairly minimalist and can be found in [this configuration file](./maxscale.cnf). At a high level the following is enabled:
- REST API with default user and password (admin / mariadb) listening to all hosts (0.0.0.0)

### Configure via REST API
The REST API by default listens on port 8989. To interact with this from the docker host, requires a port mapping to specified on container startup. The example below shows listing the current services via curl:
```
docker run -d -p 8989:8989 --name mxs mariadb/maxscale:latest
curl -u admin:mariadb -H "Content-Type: application/json" http://localhost:8989/v1/services

```
### Configure via maxscale.cnf File
An alternative model is to provide an overlay maxscale.cnf file that provides additional configuration for the cluster to be managed. To do this, you must mount your configuration file into `/etc/maxscale.cnf.d/`. When running the container with docker directly pass this using the argument to the `-v` option:

```
docker run -d --name mxs -v $PWD/my-maxscale.cnf:/etc/maxscale.cnf.d/my-maxscale.cnf mariadb/maxscale:2.2
```

## MaxScale docker-compose setup

[The MaxScale docker-compose setup](./docker-compose.yml) contains MaxScale
configured with a three node master-slave cluster. To start it, run the
following commands in this directory.

```
docker-compose build
docker-compose up -d
```

After MaxScale and the servers have started (takes a few minutes), you can find
the readwritesplit router on port 4006 and the readconnroute on port 4008. The
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
You can edit the [`maxscale.cnf.d/example.cnf`](./maxscale.cnf.d/example.cnf)
file and recreate the MaxScale container to change the configuration.

To stop the containers, execute the following command. Optionally, use the -v
flag to also remove the volumes.

To run maxctrl in the container to see the status of the cluster:
```
$ docker-compose exec maxscale maxctrl list servers
┌─────────┬─────────┬──────┬─────────────┬─────────────────┬──────────┐
│ Server  │ Address │ Port │ Connections │ State           │ GTID     │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server1 │ master  │ 3306 │ 0           │ Master, Running │ 0-3000-5 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server2 │ slave1  │ 3306 │ 0           │ Slave, Running  │ 0-3000-5 │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server3 │ slave2  │ 3306 │ 0           │ Running         │ 0-3000-5 │
└─────────┴─────────┴──────┴─────────────┴─────────────────┴──────────┘

```

The cluster is configured to utilize automatic failover. To illustrate this you can stop the master
container and watch for maxscale to failover to one of the original slaves and then show it rejoining
after recovery:
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

Once complete, to remove the cluster and maxscale containers:

```
docker-compose down -v
```
