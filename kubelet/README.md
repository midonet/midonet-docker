# Hyperkube Kubelet

This container runs a Kubelet container which, in turns, spawns the rest of
Kubernetes services (api, etcd if needed) to have an inmediate suite of K8s to
be used.  It is configured to be used by MidoNet with Neutron, by configuring
the Kuryr's CNI driver and the `mm-ctl` utility to bind containers.

## How to run it

An example command line is:

```bash
docker run -d --name kubelet \
  -e ZK_ENDPOINTS=172.17.0.83:2181,172.17.0.83:2181,172.17.0.85:2182 \
  -e UUID="a293fed0-f7dc-40e6-b01d-c688cfa02429" \
  --pid=host \
  --net=host \
  --privileged=true \
  -v ${HOME}/logs:/var/log/midonet-cluster \
  -v /:/rootfs:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker:/var/lib/docker:rw \
  -v /var/lib/kubelet:/var/lib/kubelet:rw \
  -v /var/run:/var/run:rw \
  -e K8S_API='http://127.0.0.1:8080' \
  -e RUN_API='true' \
  -e RUN_ETCD='true' \
   midonet/kubelet
```

where:

* ZK\_ENDPOINTS is a comma separated list of all the ip:ports serving
  Apache Zookeeper.
* UUID is an optional environment variable that allows you to spawn a container
  that is identified with that uuid. If you tear it down and start it again
  with the same UUID, it will take the place and configurations of the previous
  one. If it is not passed, each container run will get a new uuid.
* It is prepared to run at host level because it spawns another docker
  containers (no docker-in-docker considered yet). So the `pid` and the `net`
  should be defined at host level, and several volumes *MUST* be mounted. The only
  optional one in the example is the `/var/log/midonet-cluster` one, but we still
  recommend to mount it.
* The K8S\_API env var is the url where to connect to retrieve API events.
* Kubelet is spawned alone by default, but you have the chance to run the `api` and
  `etc` to have a local k8s deployment quickly. Just set the env vars RUN\_API and
  RUN\_ETCD as true. In this case you don't need to set the K8S\_API because is 
  already `localhost` by default.
