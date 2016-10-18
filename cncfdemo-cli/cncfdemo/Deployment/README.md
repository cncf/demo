### Usage

runner.sh should self configure as master or slave
For slave that just means editing `LISTENER` in /etc/default/distcc with local ip
For master setup DISTCC_HOSTS env variable based on k8s configmap and compile something
