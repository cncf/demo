
# CNCF Technologies Demonstration
The goal of this project is to demonstrate each of the technologies that have been adopted by the [Cloud Native Computing Foundation] (http://cncf.io) (CNCF) in a publicly available repository in order to facilitate their understanding through simple deployment tooling and by providing sample applications as common-ground for conversation. This project will enable replicable deployments and facilitate quantification of performance, latency, throughput, and cost between various deployment models.
# Table of Contents <a id="toc"></a>
- [Project Overview] (#projectoverview)
  - [Sample Applications] (#sampleapps) 
  - [Deployment Models] (#deploymentmodels)
- [Getting Started] (#quickstart)
  - [Dependencies] (#dependencies)
  - [Create Cluster] (#cluster)
  - [Run Demo] (#demo)
- [Architecture] (#arch)
  - [Kubernetes Architecture] (#kubearch)

--- 

## Technologies <a id="techoverview"></a>
1. Kubernetes - [Project] (http://kubernetes.io), [Source] (https://github.com/kubernetes/kubernetes)
2. Prometheus - [Project] (https://prometheus.io), [Source] (https://github.com/prometheus)

## Summary of Sample Applications <a id="sampleapps"></a>
1. Count.ly - [Project] (https://count.ly), [Source] (https://github.com/countly/countly-server) 
  * Goals:
    1. demonstrate autoscaling of Countly
    2. illustrate background, lower priority jobs vs foreground, higher priority jobs
  * [Details of sample application] (#countly)

2. Boinc - [Project] (http://boinc.berkeley.edu), [Source] (https://github.com/BOINC)
  * Goals:
    1. demonstrate grid computing use case
    2. contribute cycles to curing [Zika] (https://en.wikipedia.org/wiki/Zika_virus) in IBM [World Community Grid] (https://www.worldcommunitygrid.org)
  * Details of sample application

## Supported Deployments <a id="deploymentmodels"></a>
A variety of deployments models will be supported. Support for each deployment model will be delivered in this order of priority:

1. Local (on your machine)
2. [CNCF Community Cluster] (#cncf-cluster)
3. AWS
4. Azure
5. GCP
6. Packet

Given this breadth of supported deployment models using the same sample applications, performance, cost, etc. characteristics between this variety of clusters may be compared.

### CNCF Community Cluster <a id="cncf-cluster"></a>
Donated by Intel, a 1,000 node cluster of servers is running in Switch, Las Vegas, to be used by the CNCF community. Visit these links for a description of the cluster [project page] (https://cncf.io/cluster) or to be involved in the [cluster community] (https://github.com/cncf/cluster). 

## An Open Commitment
The project output will be an open source Github repo that will become widely referenced within the CNCF community. All work will occur on a public repo, all externally referenced projects will be open source, and this project itself will be licensed under Apache 2.0. 

## Disclaimer
Note that these are explicitly marketing demos, not reference stacks. The CNCF’s [Technical Oversight Committee] (https://github.com/cncf/toc) will over time be adopting additional projects and may eventually publish reference stacks. By contrast, this project is designed to take the shortest possible path to successful multi-cloud deployments of diverse applications.

# Quick Start Guide <a id="quickstart"></a> <sub><sup>([back to TOC] (#toc))</sup></sub>
Getting started with the `cncfdemo` is a three-step process:

1. [Install cncfdemo] (#dependencies)
2. [Create a Kubernetes cluster, running Prometheus] (#cluster)
3. [Run demo apps & benchmarks] (#demo)

## 1. Install cncfdemo <a id="dependencies"></a>

1. Run `pip install cncfdemo`

   pip is the python package manager. It is strongly recommended to also use a dedicated python virtualenv. For detailed install instructions for your platform read: [The Hitchhiker's Guide to Python](http://docs.python-guide.org/en/latest/starting/install/osx/#setuptools-pip). 
  
## 2. Create Cluster <a id="cluster"></a>

1. `cncfdemo bootstrap aws`

  AWS is used as an example. Substitute with your provider of choice. 
  <sub>**Note**: Grab a beverage, this step takes several minutes.</sub>
  

## 3. Run Demo <a id="demo"></a>

1. Run `cncfdemo start`
2. Browse to [countly.cncfdemo.io](countly.cncfdemo.io)
3. Run `cncfdemo benchmark --time 5m --save-html`
 
### The `cncfdemo` command _shadows and complements_ the official Kubectl binary. 

> ❯ cncfdemo create configmap example --from-file=path/to/directory

> ❯ kubectl create configmap example --from-file=path/to/directory


cncfdemo is written in Python and like Kubectl interacts with the [remote REST API server](http://kubernetes.io/docs/admin/accessing-the-api/). Unlike Kubectl, it supports HTTP only. Further differing from kubectl it is able to create new clusters on your favorite cloud provider (or even bare metal).

### Complex, Scriptable Kubernetes Deployments & Jinja Templating 

In addition to the ability to quickly spin up new clusters from scratch the `cncfdemo` command comes with a built in demo of a complex multistep multicomponent deployment.

When you run:
> ❯ cncfdemo start

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

### Behind the scences 

The demo was accomplished with [Jinja](http://jinja.pocoo.org/) templating, several [advanced kubernetes primitives & patterns](Kubernetes/Docs/Advanced.md) that are currently in Alpha, and extending and adding some functionality to the `cncfdemo` wrapper - all in order to greatly simplify and reduce the number of commands required to accomplish a complex deployment.

### Future Plans

- Additional cloud providers support
- A visualization/UI layer to display the progress of cluster bootstraps, deployments, and benchmarks

# Architecture <a id="arch"></a> <sub><sup>([back to TOC] (#toc))</sup></sub>

## Kubernetes Architecture <a id="kubearch"></a> <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png" width="42px">

This document will walk you through setting up Kubernetes. This guide **_is_** for people looking for a fully automated command to bring up a Kubernetes cluster (In fact, this is the basis for the cncfdemo command utility and you can use that directly or learn how to make your own).

Kubernetes is currently experiencing a cambrian explosion[<sup>1</sup>](https://en.wikipedia.org/wiki/Cambrian_explosion) of deployment methodologies. Described below is an _opinionated_ approach with three guiding principles: 

- Minimal dependencies 
- Portability between cloud providers, baremetal, and local, with minimal alteration
- Image based deployments bake all components into one single image


If you just want to try it out skip to the [Quick start](#quickstart).

## Three Groups

Kubernetes components are neatly split up into three distinct groups*.

<img src="https://raw.githubusercontent.com/cncf/demo/master/Docs/arch.png" width="70%">

<sub>Diagram of a highly available kubernetes cluster</sub>


[etcd](https://github.com/coreos/etcd) is a reliable distributed key-value store, its where the cluster state is kept. The [Source of Truth](https://en.wikipedia.org/wiki/Single_source_of_truth). All other parts of Kubernetes are stateless. You could (and should) deploy and manage an etcd cluster completely independently, just as long as Kubernetes masters can connect and use it.

A highly available etcd is well covered by many other guides. The cncf demo and this document eschew such a setup for simplicity's sake. Instead we opt for a single Kubernetes master with etcd installed and available on 127.0.0.1.

<img src="https://raw.githubusercontent.com/cncf/demo/master/Docs/k8s-simpler.png" width="70%">

Lets zoom in further on one of those circles representing a Kubernetes minion.


<sub><sub>*AWS AutoScalingGroups, GCE "Managed Instance Groups", Azure "Scale Sets"</sub></sub>

## _To thy own self be true_

<sub>Contents of `/etc/sysconfig/kubernetes-minions`:</sub>

```
CLUSTER_NAME=cncfdemo
CLOUD_PROVIDER=--cloud-provider=aws
KUBELET_HOSTNAME=--hostname-override=ip-172-20-0-12.us-west-2.compute.internal
```
<sub><sub>In future kubernetes will autodetect the provider and switch to [EC2 instance-ids instead of resolvable hostnames](https://github.com/kubernetes/kubernetes/pull/7182/files) so latter two lines won't be needed.</sub></sub>

This file is injected into the instance upon creation via user data.

Kubernetes consists of half a dozen binaries with no dependencies, we include _all_ and create and _enable all_ corresponding services. Accordingly, systemd service files include a conditional along the lines of:

> ConditionPathExists=/etc/sysconfig/kubernetes-minions

> ConditionPathExists=!/etc/sysconfig/kubernetes-masters
	
Naturally for a master we create the file with the name 'kubernetes-masters' instead and flip the conditional in the service files.

                        | Master | Minion 
-------------- |------- |--------
kube-apiserver          | ✔      |        |
kube-controller-manager | ✔      |        |
kube-scheduler          | ✔      |        |
kube-proxy              |        | ✔      |
kubelet                 |        | ✔      |
kubectl (No service file)|        |        |

## Cluster bootstrap via DNS discovery  

Later on you will see DNS discovery of services being used extensively **within** Kubernetes clusters as a core feature. But lets continue with the bootstrap, as per the table a minion has only a kubelet and a kube-proxy.

<sub>Contents of `kubelet.service`:</sub>

```
[Service]
EnvironmentFile=/etc/kubernetes/config
EnvironmentFile=/etc/kubernetes/kubelet
EnvironmentFile=/etc/sysconfig/kubernetes-minions
ExecStartPre=/bin/bash -c "until /usr/bin/curl -s http://masters.${CLUSTER_NAME}.k8s:8080; do echo \"waiting for master...\"; sleep 5; done"
ExecStart=/bin/kubelet \
            --api-servers=http://masters.${CLUSTER_NAME}.k8s:8080 \
            $CLOUD_PROVIDER \
            $KUBELET_ARGS

```

The precondition ensures the master is reachable and responsive. 
The endpoint is by convention 'masters.cncfdemo.k8s'.

There are **_many other ways to do this_**, however, this approach is **_not provider specific_**. 

### Making the bookkeeping orthogonal to the deployment process 

For AWS the principles are outlined in _[Building a Dynamic DNS for Route 53 using CloudWatch Events and Lambda](https://aws.amazon.com/blogs/compute/building-a-dynamic-dns-for-route-53-using-cloudwatch-events-and-lambda/)_. 

The process is reduced to the following; 

- Configure CloudWatch to trigger a Lambda function on any and all AutoScalingGroup events
- Lambda funtion simply sets a DNS record set of the private 'k8s' domain to reflect the list of healthy instances in that group

As a result, an AutoScalingGroup with Tags:
```KubernetesCluster, Role```, will always have membership correctly reflected via '{Role}.{KubernetesCluster}.k8s' DNS lookups.


## Software-defined networking for minions


At this point you might be wondering why `minions.{KubernetesCluster}.k8s` is needed. The masters subdomain is useful because the minions need to point at the masters. But who needs to point at minions? The answer is the other minions.

> Kubernetes has a distinctive networking model.

> Kubernetes allocates an IP address to each pod. When creating a cluster, you need to allocate a block of IPs for Kubernetes to use as Pod IPs. 
<sub>-- [Kubernetes Docs](http://kubernetes.io/docs/getting-started-guides/scratch/#network)</sub> 

<img src="https://raw.githubusercontent.com/cncf/demo/master/Docs/sdn.png" width="70%">

In order to let Pod A (10.32.0.1) from one minion node (172.20.0.1) communicate with Pod B (10.32.0.3) on another minion node (172.20.0.2) we use an Overlay network. It is possible to achieve this sort of routing without an overlay network (and associated performance penalty) but an overlay is simpler to configure and more importantly it is **_portable_**.

CNI, the [Container Network Interface](https://github.com/containernetworking/cni), is a proposed standard for configuring network interfaces for Linux application containers. CNI is supported by Kubernetes, Apache Mesos and others.

### Enabling CNI

Required directories for CNI plugin:

 - /opt/cni/bin
 - /etc/cni/net.d
 
 The [default cni plugin](https://github.com/containernetworking/cni/releases) binaries need to be placed in `/opt/cni/bin/`. We have opted to use Weave, its setup script adds weave binaries into this directory as well.
 
 Finally, we direct the Kubelet to use the above:
 
> KUBELET_ARGS="--network-plugin=cni --network-plugin-dir=/etc/cni/net.d --docker-endpoint=unix:///var/run/weave/weave.sock"


### Weave Quorum

Kubernetes will now rely on the Weave service to allocate the ips in the oerlay network.

> PEERS=$(getent hosts minions.cncfdemo.k8s | awk '{ printf "%s ", $1 }')
>
> MEMBERS=$(getent hosts minions.cncfdemo.k8s | wc -l)
>
> /usr/local/bin/weave launch-router --ipalloc-init consensus=$MEMBERS ${PEERS}

You can read further details on [Weave initialization strategies](https://www.weave.works/docs/net/latest/ipam/#quorum). We are using the consensus strategy. In keeping with our example:

- PEERS=172.20.0.63 172.20.0.64
- MEMBERS=2

> Weave Net uses the estimate of the number of peers at initialization to compute a majority or quorum number – specifically floor(n/2) + 1.

> If the actual number of peers is less than half the number stated, then they keep waiting for someone else to join in order to reach a quorum.

Once the quorom has been reached you can see how the IP allocation has been divvied up between the members. 

> weave status ipam
>
> 82:85:7e:7f:71:f3(ip-172-20-0-63)        32768 IPs (50.0% of total)
>
> ce:38:5e:9d:35:ab(ip-172-20-0-64)        32768 IPs (50.0% of total)

<sub>For a deeper dive on how this mechanism works: [Distributed systems with (almost) no consensus](https://www.youtube.com/watch?v=117gWVShcGU).</sub>



# Details of Sample Applications 
## Countly <a id="countly"></a>
Countly is an open source web & mobile analytics and marketing platform. It provides insights about user actions.

## Configuration Files
Two configuration files used to dictate the behavior of this demo application are [api.js] (configMaps/countly/api.js) and [frontend.js] (configMaps/countly/frontend.js). Each configuration file contains only one change from the default configurationonly line changed from the default config:

  `Host: "mongos:default"`

By setting `Host` to "mongos.default", the Countly application looks for its MongoDB servers at the address "mongos.default". The "mongos.default" reference resolves to a Kubernetes service called mongos. The .default namespace is the default top-level domain for pods and services deployed in Kubernetes.

---

## Deep Dive 

- Patterns and Best Practices

  - How to adapt your app to run in Kubernetes (Countly example in detail)
  - Clustred Datastores on top of Kubernetes (Mongo example in detail)
  - Making use of spare capcity with Background Jobs (Boinc example in detail) 

- Complex, Scriptable Kubernetes Deployments & Jinja Templating 
  
  What actually happens when you 'cncfdemo start'
# Notes on Containerizing Apps

## Picking a base image

Inevitably when working with containers the question of the base image comes up. Is it better to opt for the spartan minimalism of Alpines and Busyboxes or a bog standard 700MB CentOS?

Should you split your app into multiple containers each running a single process or bake everything into one blob?

The (typical engineer) answer is "it depends".

Take a complex app like Countly for example. To package it up convinently, so a developer can quickly try it out on her laptop for instance, it is neccessary to bundle Mongo, Nginx, NodeJS, the Countly API server app, and the dashboard UI app.

## Single process per container or... not

You can't always run one process per container. What you really might crave in such a situation is a process control system or even a proper init. 

> Traditionally a Docker container runs a single process when it is launched, for example an Apache daemon or a SSH server daemon. Often though you want to run more than one process in a container. There are a number of ways you can achieve this ranging from using a simple Bash script as the value of your container’s CMD instruction to installing a process management tool. <sub>- [Docker's documentation on using supervisord](https://docs.docker.com/engine/admin/using_supervisord/)</sub>

There's [several such supervisors](http://centos-vn.blogspot.com/2014/06/daemon-showdown-upstart-vs-runit-vs.html), a popular one being [runit](http://smarden.org/runit/). Runit is written in C and uses less resources than supervisord, adheres to the unix philosophy of utilities doing one thing well, and is very reliable.

##### Resolving the PID 1 problem

There's a subtle problem of [Docker and PID 1 zombie reaping](http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/) the aformentioned process supervisors alone don't solve. 

The Ubuntu based [phusion baseimage](http://phusion.github.io/baseimage-docker/) works around this with a small (340 line) [my_init](https://github.com/phusion/baseimage-docker/blob/rel-0.9.16/image/bin/my_init) script.

>Ideally, the PID 1 problem is solved natively by Docker. It would be great if Docker supplies some builtin init system that properly reaps adopted child processes. But as of January 2015, we are not aware of any effort by the Docker team to address this.

As of [September 20, 2016](https://github.com/docker/docker/pull/26061), this is finally fixed by Docker upstream with an optional small new daemon that gets injected with ```--init=true```.

### Customizing Countly for Kubernetes

Countly provides an official [docker image](https://hub.docker.com/r/countly/countly-server/) based on [Phusion](http://phusion.github.io/baseimage-docker/) the advantages and considerations of which are outlined above.

We extend it and simply keep the services we want to use:

```
FROM countly/countly-server:16.06

# Add custom Countly configs - these in turn come from k8s volume
ADD ./runit/countly-api.sh /etc/service/countly-api/run
ADD ./runit/countly-dashboard.sh /etc/service/countly-dashboard/run
```

##### Example service

```
#!/usr/bin/env bash

cp /etc/config/api.js /opt/countly/api/config.js
chown countly:countly /opt/countly/api/config.js

exec /sbin/setuser countly /usr/bin/nodejs /opt/countly/api/api.js
```
<sub>countly-api.sh is almost exactly like the file we replaced.</sub>

This service file is executed by runit and clobbers the default config each time. The file `/etc/config/api.js` is not actually permenantly baked into the image but rather arrives via a Kubernetes configmap.

And here we've had to resort to a bit of a hack. [ConfigMap backed volumes mounted as root](https://github.com/cncf/demo/issues/28) is a known and open issue. At the moment there's no way to specify permissions. Hence, the chown line.

#### Decomposing apps into microservices for Kubernetes

We've completely gotten rid of the Nginx service countly bundles as edge routing can be done any number of ways elsewhere with Kubernetes.

Whether or not we split apart the dashboard app and the API server is not a question of convenience or style. The API server clearly maps to a [replication controller](http://kubernetes.io/docs/user-guide/replication-controller/) and can be horizontally auto scaled with custom metrics (more on this later).

The dashboard app for our purposes has no high availability requirment and is rarely used. However, even when idle, it is taking up resources on the pod and this waste is multipled across however many API servers we end up -- whereas we only need one dashboard app running at a time.

The clean way is to split it out further to one seperate pod on the side.

As for mongo, both of these service contain a connection string we pass as a configmap like so:

```
mongodb: {
        host: "mongos.default",
        db: "countly",
        port: 27017,
        max_pool_size: 500,
    }
```


#### Seperation of concerns 

As a result, it is up to us to deploy and scale mongo seperatly from countly. Even if this particular mongo cluster is dedicated entirely to countly, and it should be, this seperation of concerns is good for maintainability and resilience. 

This decoupling is healthy. For example, a bug in one of the horizontally scaled countly API servers that causes a crash would not take a mongo pod along with it and thus the impact on overall performance is contained. Instead it will crash and burn on the side, the liveliness tests will fail, and Kubernetes in turn will transparantly route away further requests to siblings while simultanousely launching a replacement. 

- graph showing how chaos-monkey style killing one of the countlies impacts overall writes, and for how long (fast recovery is cool)

#### InitContainers

Ask yourself, does it make sense for Countly pods to be running when there is no Mongo backend available to them? The answer is no. In fact, if Countly happens to start first the deployment becomes unpredictable.

Luckily [init containers](https://github.com/kubernetes/kubernetes/blob/release-1.4/docs/proposals/container-init.md) have reached beta status in the latest version of Kubernetes (1.4). In short, with this feature enabled the pod you normally specify alone now starts last in a blocking list.

```
pod:
  spec:
    containers: ...
    initContainers:
    - name: init-container1
      image: ...
      ...
    - name: init-container2
    Containers:
    - name: regularcontainer
    
```

init-container1 can have a simple command along the lines of `nslookup monogos.default | -ge 3`. This will fail as long as the mongo service is not up and running and passing its readyness and liveliness probes. Countly will be blocked from starting until the init container succeeds, exactly the desired behaviour. 

### Deploying a Mongo cluster with Kubernetes

Separate article?
