#!/bin/bash

HEADER_CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"

GRAFANA_SERVICE_PORT=${GRAFANA_SERVICE_PORT:-3000}
DASHBOARD_LOCATION=${DASHBOARD_LOCATION:-"/dashboards"}

# Allow access to dashboards without having to log in
export GF_AUTH_ANONYMOUS_ENABLED=${GF_AUTH_ANONYMOUS_ENABLED:-true}
export GF_SERVER_HTTP_PORT=${GRAFANA_SERVICE_PORT}

set -m
echo "Starting Grafana in the background"
exec /usr/sbin/grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini cfg:default.paths.data=/var/lib/grafana cfg:default.paths.logs=/var/log/grafana &

echo "Waiting for Grafana to come up..."
until $(curl -k --fail --output /dev/null --silent localhost:${GRAFANA_SERVICE_PORT}/api/org); do
  printf "."
  sleep 2
done
echo "Grafana is up and running."
echo "Creating default datasource..."

AddDataSource() {
  curl 'http://localhost:3000/api/datasources' \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary \
    '{"name":"Prometheus","type":"prometheus","url":"http://prometheus.monitoring:9090","access":"proxy","isDefault":true}'
}


until AddDataSource; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'


echo ""
echo "Importing default dashboards..."
for filename in ${DASHBOARD_LOCATION}/*.json; do
  echo "Importing ${filename} ..."
  curl -k -i -XPOST --data "@${filename}" -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" "localhost:${GRAFANA_SERVICE_PORT}/api/dashboards/db"
  echo ""
  echo "Done importing ${filename}"
done
echo ""
echo "Bringing Grafana back to the foreground"
fg

