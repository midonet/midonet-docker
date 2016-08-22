#!/bin/bash -x

if [[ -z $UUID ]];then
   echo "UUID for host must be provided"
   exit 1
fi

echo "host_uuid=$UUID" >  \
      /etc/neutron/lbaas-agent/midonet_host_id.properties

cat > /etc/neutron/neutron.conf <<EOF
[DEFAULT]
service_plugins= lbaas
rpc_backend=$OS_RPC_BACKEND
rabbit_host= $RB_HOST
rabbit_user= $RB_USERNAME
rabbit_password= $RB_PASSWORD

EOF

neutron-lbaas-agent --debug --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/services/loadbalancer/haproxy/lbaas_agent.ini
