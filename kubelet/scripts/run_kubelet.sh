#!/bin/sh

mkdir -p /etc/kuryr/
cat << EOF > /etc/kuryr/kuryr.conf
[DEFAULT]
bindir = /opt/kuryr/usr/libexec/kuryr

[k8s]
api_root = http://${MASTER_IP}:8080
EOF

HOST_ID_FILE='/etc/midonet_host_id.properties'
MIDOLMAN_CONF_FILE='/etc/midolman/midolman.conf'

if [ ! -f ${MIDOLMAN_CONF_FILE} ] || [ "$(stat -c '%m' /etc/midolman)" = "/" ]; then
    cat > /etc/midolman/midolman.conf << EOF
[zookeeper]
zookeeper_hosts = "${ZK_ENDPOINTS}"
EOF
fi


# Do not write things to /etc if the user mounted his own config
if [ ! -f ${HOST_ID_FILE} ] || [ "$(stat -c '%m' ${HOST_ID_FILE})" = "/" ]; then

    # if a UUID was not supplied, we'll get a new one with each `docker run`
    if [ "$UUID" = "" ]; then
        UUID=$(python -c "import uuid; print(uuid.uuid4())")
    fi
    echo "host_uuid=$UUID" > ${HOST_ID_FILE}
fi

/hyperkube kubelet \
  --allow-privileged=true \
  --api-servers="http://${MASTER_IP}:8080" \
  --v=2 \
  --address='0.0.0.0' \
  --enable-server \
  --containerized \
  --network-plugin=cni
