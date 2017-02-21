
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
- [Postmortem & Suggestions] (#postmortem)

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

The demo was accomplished with [Jinja](http://jinja.pocoo.org/) templating, several [advanced kubernetes primitives & patterns](Advanced.md) that are currently in Alpha, and extending and adding some functionality to the `cncfdemo` wrapper - all in order to greatly simplify and reduce the number of commands required to accomplish a complex deployment.

### Future Plans 

- Additional cloud providers support
- A visualization/UI layer to display the progress of cluster bootstraps, deployments, and benchmarks

# Architecture <a id="arch"></a> <sub><sup>([back to TOC] (#toc))</sup></sub>

## Image based Kubernetes deployments

The Kubernetes project consists of half a dozen standalone binaries, copied to their appropriate location along with associated Systemd unit files*.

                        | Master | Minion 
-------------- |------- |--------
kube-apiserver          | ✔      |        |
kube-controller-manager | ✔      |        |
kube-scheduler          | ✔      |        |
kube-proxy              |        | ✔      |
kubelet                 |        | ✔      |
kubectl (No service file)|        |        |

<img src="https://raw.githubusercontent.com/cncf/demo/master/docs/k8s-cube.png" width="300px">

The first three belong on master nodes, kube-proxy and kubelet belong on minions, and kubectl is just an optional handy utility to have on the path.

Instead of cutting seperate images for masters and minions we rely on Cloud-init -- the defacto multi-distribution package that handles early initialization of a cloud instance -- and Systemd drop-in files to tag an instance as a master or minion. 

### Systemd drop-in files

The Kubernetes unit files are written upstream and should work on any distro that supports systemd. There's no need to edit them directly, they are as static as their associated binaries. 

Instead, we want to override only specific directives from these unit files. Systemd has a mechanism that picks up drop-in files and appends or modifies a unit file's directives.

So for example, an _upstream provided_ unit file for kube-apiserver exists at `/lib/systemd/system/kube-apiserver.service`, we simply _add_ a file at `/lib/systemd/system/kube-apiserver.service.d/role.conf` with the contents:

> ConditionPathExists=/etc/sysconfig/kubernetes-master

At boot Systemd will essentially merge role.conf into the original unit file, and start the kube-apiserver service based on whether or not a file exists at `/etc/sysconfig/kubernetes-masters` (This is called path based activation).

<img src="https://raw.githubusercontent.com/cncf/demo/master/docs/cloud-init.png" width="300px">

With this baked into a server image (by a tool like Packer) all that is left is to specify how many copies we want to run and tell cloud-init to create the file. This functionality is **common to basically any modern distro and cloud provider**, and library (like boto) or provisioning tool (like Terraform).

For example on AWS:

`aws ec2 run-instances --image-id ami-424242 --count 3 --user-data 'touch /etc/sysconfig/kubernetes-master'`

#### Other useful settings cloud-init can override 

* The clustername - Kubernetes clusters require a unique id
* The url to pull the addons manager from (so it doesn't have to be baked into the image)
* The master endpoint 
	- not recommended but useful for testing; The preferable approach is to provision the cloud environment to route by convention masters.{clustername}.domainame
* Other endpoints for customized images that include things like fluentd forwarding logs to S3, The cncfdemo backend API, 'etc.

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

Lets zoom in further on one of those circles representing a Kubernetes minion.


<sub><sub>*AWS AutoScalingGroups, GCE "Managed Instance Groups", Azure "Scale Sets"</sub></sub>


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

# Postmortem & Suggestions <a id="postmortem"></a>

## Abstract

Kubernetes can run on a wide range of Cloud providers and bare-metal environments, and with many base operating systems.

Major releases roll out approximately every 15 weeks with requirements and dependencies still somewhat in flux. Additionally, although there are unit and integration tests that must be passed before a release, in a distributed system it is not uncommon that minor changes may pass all tests, but cause unforeseen changes at the system level. 

There's a growing plurality of outdated and conflicting information on how to create a Kubernetes cluster from scratch. Furthermore, and perhaps most painfully, while a release can be assumed to be reasonably stable in the environment it was tested in ("works for me"), not many guarantees can yet be made about how things will work for a custom deployment. 


What follows chronologically describes one beaten path to a custom cluster and some of the dos and don'ts accumulated from the false starts.

## Picking a host operating system

<sub><sub>_"If you wish to make an apple pie from scratch, you must first invent the universe."_ -- [Carl Sagan](https://www.youtube.com/watch?v=7s664NsLeFM)</sub></sub>

Starting out on AWS one might be tempted to quick start from the web console and opt for Amazon Linux AMI. But that is not a portable choice. So at least for the sake of portability (perhaps in the future you'll want to run on another cloud provider, bare metal, or your laptop) it is better to opt for something like CentOS, Debian, or CoreOS.

This is not an easy choice and there is no universal answer. Each option brings along its own dependencies, problems, and bugs. But since choose we must we will go down the CentOS direction of this decision tree and see how far it takes us.

### CentOS 7

[Official CentOS images](https://wiki.centos.org/Cloud/AWS) are provided for us on the AWS Marketplace.

To avoid ending up with deprecated AMI's and outdated images it is recommended to grab the AMI id programmatically (`aws --region us-west-2 ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce`) and in case of a response with multiple ids pick the one with the most recent creation date as well as running `yum update` as the first step in your build process.

### Default Docker is strongly discouraged for production use

Docker is not actually a hard requirement for Kubernetes, but this isn't about recommending alternative container runtimes. This is about the defaults being a hidden minefield.

#### The warning 

What happens with the common `yum install docker`?

> $ docker info


```
Containers: 0
Server Version: 1.10.3
Storage Driver: devicemapper
 Pool Name: docker-202:1-9467182-pool
 Pool Blocksize: 65.54 kB
 Base Device Size: 10.74 GB
 Backing Filesystem: xfs
 Data file: /dev/loop0
 Metadata file: /dev/loop1
 ..
 Data loop file: /var/lib/docker/devicemapper/devicemapper/data
 WARNING: Usage of loopback devices is strongly discouraged for production use.
 Metadata loop file: /var/lib/docker/devicemapper/devicemapper/metadata
```

As you can see from the warning, the default Docker storage config that ships with CentOS 7 is not recommended for production use. Using devicemapper with loopback can lead to unpredictable behaviour.

In fact, to give a bit of a look into this dead end if we follow the path all the way to a Kubernetes cluster you will see nodes coming up like this:

```
systemctl --failed
  UNIT                         LOAD   ACTIVE SUB    DESCRIPTION
● docker-storage-setup.service loaded failed failed Docker Storage Setup
● kdump.service                loaded failed failed Crash recovery kernel arming
● network.service              loaded failed failed LSB: Bring up/down networking
```

#### What docker-storage-setup is trying (and failing) to do 

`docker-storage-setup` looks for free space in the volume group of the root volume and attempts to setup a thin pool. If there is no free space it fails to set up a LVM thin pool and will fall back to using loopback devices. Which we are warned by docker itself is a `strongly discouraged` outcome.

#### Why this is a problem

This is insidious for several reasons. Depending on how many volumes your instance happens to spin up with (and how they're configured) you might never see this warning or experience any problem at all. For example if you have one hard-drive on bare-metal and no unallocated space this will always happen.

If the disk provisioning changes you might end up in this edge case but the cluster will _still_ initially appear to be working. Only after some activity will xfs corruption in the docker image tree (`/var/lib/docker`) start to sporadically manifest itself and kubernetes nodes will mysteriously fail as a result. 


Despite this being [known as problematic](https://twitter.com/codinghorror/status/604096348682485760) for some time and [documented](https://access.redhat.com/documentation/en/red-hat-enterprise-linux-atomic-host/7/single/getting-started-with-containers/#overlay_graph_driver), people still frequently [run into this](https://forums.docker.com/t/docker-with-devicemapper-doesnt-start-on-centos-7/9641) problem.  

Incidentally `yum install docker` can result in slightly different versions of docker installed. 

> Each docker release has some known issues running in Kubernetes as a runtime.

[So what's the recommended docker version](https://github.com/kubernetes/kubernetes/issues/25893 )? v1.12 or v1.11? It turns out the latest (v1.12) is not yet supported by Kubernetes v1.4.

_The problem is a distribution like CentOS 7, officially supported by Kubernetes, by default will arbitrarily work for some but not others, with the full requirements hidden and **underspecified**._

At the very least Docker versions should be pinned together with OS and Kubernetes versions and a recommendation about the storage driver should be made.


#### To avoid these pitfalls, carefully select the storage driver

As Docker has a [pluggable storage driver architecture](https://docs.docker.com/engine/userguide/storagedriver/selectadriver/) and the default is (or might be) inappropriate, you must carefully consider your options. As discussed, getting this wrong will eventually cascade all the way to hard to debug and reproduce bugs and broken clusters.

>Which storage driver should you choose?
Several factors influence the selection of a storage driver. However, these two facts must be kept in mind:

> - No single driver is well suited to every use-case
> - Storage drivers are improving and evolving all of the time

The docker docs don't take a position either. If one doesn't want to make assumptions about how many disks a machine has (laptops, bare metal servers with one drive, 'etc) direct LVM is out.

AUFS [was the original backend](http://jpetazzo.github.io/assets/2015-03-03-not-so-deep-dive-into-docker-storage-drivers.html#28) used by docker but is not in the mainline kernel (it is however included by debian/ubuntu).

Overlay is in mainline and supported as a Technology Preview by RHEL.

Additionally _"Many people consider OverlayFS as the future of the Docker storage driver"_. It is the future proof way to go.

##### Overlay Dependencies

- CentOS 7.2
- _"Only XFS is currently supported for use as a lower layer file system."_
- _"/etc/sysconfig/docker must not contain --selinux-enabled"_ (for now)

With the above satisfied, to enable overlay simply:

`echo "overlay" > /etc/modules-load.d/overlay.conf`

And add the flag (`--storage-driver=overlay`) in the docker service file or DOCKER_OPTS (`/etc/default/docker`).

This requires a reboot, but first...

### Properly configure netfilter

`docker info` had another complaint.

```
WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
```

This toggles whether packets traversing the bridge are forwarded to iptables.
This is [docker issue #24809](https://github.com/docker/docker/issues/24809) and _could_ be ignored ("either /proc/sys/net/bridge/bridge-nf-call-iptables doesn't exist or is set to 0"). CentOS and most distros default this to 0.

If I was writing a choose your own adventure book this is the point I'd write that thunder rumbles in the distance, a quiet intensity.

If you follow _this_ dead end all the way to a Kubernetes cluster you will find out that **kube-proxy requires that bridged traffic passes through netfilter**. So that path should absolutely exist otherwise you have a problem.

Furthermore you'll find that [kube-proxy will not work properly with Weave on Centos](https://github.com/kubernetes/kubernetes/issues/33790) if this isn't toggled to 1. At first everything will appear to be fine, the problem only manifests itself by kubernetes service endpoints not being routable.

To get rid of these warnings you might try:

`echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables`

`echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables`

This would toggle the setting but not persist after a reboot. Once again, this will cause a situation where a cluster will initially appear to work fine.

The above settings used to live in /etc/sysctl.conf the contents of which nowadays are:

```
# System default settings live in /usr/lib/sysctl.d/00-system.conf.
# To override those settings, enter new settings here, or in an /etc/sysctl.d/<name>.conf file
```

This file is sourced on every invocation of `sysctl -p`.

Attempting to toggle via `sysctl -p` [gives the following error](https://github.com/ansible/ansible/issues/6272) under certain conditions:

```
error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
error: "net.bridge.bridge-nf-call-iptables" is an unknown key
```

Since `sysctl` runs at boot there's also a very possible race condition [if the bridge module hasn't loaded yet](https://bugzilla.redhat.com/show_bug.cgi?id=1054178#c1) at that point. Making this a (sometimes) misleading error message.

The correct way to set this as of CentOS7:

> $ cat /usr/lib/sysctl.d/00-system.conf

```

# Kernel sysctl configuration file
#
# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and
# sysctl.conf(5) for more details.

# Disable netfilter on bridges.
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

```

> $ cat /usr/lib/sysctl.d/90-system.conf

```
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

This way systemd ensures these settings will be evaluated whenever a bridge module is loaded and the race condition is avoided.

Speaking of misleading error messages, kubernetes logs an [incorrect br-netfilter warning on Centos 7](https://github.com/kubernetes/kubernetes/issues/23385):

> proxier.go:205] missing br-netfilter module or unset br-nf-call-iptables; proxy may not work as intended

Stay the course, there's nothing else to toggle to make this warning go away, it is simply a false positive.

### Consider disabling selinux

With Overlay as the storage backend currently you can only run with selinux on the host, a temporary limitation. 

However, elsewhere, kubernetes uses a mechanism that injects special volumes into each container to expose service account tokens and [with selinux turned on secrets simply don't work](http://stackoverflow.com/questions/35338213/kubernetes-serviceaccounts-and-selinux/35347520#35347520).

The work around is to set the security context of volume on the kubernetes host (`sudo chcon -Rt svirt_sandbox_file_t /var/lib/kubelet`) or set selinux to permissive mode.

Otherwise down the line [kubernetes add-ons](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons) will fail or behave unpredictably. For example KubeDNS will fail to authenticate with the master and [dns lookups on service endpoints will fail](https://github.com/cncf/demo/issues/103). (Slightly differs from the bridge netfilter disabled problem described above which results in routing by ip intermittently failing)

Since there might be other selinux permissions necessary elsewhere consider turning off selinux entirely until this is properly decided upon and documented.

### Correct CNI config


Kubernetes supports [CNI Network Plugins](http://kubernetes.io/docs/admin/network-plugins/#cni) for interoperability. Setting up a network overlay requires this dependency.

Kubernetes 1.3.5 [broke the cni config](https://github.com/kubernetes/kubernetes/issues/30681) — as of that version it is necessary to pull in the [cni release binaries](https://github.com/containernetworking/cni/releases) into the cni bin folder.

As of Kuberentes 1.4 the [flags to specify cni directories](https://github.com/kubernetes/kubernetes.github.io/pull/1516) changed and documentation was added pinning the minimum cni version to 0.2 and at least the `lo` binary.

### Other Dependencies

There's [additional undocumented missing dependencies](https://github.com/cncf/demo/issues/64) as follows:

   - conntrack-tools
   - socat
   - bridge-utils

### AWS specific requirements & debugging

[Peeking under the hood of Kubernetes on AWS](https://github.com/kubernetes/kubernetes/blob/master/docs/design/aws_under_the_hood.md#tagging) you'll find:

> All AWS resources are tagged with a tag named "KubernetesCluster", with a value that is the unique cluster-id. This tag is used to identify a particular 'instance' of Kubernetes, even if two clusters are deployed into the same VPC. Resources are considered to belong to the same cluster if and only if they have the same value in the tag named "KubernetesCluster".

This isn't only necessary to differentiate resources between different clusters in the same VPC but also needed for the controller to discover and manage AWS resources at all (even if it has an entire VPC to itself).

Unfortunately these tags are [not filtered on in a uniform manner across different resource types](https://github.com/cncf/demo/issues/144).

A `kubectl create -f resource.yaml` successfully submitted to kubernetes might not result in expected functionality (in this case a load balancer endpoint) even when the desired resource shows as `creating...`. It will simply show that indefinitely instead of an error.

Since the problem doesn't bubble up to kubectl responses the only way to see that something is amiss is by carefully watching the controller log.

```
aws.go:2731] Error opening ingress rules for the load balancer to the instances: Multiple tagged security groups found for instance i-04bd9c4c8aa; ensure only the k8s security group is tagged
```

[Reading the code](https://github.com/kubernetes/kubernetes/blob/master/pkg/cloudprovider/providers/aws/aws.go#L2783) yields:

```
// Returns the first security group for an instance, or nil
// We only create instances with one security group, so we don't expect multiple security groups.
// However, if there are multiple security groups, we will choose the one tagged with our cluster filter.
// Otherwise we will return an error.
```

In this example the kubernetes masters and minions each have a security group, both security groups are tagged with "KubernetesCluster=name". Removing the tags from the master security group resolves this problem as now the controller receives an expected response from the AWS API. It is easy to imagine many other scenarios where such conflicts might arise if the tag filtering is not consistent.

Smoke tests that simply launch and destroy a large amount of pods and resources would not catch this problem either.

## Conclusion

The most difficult bugs are the ones that occur far away from their origins.
Bugs that will slowly but surely degrade a cluster and yet sneak past continuous integration tests.

Additionally the target is a moving one. Minor releases of kubernetes can still have undocumented changes and undocumented dependencies.

If a [critical Add-Ons fails](https://github.com/kubernetes/kubernetes/issues/14232) seemingly identical clusters deployed minutes apart will have divergent behaviour. The cloud environments clusters slot into are also a source of state and therfore subtle edgecase that can confuse the controller and silently prevent it from deploying things.

In short, this is a complex support matrix.

A possible way to improve things is by introducing:

- A set of host OS images with minimal changes baked in as neccessary for Kubernetes

	- Continuously (weekly?) rebased on top of the latest official images 


	- As the basis for a well documented reference implementation of a custom cluster 
		
- Long running custom clusters spun up for each permutation of minor version updates (kubernetes version bump, weave, flannel, etcd, and so on) 

- A deterministic demo app/deployment as a comprehensive smoketest & benchmark


The community need to mix and match the multiple supported components with arbitrary neccessary for custom deployments can be benefit from a set of "blessed"  kubernetes-flavored host OS images and a more typical real-world artifcat to check their customizations against.
