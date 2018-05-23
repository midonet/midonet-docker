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

    # if a UUID was not supplied, we'll get a new one with each `docker run`
    if [ "$UUID" != "" ]; then
        echo "host_uuid=$UUID" > /etc/midonet_host_id.properties
    fi
fi

if [ "$TEMPLATE" != "compute.large" ]; then
    TEMPLATE_NAME="agent-$(echo "$TEMPLATE" | sed -e 's/\./-/')"
    mn-conf template-set -h local -t "$TEMPLATE_NAME"
    cp "/etc/midolman/midolman-env.sh.$TEMPLATE" /etc/midolman/midolman-env.sh
fi

function do_midonet_command() {
    echo "Calling : midonet-cli --midonet-url=$MIDONET_API_URL --no-auth --eval \"$@\" "
 
    midonet-cli --midonet-url=$MIDONET_API_URL --no-auth --eval "$@" 
}


do_midonet_command tunnel-zone list || exit 1

set -m

echo "Running midolman-start ..."
/usr/share/midolman/midolman-start &

echo "Waiting ${INIT_WAIT_TIME}s to midolman to init ..."

sleep $INIT_WAIT_TIME

# add host to tunnel zone
export TZONE_NAME="default-tz"

do_midonet_command "tunnel-zone create name default-tz type vxlan"

export TZONE_ID=$(do_midonet_command tunnel-zone list | grep $TZONE_NAME | cut -d' ' -f2)

echo "The tunnel zone id is $TZONE_ID"

export HOST_ID=$(grep ^host_uuid /etc/midonet_host_id.properties | cut -d'=' -f2)

echo "The host id is $HOST_ID"

echo "The host IP is $HOST_IP"

echo "Adding host to tunnel zone"

do_midonet_command tunnel-zone $TZONE_ID add member host $HOST_ID address $HOST_IP

echo "Host added to tunnel zone"

fg
