#!/bin/sh

mkdir -p /etc/kuryr/
cat << EOF > /etc/kuryr/kuryr.conf
[DEFAULT]

bindir = /usr/local/lib/python3.4/dist-packages/usr/libexec/kuryr
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

if [ "$RUN_API" = "" ]; then
    rm /etc/kubernetes/manifests/master.json
else
    # Bind the api to all addresses
    sed -i s/--insecure-bind-address=127.0.0.1/--insecure-bind-address=0.0.0.0/ /etc/kubernetes/manifests/master.json
fi

if [ "$RUN_ETCD" = "" ]; then
    rm /etc/kubernetes/manifests/etcd.json
fi

/hyperkube kubelet --network-plugin=cni --hostname-override='127.0.0.1' --address='0.0.0.0' --api-servers=${K8S_API} --cluster-dns=10.0.0.10 --cluster-domain=cluster.local --config=/etc/kubernetes/manifests --allow-privileged=true --v=2
