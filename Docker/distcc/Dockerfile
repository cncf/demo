FROM debian:stable
MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN apt update && \
      apt install -y distcc distcc-pump

COPY config /etc/default/distcc

