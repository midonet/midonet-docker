FROM gcr.io/google_containers/hyperkube-amd64:v1.2.4
MAINTAINER MidoNet (http://midonet.org)

# We don't need the kube-proxy
RUN rm /etc/kubernetes/manifests/kube-proxy.json

# MidoNet configuration files
ADD conf/midonet.list /etc/apt/sources.list.d/midonet.list
ADD conf/kuryr.conf /usr/libexec/kubernetes/kubelet-plugins/net/exec/kuryr.conf
ADD scripts/run_kubelet.sh /kubelet

# # Install Java 8 (jessie-backports must be added)
RUN echo "deb http://httpredir.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
    && apt-get -qqy update \
    && apt-get install -qy openjdk-8-jdk --no-install-recommends \
    && rm -fr /var/lib/apt/lists/*

# Midonet key
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv \
     E9996503AEB005066261D3F38DDA494E99143E75

# We need to have the CNI driver installed in the kubelet container
# Clone the kuryr project and install
RUN apt-get -qy update \
    && apt-get -qy install git python3 python3-dev build-essential --no-install-recommends \
    && curl -s https://bootstrap.pypa.io/get-pip.py | python3 1>/dev/null \
    && git clone http://github.com/midonet/kuryr /opt/kuryr -b k8s \
    && cd /opt/kuryr \
    && pip3 install . \
    && rm -fr /var/lib/apt/lists/*

# Install mm-ctl
RUN apt-get -qy update \
    && apt-get install -qqy python-setproctitle \
    && cd /tmp \
    && apt-get download midolman \
    && mv midolman* midolman.deb \
    && dpkg -i --ignore-depends=openvswitch-datapath-dkms,bridge-utils,haproxy,quagga,libreswan,iproute,midonet-tools /tmp/midolman.deb \
    && rm -fr /var/lib/apt/lists/* /etc/apt/sources.list.d/*

# Set ENV VARS
ENV ZK_ENDPOINTS="127.0.0.1:2181"
ENV UUID=""
ENV RUN_API=""
ENV RUN_ETCD=""
ENV K8S_API="http://localhost:8080"

CMD ["/kubelet"]
