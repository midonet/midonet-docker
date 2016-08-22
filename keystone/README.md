
#Keystone Dockerfile

Dockerfile for a Keystone server backed by a MariaDB database.

Uses host networking to facilitate connectivity to other
services and from client applications.

The *run-keystone.sh* script creates the minimal configuration
files /etc/keystone/keystone.conf from the environment variables.
The process also synchronizes the db schema.

The log are sent to the /var/log/keystone directory, which can be
mounted in the host to acces it.

##Environment Variables

The container receives multiple environent variables that are used to
configure Keystone:

|Variable     | Description               | Default                     |
|-------------|:-------------------------:|:---------------------------:|
|General                                                                |
|OS_VERBOSE   | Sets verbose logging      | False                       |
|OS_TOKEN     | Administrative token      | 'admin'                     |
|MariaDB                                                                |
|DB_NAME      | DB name                   | 'neutron'                   |
|DB_USERNAME  | DB user                   | 'root'                      |
|DB_PASSWORD  | DB password               | 'root'                      |
|DB_HOST      | DB host name or ip        | '127.0.0.1'                 |
