# Kubernetes [Jobs](http://kubernetes.io/docs/user-guide/jobs/)

Every story has a beginning, a middle, and an end.
A Job is similar to a regular Deployment with a terminating condition. 

This is useful for various things, for instance a benchmark.

Here we are demonstrating how Kubernetes ensures a certain amount of succesful completions of a scriptable [WRK](https://github.com/wg/wrk) HTTP benchmarking pod. The pods all report metrics to a Prometheus Pushgateway service independently of each other. The number of pods a job runs in parallel is configurable, as well as how many concurrent requests each WRK pod attempts to make.
