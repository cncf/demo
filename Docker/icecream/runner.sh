#!/bin/sh

set -ex

time git clone https://github.com/mozilla/gecko-dev.git
cd gecko-dev && git checkout release

export MOZCONFIG=/root/mozconfig

./mach bootstrap --no-interactive

export PATH="$HOME/.cargo/bin:$PATH"
export PATH=/usr/lib/icecc/bin:$PATH

service icecc-scheduler start
service iceccd start # both on same box are fine, need at least one d

./mach configure
./mach build

sleep infinity
