FROM debian:jessie-slim

MAINTAINER Eugene Zilman <ezilman@gmail.com>

ADD mozconfig /root/mozconfig

RUN apt install -y git icecc

COPY runner.sh /runner.sh

ENTRYPOINT ["/runner.sh"]

