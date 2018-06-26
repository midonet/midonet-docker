# MidoNet Host Agent

This container is designed to interact with a Zookeeper cluster that is managed
by a MidoNet Cluster.

## How to run it

An example command line is:

```bash
docker run -d --name agent --net=host \
  --cap-add=NET_ADMIN \
  -e ZK_ENDPOINTS=172.17.0.14:2181,172.17.0.15:2181 \
  -e UUID=e967e5c2-3579-41d2-8a1b-4391ea40b0f3 \
  -v ${HOME}/logs/midonet_agent:/var/log/midolman \
  midonet/agent:latest
```

where:

* ZK\_ENDPOINTS is a comma-separated list of all the ip:ports serving
  Apache Zookeeper.
* UUID is an optional environment variable that allows you to spawn a container
  that is identified with that uuid. If it is not passed, it will be calculated
  from the output of `hostname` command. If you tear it down and start it again
  with the same UUID (or same hostname, if UUID not provided), it will take the
  place and configurations of the previous one.
* A volume is mounted to have the Cluster logs available in the host without
  having to enter the container.

Other available options:
* TEMPLATE is one of compute.large (default), compute.medium, gateway.large and
  gateway.medium. It is recommended to keep the default template for all the
  agents except for the gateway nodes, where you should pick one of the gatewa
  template options.
