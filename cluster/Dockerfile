FROM ubuntu:14.04
MAINTAINER MidoNet (https://www.midonet.org)

ADD conf/midonet.list /etc/apt/sources.list.d/midonet.list

RUN set -xe \
  \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv \
  E9996503AEB005066261D3F38DDA494E99143E75 \
  && apt-get -qy update \
  && apt-get -qy dist-upgrade \
  \
  && apt-get -qy install software-properties-common \
  && add-apt-repository -y ppa:openjdk-r/ppa \
  && apt-get -qy update \
  && apt-get -qy install openjdk-8-jre --no-install-recommends \
  \
  && apt-get -qy install midonet-cluster \
  \
  && apt-get -qy remove --auto-remove software-properties-common \
  && rm -fr /var/lib/apt/lists/* /etc/apt/sources.list.d/*

ADD scripts/run-cluster.sh /cluster

EXPOSE 8181

ENV CASSANDRA_FACTOR=3
ENV ZK_ENDPOINTS="127.0.0.1:2181"
ENV KEYSTONE_HOST="127.0.0.1"
ENV KEYSTONE_PORT=35357
ENV KEYSTONE_TENANT_NAME="admin"
ENV KEYSTONE_ADMIN_TOKEN="admintoken"
ENV UUID=""

# Agent-related cluster level configuration
ENV AGENT_LOG_LEVEL="INFO"
ENV C_FACTOR=3
ENV C_SERVERS=""

VOLUME /var/log/midonet-cluster

CMD ["/cluster"]
