FROM ubuntu-upstart:14.04
MAINTAINER MidoNet (http://midonet.org)

ONBUILD ADD conf/cloudarchive-ost.list /etc/apt/sources.list.d/cloudarchive-ost.list
ONBUILD RUN apt-mark hold udev
ONBUILD RUN apt-get install -qy ubuntu-cloud-keyring
ONBUILD RUN apt-get -q update && apt-get -qy dist-upgrade
ONBUILD RUN echo "manual" > /etc/init/keystone.override
ONBUILD RUN apt-get install -qy --no-install-recommends keystone python-openstackclient

EXPOSE 5000 35357

ADD bin/run-keystone.sh /run-keystone.sh

ENV DB_USER='keystone'  \
    DB_PASSWORD='admin' \
    DB_NAME='keystone'  \
    DB_HOST='localhost' \
    OS_TOKEN='admin' \
    OS_DEBUG='False'                         \
    OS_VERBOSE='False'

CMD ["/run-keystone.sh"]
