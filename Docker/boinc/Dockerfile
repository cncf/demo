FROM phusion/baseimage:0.9.19

MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN apt update -y && \
    apt install -y boinc-client && \
    apt-get clean &&  \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN mkdir -p /var/lib/boinc-client/projects/www.worldcommunitygrid.org && \
    mkdir -p /var/lib/boinc-client/slots && \
    chown -R boinc:boinc /var/lib/boinc-client 

ADD runner.sh /var/lib/boinc-client
ADD attach.sh /var/lib/boinc-client

WORKDIR /var/lib/boinc-client

ENTRYPOINT ["/var/lib/boinc-client/runner.sh"]
