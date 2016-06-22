#!/bin/sh

wrk -s $script -d$DURATION -c1 -t1 --timeout 1s $URL

