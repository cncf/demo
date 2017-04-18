
boinccmd --lookup_account http://www.worldcommunitygrid.org zilman zombocom
status: Success
poll status: operation in progress
account key: d2804d9d05efdad427b69bc020d5492f

pkill boinc

/var/lib/boinc-client
boinc &
boinccmd --project_attach http://www.worldcommunitygrid.org d2804d9d05efdad427b69bc020d5492f

weak account key is "better":

boinccmd --project_attach http://www.worldcommunitygrid.org 1013367_21303863232c651457665d59cf936248 

/usr/bin/boinc --skip_cpu_benchmarks --exit_after_finish --fetch_minimal_work --exit_when_idle --abort_jobs_on_exit --no_gpus 



