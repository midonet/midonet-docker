FROM ubuntu-upstart:14.04
MAINTAINER MidoNet (http://midonet.org)

RUN mkdir -p /etc/neutron/plugins/midonet

COPY conf/midonet.list /etc/apt/sources.list.d/midonet.list
COPY conf/keystonerc /keystonerc
COPY conf/midonetrc /root/.midonetrc
COPY bin/run-neutron.sh /run-neutron.sh

# These files needs to be moved after neutron installation
# Put in a temporary directory so they can be placed correctly on the child image
COPY conf/neutron_defaults /midonet_conf/neutron-server
COPY conf/neutron_lbaas.conf /midonet_conf/neutron_lbaas.conf
COPY conf/neutron_vpnaas.conf /midonet_conf/neutron_vpnaas.conf

RUN apt-get -q update && apt-get install -qy curl
RUN curl -k http://builds.midonet.org/midorepo.key | apt-key add -
RUN apt-get -qy install --no-install-recommends \
                        python-mysql.connector \
                        python-openssl \
                        mariadb-client

#set environemnt variables
ENV OS_VERBOSE='false'     \
#MariaDB
    DB_NAME='neutron'   \
    DB_USERNAME='neutron'      \
    DB_PASSWORD='neutron'      \
    DB_HOST='127.0.0.1' \
#For RabbitMQ
    RB_HOST='127.0.0.1'      \
    RB_USERNAME='guest'      \
    RB_PASSWORD='guest'      \
#For OpenStack keystone
    OS_USERNAME='neutron'      \
    OS_PASSWORD='neutron'      \
    OS_TENANT_NAME='service'   \
    OS_AUTH_URL='http://127.0.0.1:35357/v2.0'  \
    OS_AUTH_URI='http://127.0.0.1:5000/v2.0' \
    OS_DEBUG='False'   \
    OS_VERBOSE=False   \
#For Midonet
    MN_USERNAME='netron'      \
    MN_PASSWORD='neutron'     \
    MN_PROJECT='service'      \
    MN_URI='http://127.0.0.1:8181/midonet-api'

CMD ["/run-neutron.sh"]
