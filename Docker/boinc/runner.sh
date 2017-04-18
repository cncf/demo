#!/bin/sh
set -ex

/sbin/setuser boinc /var/lib/boinc-client/attach.sh &

exec /sbin/setuser boinc /usr/bin/boinc --exit_after_finish --fetch_minimal_work --exit_when_idle --abort_jobs_on_exit --no_gpus >>/var/lib/boinc-client/log 2>&1 
