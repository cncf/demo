# The `cncf` command _shadows and complements_ Kubectl. 

> ❯ cncf create configmap example --from-file=path/to/directory

> ❯ kubectl create configmap example --from-file=path/to/directory

There are advantages besides being 57% shorter to type. Lets compare the two.


## The Kubectl Command
<sub>MacOS: `brew install kubernetes`</sub>

Kubectl is written in Go. It authenticates against an existing Kubernetes cluster.

It interacts with the [remote REST API server](http://kubernetes.io/docs/admin/accessing-the-api/).



## The CNCF Command

<sub>`pip install cncf`, and is coming to your favorite package manager soon.</sub>

cncf is written in Python. It doesn't authenticate against an existing Kubernetes cluster.

It interacts with the [remote REST API server](http://kubernetes.io/docs/admin/accessing-the-api/).

```
In order to use cncf from your machine open a second terminal tab and run:

❯ kubectl proxy
Starting to serve on 127.0.0.1:8001
```




Unlike Kubectl, it is able to create new clusters on your favorite cloud provider (or even bare metal).

For example:
> ❯ cncf bootstrap aws --masters 3 --minions 6

### Complex, Scriptable Kubernetes Deployments & Jinja Templating 

In addition to the ability to quickly spin up new clusters from scratch the `cncf` command comes with a built in demo of a complex multistep multicomponent deployment.

Simply run:
> ❯ cncf demo

The following is going on behind the scenes: 

- [Prometheus](https://github.com/prometheus) and its Pushgateway are deployed
- Grafana is deployed with preconfigured dashboards to expose metrics collected by Prometheus
- ConfigMaps are created from autodetection of configuration files required by the applications being deployed
- A sharded mongo cluster is provisioned 
- One Shot Kuberentes Jobs initialize and configure the mongo cluster
- A mongos service is exposed internally to the cluser
- Multiple instances of [Countly](https://count.ly/) are spun up against the mongo cluster
- Countly service is exposed at a human readable subdomain [countly.cncfdemo.io](countly.cncfdemo.io) via Route53
- HTTP Benchmarking is performed against the Countly subdomain via [WRK](https://github.com/wg/wrk) jobs
- Idle cluster capacity to search for a cure to the Zika virus is donated via [Boinc](https://hub.docker.com/r/zilman/boinc/) and [IBM WorldCommunityGrid](https://www.worldcommunitygrid.org/about_us/viewAboutUs.do)

The demo described above is difficult and brittle to put together with regular `kubectl` usage. Editing YAML files by hand is time consuming and error prone. 

# Behind the scences 

The demo was accomplished with [Jinja](http://jinja.pocoo.org/) templating, several [advanced kubernetes primitives & patterns](Advanced.md) that are currently in Alpha, and extending and adding some functionality to the `cncf` wrapper - all in order to greatly simplify and reduce the number of commands required to accomplish a complex deployment.

# Future Plans

- Additional cloud providers support
- A visualization/UI layer to display the progress of cluster bootstraps, deployments, and benchmarks
