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
    mn-conf set -t default << EOF
    cluster.auth {
        provider_class = "org.midonet.cluster.auth.keystone.v2_0.KeystoneService"
        admin_role = "admin"
        keystone.tenant_name = "$KEYSTONE_TENANT_NAME"
        keystone.admin_token = "$KEYSTONE_ADMIN_TOKEN"
        keystone.host = $KEYSTONE_HOST
        keystone.port = $KEYSTONE_PORT
    }
EOF
else
    echo "Using MockAuth provider instead of keystone as no container was linked."
fi

if [ "$UUID" != "" ]; then
    echo "host_uuid=$UUID" > /etc/midonet_host_id.properties
fi

sh /usr/share/midonet-cluster/midonet-cluster-start
