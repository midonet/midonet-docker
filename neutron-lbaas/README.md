
# Neutron LBAAS Dockerfile

Dockerfile for a Midonet LBAAS agent for OpenStack Neutron.

The service uses RabbitMQ as rpc backend.

Uses host networking to facilitate connectivity to other
services and from client applications.

The *run-lbaas-agent.sh* script creates the minimal configuration
files /etc/neutron/neutron.conf.

The container must run in privileged mode.

Addionally, the container requires the volume "/var/run/midolman" to be
mounted to allow communication with the midonet agent by means of a system 
socket.

## Environment Variables

The container receives multiple environment variables that are used to
configure Neutron agent.

|Variable     | Description               |  Default                     |
|-------------|:-------------------------:|-----------------------------:|
|General                                                                 |
|OS_DEBUG     | sets verbose logging      | 'false'                      |
|OS_RPC       | sets rpc backend          | 'rabbit'                     |
|             | Set to 'fake' to dissable |                              |
|UUID         | Hosts UUID                |  N/A                         |
|RabbitMQ                                                                |
|MQ_HOST      | host for RabbitMQ         |  '127.0.0.1'                 |
|MQ_USERNAME  | User name for Rabbit MQ   |  'guest'                     |
|MQ_PASSWD    | Password for RabbitMQ     |  'guest'                     |
