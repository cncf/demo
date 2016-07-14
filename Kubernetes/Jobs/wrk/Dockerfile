FROM williamyeh/wrk:4.0.2

MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN apk add --update curl --no-cache

ADD runner.sh /wrk/
ADD send_summary.lua /wrk/

ENTRYPOINT ["/wrk/runner.sh"]
