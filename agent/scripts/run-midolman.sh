#!/bin/bash

HOST_ID_FILE="/etc/midonet_host_id.properties"

# If the user did not mount a volume with configuration, we create it from
# environment variables
if [ "$(stat -c '%m' /etc/midolman)" = "/" ]; then
    cat > /etc/midolman/midolman.conf << EOF
[zookeeper]
zookeeper_hosts = "${ZK_ENDPOINTS}"
EOF
fi

rm /usr/bin/wdog

# Do not write things to /etc if the user mounted his own config
if [ ! -f $HOST_ID_FILE ] || [ "$(stat -c '%m' "$HOST_ID_FILE")" = "/" ]; then
    echo "Midonet Host ID file not found ${HOST_ID_FILE}"
    # if a UUID was not supplied, we'll get a calculate one from the hostname
    if [ "$UUID" != "" ]; then
        echo "UUID=${UUID} given, using it"
    else
        echo "UUID not given, calculating it from $(hostname)"
        export UUID=$(hostname | md5sum | awk '{print $1}' | sed 's/\(........\)\(....\)\(....\)\(....\)\(............\)/\1-\2-\3-\4-\5/')
    fi
    echo "Creating file /etc/midonet_host_id.properties with UUID=${UUID}"
    echo "host_uuid=$UUID" > /etc/midonet_host_id.properties
fi

if [ "$TEMPLATE" != "compute.large" ]; then
    TEMPLATE_NAME="agent-$(echo "$TEMPLATE" | sed -e 's/\./-/')"
    mn-conf template-set -h local -t "$TEMPLATE_NAME"
    cp "/etc/midolman/midolman-env.sh.$TEMPLATE" /etc/midolman/midolman-env.sh
fi

echo "Running midolman-prepare ..."
bash /usr/share/midolman/midolman-prepare

echo "Running midolman-start ..."
bash /usr/share/midolman/midolman-start
