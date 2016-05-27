#!/bin/sh

if [ $# = 0 ]; then
    echo "You must provide a command name to run a MidoNet utility"
    exit 2
fi

UTILITY=$1

shift

case "$UTILITY" in
    midonet|midonet-cli|cli)
        if [ "$CLUSTER_URL" = "" ] || [ "$USERNAME" = "" ] || \
           [ "$PASSWORD" = "" ]; then
            echo "Missing MidoNet Cluster URL or credentials."
            exit 2
        fi

        DIR="/home/midonet"

        if [ ! -d "$DIR" ] || [ "$(stat -c '%m' "$DIR")" = "/" ]; then
            cat > "$DIR/.midonetrc" << EOF
[cli]
api_url = $CLUSTER_URL
username = $USERNAME
password = $PASSWORD
project_id = $PROJECT
EOF
        fi
        midonet-cli "$@"
        exit $?
        ;;
    mn-conf|conf)
        if [ "$ZK_ENDPOINTS" = "" ]; then
            echo "Missing Zookeeper endpoints to call $UTILITY"
            exit 2
        fi

        HOST_ID_FILE="/etc/midonet_host_id.properties"
        # Do not write things to /etc if the user mounted his own config
        if [ ! -f $HOST_ID_FILE ] || \
           [ "$(stat -c '%m' "$HOST_ID_FILE")" = "/" ]; then

            # if a UUID was not supplied, we'll get a new one with each
            # `docker run`
            if [ "$UUID" != "" ]; then
                echo "host_uuid=$UUID" > /etc/midonet_host_id.properties
            fi
        fi

        DIR="/etc/midonet"

        if [ ! -d "$DIR" ] || [ "$(stat -c '%m' "$DIR")" = "/" ]; then
            mkdir -p "$DIR"
            cat > "$DIR/midonet.conf" << EOF
[zookeeper]
zookeeper_hosts = "${ZK_ENDPOINTS}"
EOF
        fi
        mn-conf "$@"
        exit $?
        ;;
    *)
        echo "Unknown utility $UTILITY"
        exit 2
        ;;
esac
