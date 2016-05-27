# MidoNet utils

This container is designed to give you access to common MidoNet command line
administration tools

## How to run it

It gives you access to both midonet-cli and mn-conf

### MidoNet CLI

An example non-interactive command line is:

```bash
docker run --rm \
  -e CLUSTER_URL=http://172.17.0.7:8181/midonet-api \
  midonet/utils cli -e host list
```

To get into interactive mode:

```bash
docker run --rm \
  -e CLUSTER_URL=http://172.17.0.7:8181/midonet-api \
  midonet/utils cli
```

where:
* CLUSTER\_URL is the url to the MidoNet API endpoint to connect to.

Other available options:
* USERNAME is the Keystone username with admin role to use to connect to
  the MidoNet cluster. (Default "admin").
* PASSWORD is the password for the above USERNAME. (Default "admin").
* PROJECT is the Keystone project for the above USERNAME. (Default "admin").

#### Making it easier:

If you want to avoid typing the docker run and env vars everytime, you can
create something like the following:

```bash
cat > ~/bin/midonet-cli << EOF
#!/bin/sh

docker run --rm \
  -e CLUSTER_URL=http://172.17.0.7:8181/midonet-api \
  midonet/utils cli "\$@"
EOF
chmod +x ~/bin/midonet-cli
```

After this, you can just call midonet-cli.

### mn-conf

An example non-interactive command line is:

```bash
docker run -ti --rm \
  -e ZK_ENDPOINTS=172.17.0.6:2181,172.17.0.5:2181,172.17.0.4:2182 \
  celebdor/utils conf dump

where:
* ZK\_ENDPOINTS is a comma separated list of all the ip:ports serving
  Apache Zookeeper.
* UUID is an optional environment variable that allows you to spawn a container
  that is identified with that uuid. It should allow you to impersonate a host
  and set specific local configuration for that host.
* You can also mount an /etc/midonet volume to provide the above configurations
  instead

#### Making it easier:

If you want to avoid typing the docker run and env vars everytime, you can
create something like the following:

```bash
cat > ~/bin/mn-conf << EOF
#!/bin/sh

docker run -ti --rm \
  -e ZK_ENDPOINTS=172.17.0.6:2181,172.17.0.5:2181,172.17.0.4:2182 \
  midonet/utils conf "\$@"
EOF
chmod +x ~/bin/mn-conf
```

After this, you can just call mn-conf.
