#!/bin/bash

# Update config file to point to ZK
CLUSTER_ENV=/usr/share/midonet-cluster/midonet-cluster-env.sh
MIDO_CFG=$(awk 'BEGIN {FS="="} /MIDO_CFG/ && !/MIDO_CFG_FILE/ { print $2 }' \
    "$CLUSTER_ENV")
MIDO_CFG_FILE=$(awk 'BEGIN {FS="="} /MIDO_CFG_FILE/ { print $2 }' \
    "$CLUSTER_ENV")

sed -i -e 's/zookeeper_hosts = .*$/zookeeper_hosts = '"$ZK_ENDPOINTS"'/' \
    "$MIDO_CFG/$MIDO_CFG_FILE"

echo "Setting up Zookeeper endpoint configuration for the cluster..."
mn-conf set -t default << EOF
zookeeper.zookeeper_hosts="$ZK_HOSTS"
EOF

echo "Setting up the default Cassandra replication factor..."
mn-conf set -t default << EOF
cassandra.replication_factor: $CASSANDRA_FACTOR
EOF

#If specified, the keystone url has precende over host and port
if [ ! -z "$KEYSTONE_URL" ]; then
   KS_HOST_AND_PORT=$(echo "$KEYSTONE_URL" | sed -e 's|^.*://||' | sed -e 's|/.*||')
   KEYSTONE_HOST=$(echo "$KS_HOST_AND_PORT" | cut -d ':' -f 1)
   KEYSTONE_PORT=$(echo "$KS_HOST_AND_PORT" | cut -d ':' -f 2)
fi

if [ "$AUTH_PROVIDER" = "Keystone" ]; then
    echo "Keystone environment variables were set. Setting up Keystone"
    AUTH_CONF=$(cat <<EOF
cluster.auth {
    provider_class: "org.midonet.cluster.auth.keystone.KeystoneService"
    admin_role: admin
    keystone.tenant_name: "$KEYSTONE_TENANT_NAME"
    keystone.admin_token: "$KEYSTONE_ADMIN_TOKEN"
    keystone.host: $KEYSTONE_HOST
    keystone.port: $KEYSTONE_PORT
}

EOF
)
elif [ "$AUTH_PROVIDER" = "Mock" ]; then
    echo "Using MockAuth provider instead of keystone as no container was linked."
    AUTH_CONF=$(cat <<EOF
cluster.auth {
    provider_class: "org.midonet.cluster.auth.MockAuthService"
}

EOF
)
else
    echo "Unknown AUTH_PROVIDER: '$AUTH_PROVIDER': it must be either 'Keystone' or 'Mock'"
    exit 1
fi

echo "Setting up the cluster configuration..."
/usr/bin/mn-conf set -t default << EOF
    zookeeper {
        zookeeper_hosts = "$ZK_ENDPOINTS"
    }

    agent {
        midolman {
            bgp_keepalive: 1s
            bgp_holdtime: 3s
            bgp_connect_retry: 1s
            lock_memory: true
            simulation_threads: 2
            output_channels: 2
        }

        datapath {
            max_flow_count: 1500000
            send_buffer_pool_max_size: 16384
            send_buffer_pool_initial_size: 4096
        }

        loggers.root: $AGENT_LOG_LEVEL

        haproxy_health_monitor {
            namespace_cleanup: true
            health_monitor_enable: true
            haproxy_file_loc: /etc/midolman/l4lb/
        }
    }

    $AUTH_CONF

EOF


if [ "$UUID" != "" ]; then
    echo "host_uuid=$UUID" > /etc/midonet_host_id.properties
fi


set -m

echo "Running midonet-cluster-start ..."

sh  /usr/share/midonet-cluster/midonet-cluster-start &

until curl ${MIDONET_API_URL}; do echo Waiting for Midonet API ...; sleep 2; done;

curl -d "{\"tenantId\": \"\", \"id\": \"${CLUSTER_ROUTER_UUID}\"}" -H "Content-Type: application/vnd.org.midonet.Router-v3+json" -H "X-Auth-Token: 00000000" -X POST ${MIDONET_API_URL}/routers

echo "Cluster router added"

tail -f -n +1 /var/log/midonet-cluster/midonet-cluster.log
