FROM countly/countly-server:16.06

LABEL maintainer "Eugene Zilman <ezilman@gmail.com>"

# Add custom Countly configs - these in turn come from k8s volume
ADD ./runit/countly-api.sh /etc/service/countly-api/run
ADD ./runit/countly-dashboard.sh /etc/service/countly-dashboard/run
