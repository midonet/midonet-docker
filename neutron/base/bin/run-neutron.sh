#!/bin/bash -x



# Update the neutron config file with environment variables
# The pattern is /^[# ]*property[ ]*=/ s|^.*|= $VARIABLE/
#  ^[# ]*         matches the start of line with trailing blanks or comments
#  /property[ ]*= matches a line with the property name and a value assigment
#  s|=^*/         matches any current value of the line
#  /property = $VARIABLE   does the substitution

cat > /etc/neutron/neutron.conf <<EOF
[DEFAULT]
debug=$OS_DEBUG
log_dir = /var/log/neutron
log_file = neutron.log

auth_strategy = keystone

rpc_backend = rabbit

core_plugin = midonet.neutron.plugin_v2.MidonetPluginV2
service_plugins = lbaas,midonet.neutron.services.l3.l3_midonet.MidonetL3ServicePlugin,midonet.neutron.services.firewall.plugin.MidonetFirewallPlugin

[service_providers]
service_provider = LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

[keystone_authtoken]
auth_plugin = password
project_name = $OS_TENANT_NAME
auth_uri = $OS_AUTH_URI
auth_url = $OS_AUTH_URL
username = $OS_USERNAME
password = $OS_PASSWORD

[database]
connection = mysql+mysqlconnector://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME

[oslo_messaging_rabbit]
rabbit_host = $RB_HOST
rabbit_userid = $RB_USERNAME
rabbit_password = $RB_PASSWORD

EOF

cat > /etc/neutron/plugins/midonet/midonet.ini <<EOF
[DEFAULT]
llow_overlapping_ips = True

[MIDONET]
username = $MN_USERNAME
password = $MN_PASSWORD
project_id = $MN_PROJECT
auth_url = $OS_AUTH_URI
midonet_uri = $MN_URI

[database]
connection = mysql+mysqlconnector://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME

EOF

cat > keystonerc << EOF
export OS_TENANT_NAME=$OS_TENANT_NAME
export OS_USERNAME=$OS_USERNAME
export OS_PASSWORD=$OS_PASSWORD
export OS_AUTH_URL=$OS_AUTH_URL
export OS_AUTH_URI=$OS_AUTH_URI
EOF

while ! nc -z $DB_HOST 3306; do
    /bin/sleep 3;
    echo "MariaDB not running yet at host ${DB_HOST}"
done

neutron-db-manage --config-file /etc/neutron/neutron.conf \
                   --config-file /etc/neutron/plugins/midonet/midonet.ini \
                                      upgrade head

neutron-db-manage --config-file /etc/neutron/plugins/midonet/midonet.ini \
                   --subproject networking-midonet upgrade head

neutron-server --config-file /etc/neutron/neutron.conf \
               --config-file /etc/neutron/plugins/midonet/midonet.ini 

