#!/bin/sh


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
if [ "$(stat -c '%m' /etc/midonet_host_id.properties)" = "/" ]; then

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

sed -i '/exec >> \/var\/log\/midolman\/upstart-stderr.log/{N;d;}' \
    /usr/share/midolman/midolman-start

sh /usr/share/midolman/midolman-prepare
sh /usr/share/midolman/midolman-start
