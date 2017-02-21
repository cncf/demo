FROM zilman/kernel
MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN apt-get install -y distcc distcc-pump

COPY config /etc/default/distcc
COPY runner.sh /runner.sh

ENTRYPOINT ["/runner.sh"]

