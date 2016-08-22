#!/bin/bash
set -x

mkdir -p /etc/zookeeper/conf
mkdir -p /var/lib/zookeeper

# keep zookeeper in-memory for performance unless is set to false
if [ "${ZK_IN_MEM}" != "false" ]; then
    sudo mount -t tmpfs -o size=1024m tmpfs /var/lib/zookeeper
fi

echo "$ZK_ID" > /var/lib/zookeeper/myid
echo "$ZK_ID" > /etc/zookeeper/conf/myid

#remove stalled configuration
rm /etc/zookeeper/conf/zoo.cfg

#set minimun parameters
echo -e "dataDir=/var/lib/zookeeper/" \
        "\nclientPort=2181"             \
        "\nforceSync=$ZK_SYNC" >> /etc/zookeeper/conf/zoo.cfg

#Look for hosts as a list of hostname:id
for MEMBER in $ZK_QUORUM; do
   HOST=$(echo $MEMBER | cut -d: -f1)
   ID=$(echo $MEMBER | cut -d: -f2)
   echo "server.$ID=$HOST:2888:3888" >> /etc/zookeeper/conf/zoo.cfg
done

exec /sbin/init
