FROM debian:stable
LABEL maintainer "Eugene Zilman <ezilman@gmail.com>"

RUN apt-get clean && apt update && apt install -y

RUN apt install -y kernel-package
RUN apt install -y git build-essential
RUN apt install -y distcc distcc-pump

COPY config /etc/default/distcc
COPY runner.sh /runner.sh

ENTRYPOINT ["/runner.sh"]
