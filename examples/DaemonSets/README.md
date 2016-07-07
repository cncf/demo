# [Daemon Sets](http://kubernetes.io/docs/admin/daemons/)

The usual concept is a pod being provided by the developer and Kubernetes figuring out where to run it. A pod runs _somewhere_, where exactly is not something to be concerned with.

Daemon Sets are the way to run (a copy of a) pod on _all_ the nodes in a Kubernetes cluster. If a Node is added to the cluster it is ensured to get and run a copy of what's defined in the Daemon Set.


## Node Exporter

The Prometheus [Node Exporter](https://github.com/prometheus/node_exporter) is a great example of the DaemonSet functionality being useful.

Cluster wide instrumentation  requires an agent of some sort to run on **every** machine across the fleet. Node Exporter collects and exposes this info via HTTP on a specified port. (Note how hostPID and hostNetwork are toggled on, see [v1beta1 API definitions](http://kubernetes.io/docs/api-reference/extensions/v1beta1/definitions/) for reference)

Alternatively, for a metrics push model you would run [CollectD](https://collectd.org/) (or equivalent) as a DaemonSet. The downside being forced to define _where_  to push metrics measurements to ahead of time.

Another example would be a [Consul](https://www.consul.io/) Agent, 'etc. In short, whenever you need to ensure a copy of something runs across the entire cluster fleet you should use a Daemon Set.
