# Hyperkube Kubelet

This container runs a Kubelet agent configured to be used Kuryr's
CNI driver to bind containers to network ports provided by midonet.

## How to run it

An example command line is:

```bash
docker run -d --name kubelet \
  -e ZK_ENDPOINTS=172.17.0.83:2181,172.17.0.83:2181,172.17.0.85:2182 \
  -e UUID="a293fed0-f7dc-40e6-b01d-c688cfa02429" \
  -e MASTER_IP="10.11.0.2" \
  -e PUBLIC_IP=10.11.0.8" \
  --pid=host \
  --net=host \
  --privileged=true \
  -v ${HOME}/logs:/var/log/midonet-agent \
  -v /:/rootfs:ro
  -v /sys:/sys:ro
  -v /var/lib/docker:/var/lib/docker:rw
  -v /var/lib/kubelet:/var/lib/kubelet:rw
  -v /var/run:/var/run:rw
   midonet/kubelet
```

where:

* ZK\_ENDPOINTS is a comma separated list of all the ip:ports serving
  Apache Zookeeper.
* UUID is an optional environment variable that allows you to spawn a container
  that is identified with that uuid. If you tear it down and start it again
  with the same UUID, it will take the place and configurations of the previous
  one. If it is not passed, each container run will get a new uuid.
* MASTER\_IP is the Kubernetes API server IP.
* PUBLIC\_IP is an optional parameter. If specified, it is used instead of the host
  name to make it accessible to the master if its hostname can't e resolved by dns.
* It is prepared to run at host level because it spawns another docker
  containers (no docker-in-docker considered yet). So the `pid` and the `net`
  should be defined at host level, and several volumes *MUST* be mounted. The only
  optional one in the example is the `/var/log/midonet-cluster` one, but we still
  recommend to mount it.
