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
    # if a UUID was not supplied, we'll get a new one with each `docker run`
    if [ "$UUID" != "" ]; then
        echo "UUID=${UUID} given, using it"
    else
        echo "UUID not given, calculating one"
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

function do_midonet_command() {
    echo "Calling : midonet-cli --midonet-url=$MIDONET_API_URL --no-auth --eval \"$@\" "
 
    midonet-cli --midonet-url=$MIDONET_API_URL --no-auth --eval "$@" 
}


do_midonet_command tunnel-zone list || exit 1

set -m

echo "Running midolman-prepare ..."
bash /usr/share/midolman/midolman-prepare

touch /var/log/midolman/midolman.log

echo "Running midolman-start in background ..."
bash /usr/share/midolman/midolman-start &

until curl ${MIDONET_API_URL}; do echo Waiting for Midonet API ...; sleep 2; done;

# add host to tunnel zone
export TZONE_NAME="default-tz"

echo "Trying to create tunnel zone in case it is not already created ..."

# Use curl to workaround a limitation of midonet-cli.
# See https://midonet.atlassian.net/browse/MNA-1287
curl -d "{\"id\": \"${MIDONET_TUNNELZONE}\", \"name\": \"default-tz5\", \"type\": \"vxlan\" }" -H "Content-Type: application/vnd.org.midonet.TunnelZone-v1+json" -H "X-Auth-Token: 00000000" -X POST ${MIDONET_API_URL}/tunnel_zones

export HOST_ID=$(grep ^host_uuid /etc/midonet_host_id.properties | cut -d'=' -f2)

echo "The host id is $HOST_ID"

echo "The host IP is $HOST_IP"

echo "Adding host to tunnel zone"

until do_midonet_command tunnel-zone ${MIDONET_TUNNELZONE} add member host $HOST_ID address $HOST_IP; do echo Retrying to add host to tunnel zone ...; sleep 2; done;

echo "Host added to tunnel zone"

tail -f -n +1 /var/log/midolman/midolman.log
