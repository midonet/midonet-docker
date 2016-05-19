# MidoNet Host Agent

## Usage

This container is designed to run in the host network namespace. Make sure that
the host hostname is resolvable and then run:

    docker run --net=host -ti --cap-add=NET_ADMIN celebdor/midonet-agent:master

This expects to find a zookeeper machine running at 127.0.0.1

    docker run -ti --rm --net=host jplock/zookeeper

You can also specify the address of the zookeeper machines by running the
midonet-agent container with

    -e MIDO_ZOOKEEPER_HOSTS=addr:port
