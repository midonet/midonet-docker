# Zookeeper  Dockerfile

Dockerfile for a Zookeeper server.


Uses host networking to facilitate connectivity to other
services and from client applications.

The *run-zookeeper.sh* script creates the minimal configuration
files /etc/zookeeper/zookeeper/conf/zoo.cfg, /etc/zookeeper/cfg/mydi, and
/etc/zookeeper/conf/myid.

State is stored in the directory /var/lib/zookeeper.

## Environment Variables

The container receives multiple environment variables that are used to
configure Zookeeper service

|Variable     | Description                    |  Default         |
|-------------|:------------------------------:|-----------------:|
|General                                                          |
|ZK_QUORUM    | List of server in the quorum   | 127.0.0.1:1      |
|ZK_ID        | Id of the server in the quorum | 1                |
|ZK_IN_MEM    | Store data inmemory            | false            |
|ZK_SYNC      | Synch data in disj             | no               |
