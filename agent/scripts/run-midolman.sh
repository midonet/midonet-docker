#!/bin/sh

# Update CASS hosts in case they were linked to this container
SERVERS=$(env | grep _PORT_9042_TCP_ADDR)
if [ $? -eq 0 ]; then
    CASS_SERVERS="$(echo "$SERVERS" | sed 's/.*_PORT_9042_TCP_ADDR=//g' | sed -e :a -e N | sort -u)"
    CASS_SERVERS="$(echo "$CASS_SERVERS" | sed 's/ /,/g')"
fi

# Default cassandra replication factor
if [ -z "$CASS_FACTOR" ]; then
    CASS_FACTOR=3
fi

ZK_HOSTS=${MIDO_ZOOKEEPER_HOSTS:-"127.0.0.1:2181"}
echo "initially connecting to ${ZK_HOSTS}"
/usr/bin/mn-conf set -t default <<EOF
zookeeper.zookeeper_hosts="$ZK_HOSTS"
cassandra.servers="$CASS_SERVERS"
cassandra.cluster=midonet
agent.midolman.bgp_keepalive=1s
agent.midolman.bgp_holdtime=3s
agent.midolman.bgp_connect_retry=1s
agent.midolman.lock_memory=false
agent.midolman.simulation_threads=2
agent.loggers.root=DEBUG
agent.haproxy_health_monitor.namespace_cleanup=true
agent.haproxy_health_monitor.health_monitor_enable=true
agent.haproxy_health_monitor.haproxy_file_loc=/etc/midolman/l4lb/
EOF

mkdir -p /var/log/midolman
echo "" > /etc/midolman/midolman.conf
rm /usr/bin/wdog

sed -i '/exec >> \/var\/log\/midolman\/upstart-stderr.log/{N;d;}' /usr/share/midolman/midolman-start

sh /usr/share/midolman/midolman-prepare
sh /usr/share/midolman/midolman-start
