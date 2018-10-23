FROM centos:centos7
MAINTAINER micklove
ARG gitsha
ARG buildno

RUN yum install -y squid && \
    yum install -y python && \
    yum -y install epel-release && \
    yum -y install less && \
    yum -y install python-pip && \
    pip -v && \
    pip install j2cli  && \
    yum clean all  && \
    rm -rf /var/cache/yum

ADD squid.conf.j2 /etc/squid/squid.conf.j2
ADD run-container.sh /run-container.sh

# Make cache dirs
RUN yum install -y nc
EXPOSE 3128
VOLUME /squid
CMD /run-container.sh
