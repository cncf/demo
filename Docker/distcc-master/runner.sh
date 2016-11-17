#!/bin/sh

set -ex

/etc/init.d/distcc start

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
cd linux-stable && make defconfig

export DISTCC_HOSTS="$(getent hosts distcc | awk '{ printf "%s,cpp,lzo ", $1 }')"
export N_JOBS="$(echo $(getent hosts distcc | wc -l)+2 | bc)"

distcc --show-hosts

eval $(distcc-pump --startup)
export PATH=/usr/lib/distcc:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DISTCC_VERBOSE=1 make -j$N_JOBS 2>&1 | tee build.log

sleep infinity
