# MidoNet Cluster

This container is designed to interact with OpenStack Keystone and Apache
Zookeeper.

## How to run it

An example command line is:

```bash
docker run -d --name cluster \
  -e ZK_ENDPOINTS=172.17.0.83:2181,172.17.0.83:2181,172.17.0.85:2182 \
  -e KEYSTONE_HOST=172.17.0.81 \
  -e KEYSTONE_PORT=35357 \
  -e KEYSTONE_ADMIN_TOKEN="ADMIN" \
  -e UUID="a293fed0-f7dc-40e6-b01d-c688cfa02429" \
  -v ${HOME}/logs:/var/log/midonet-cluster \
   midonet/cluster
```

where:

* ZK\_ENDPOINTS is a comma separated list of all the ip:ports serving
  Apache Zookeeper.
* KEYSTONE\_HOST is the IP address or resolvable name (if you use docker links)
  of the Keystone endpoint.
* KEYSTONE\_PORT is the port under which the Keystone service is offered.
* KEYSTONE\_ADMIN\_TOKEN is the token that the Cluster will use to authenticate
  itself with keystone and it must belong to an admin role.
* UUID is an optional environment variable that allows you to spawn a container
  that is identified with that uuid. If you tear it down and start it again
  with the same UUID, it will take the place and configurations of the previous
  one. If it is not passed, each container run will get a new uuid.
* A volume is mounted to have the Cluster logs available in the host without
  having to enter the container.

Other available options:
* AGENT\_LOG\_LEVEL: which allows you to change the logging level that is used
  by the MidoNet agents in the cluster. It defaults to 'INFO'.
* C\_SERVERS: the comma-separated IPs of the cassandra servers in the cluster.
  If it is not provided, some MidoNet features like flow tracing will be
  disabled.
* C\_FACTOR: The Cassandra replication factor that the MidoNet agents in the
  cluster will use when writing to the Cassandra cluster.
