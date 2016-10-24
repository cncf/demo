FROM debian:stable
MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN apt update

RUN apt install -y kernel-package
RUN apt install -y git build-essential
RUN apt install -y distcc distcc-pump

COPY config /etc/default/distcc
COPY runner.sh /runner.sh

ENTRYPOINT ["/runner.sh"]

