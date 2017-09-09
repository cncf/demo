FROM debian:jessie-slim

MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN apt install -y icecc
COPY runner.sh /runner.sh

ENTRYPOINT ["/runner.sh"]

