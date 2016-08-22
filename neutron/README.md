# Neutron Dockerfile

Dockerfile for a neutron server with Midonet integration.

The service is backed by a MariaDB database and uses
RabbitMQ as rpc backend.

Depends on a Keystone service with the neutron user and
service defined according with the [controller node configuration guide]
(http://docs.openstack.org/liberty/install-guide-obs/neutron-controller-install.html)

Uses host networking to facilitate connectivity to other
services and from client applications.

The *run-neutron.sh* script creates the minimal configuration
files /etc/neutron/neutron.conf and /neutron/plugins/midonet/midonet.ini
from the Environment variables. The process also synchronizes the db
schema.

## Environment Variables

The container receives multiple environment variables that are used to
configure Neutron and Midonet.

|Variable     | Description               |  Default                     |
|-------------|:-------------------------:|-----------------------------:|
|General                                                                 |
|OS_DEBUG     | sets verbose logging      |  'false'                     |
|OS_RPC       | sets rpc backend          | 'rabbit'                     |
|             | Set to 'fake' to dissable |                              |
|MariaDB                                                                 |
|DB_NAME      | DB name                   | 'neutron'                    |
|DB_USERNAME  | DB user                   | 'root'                       |
|DB_PASSWORD  | DB password               | 'root'                       |
|DB_HOST      | url for DB connection     | '127.0.0.1'                  |
|RabbitMQ                                                                |
|MQ_HOST      | host for RabbitMQ         |  '127.0.0.1'                 |
|MQ_USERNAME  | User name for Rabbit MQ   |  'guest'                     |
|MQ_PASSWD    | Password for RabbitMQ     |  'guest'                     |
|Keystone                                                                |
|OS_USERNAME  | OST admin user            | 'admin'                      |
|OS_PASSWORD  | OST admin user password   | 'admin'                      |
|OS_TENANT    | OST tennant name          | 'service'                    |
|OS_AUTH_URL  | URL for auth admin        | 'http://127.0.0.1:35357/v2.0'|
|OS_AUTH_URI  | URL for auth api          | 'http://127.0.0.1:5000/v2.0' |
|Midonet                                                                 |
|MN_USERNAME  | Midonet api username      | 'admin'                      |
|MN_PASSWD    | Midonet api password      | 'admin'                      |
|MN_HOST      | Url to midonet api        | 127.0.0.1                    |
|MN_PORT      | Port for Midonet          | 8181                         |
|MN_PROJECT   | Tenant id                 | 'service'                    |
