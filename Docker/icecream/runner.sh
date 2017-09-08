#!/bin/sh

set -ex

time git clone https://github.com/mozilla/gecko-dev.git
cd gecko-dev && git checkout release

export MOZCONFIG=/root/mozconfig

./mach bootstrap --no-interactive

export PATH="$HOME/.cargo/bin:$PATH"
export PATH=/usr/lib/icecc/bin:$PATH

./mach configure
./mach build

sleep infinity
