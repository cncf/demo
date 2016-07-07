#!/bin/sh

wrk -s $SCRIPT -d$DURATION -c$CONNECTIONS -t$THREADS --timeout $TIMEOUT $URL

