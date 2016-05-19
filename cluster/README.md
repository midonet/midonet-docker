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
  -v ${HOME}/logs:/var/log/midonet-cluster \
   midonet/cluster
```

where

* ZK\_ENDPOINTS is a comma separated list of all the ip:ports serving
  Apache Zookeeper.
* KEYSTONE\_HOST is the IP address or resolvable name (if you use docker links)
  of the Keystone endpoint.
* KEYSTONE\_PORT is the port under which the Keystone service is offered.
* KEYSTONE\_ADMIN\_TOKEN is the token that the Cluster will use to authenticate
  itself with keystone and it must belong to an admin role.
* A volume is mounted to have the Cluster logs available in the host without
  having to enter the container.
