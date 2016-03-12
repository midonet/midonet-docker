FROM gliderlabs/alpine
MAINTAINER Antoni Segura Puimedon "toni@midokura.com"
WORKDIR /
RUN apk add --no-cache \
    bash \
    bridge-utils \
    haproxy \
    openjdk8 \
    quagga && \
    apk add --no-cache --virtual build-deps \
        curl \
        tar \
        xz && \
    curl http://119.15.120.38:8000/midolman_5.2-201603111652.c6374cb.tar.xz | tar xJvf - && \
    curl http://119.15.120.38:8000/midonet-tools-5.2-201603111652.c6374cb.tar.xz | tar xJvf - && \
    apk del build-deps

ADD scripts/run-midolman.sh /run-midolman.sh

ENV MIDO_ZOOKEEPER_HOSTS="127.0.0.1:2181" MIDO_ZOOKEEPER_ROOT_KEY="/midonet"

CMD ["/run-midolman.sh"]
