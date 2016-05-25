#!/bin/sh

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

if [ -n "$KEYSTONE_HOST" ] && [ -n "$KEYSTONE_PORT" ]; then
    echo "Keystone environment variables were set. Setting up Keystone"
    AUTH_CONF=$(cat <<'END_OF_HEREDOC'
cluster.auth {
    provider_class: org.midonet.cluster.auth.keystone.KeystoneService
    admin_role: admin
    keystone.tenant_name: "$KEYSTONE_TENANT_NAME"
    keystone.admin_token: "$KEYSTONE_ADMIN_TOKEN"
    keystone.host: $KEYSTONE_HOST
    keystone.port: $KEYSTONE_PORT
}

END_OF_HEREDOC
)
else
    echo "Using MockAuth provider instead of keystone as no container was linked."
fi

if [ "$C_SERVERS" != "" ]; then
    echo "Configuring Cassandra for this MidoNet cluster..."
    C_CONF=$(cat <<'END_OF_HEREDOC'
cassandra {
    servers: "$C_SERVERS"
    replication_factor: $C_FACTOR
    cluster: midonet
}

END_OF_HEREDOC
)
else
    echo "No Cassandra configuration. It won't be configured."
    C_CONF=""
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

    "$AUTH_CONF"
    "$C_CONF"
EOF


if [ "$UUID" != "" ]; then
    echo "host_uuid=$UUID" > /etc/midonet_host_id.properties
fi

sh /usr/share/midonet-cluster/midonet-cluster-start
