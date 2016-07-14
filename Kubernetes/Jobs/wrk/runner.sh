#!/bin/sh

set -ex

if [ -z "$URL" ]; then echo "URL Required" && exit 1; fi

# Wrk Defaults
SCRIPT=${SCRIPT-/wrk/send_summary.lua}
DURATION=${DURATION-5}
CONNECTIONS=${CONNECTIONS-5}
THREADS=${THREADS-2}
TIMEOUT=${TIMEOUT-3}

# Global Defaults
export hostIP=$(curl -m1 -s http://169.254.169.254/latest/meta-data/local-ipv4)
export podID=$(hostname | cut -d- -f4)

hostIP=${hostIP:=127.0.0.1}
podID=${podID:=42}

export PUSHGATEWAY_SERVICE_PORT=${PUSHGATEWAY_SERVICE_PORT:=9091}
export PUSHGATEWAY=${PUSHGATEWAY-pushgateway}

wrk -s $SCRIPT -d$DURATION -c$CONNECTIONS -t$THREADS --timeout $TIMEOUT $URL
