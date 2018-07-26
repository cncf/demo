#!/bin/sh

set -ex

service iceccd start  # same as iceccd -s $icemaster
sleep infinity
