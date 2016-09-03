# Kubernetes The Reasonably hard Way 

<img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png" width="42px">

## Overview

This document will walk you through setting up Kubernetes the reasonably hard way. This guide **_is_** for people looking for a fully automated command to bring up a Kubernetes cluster (In fact, this is the basis for the cncfdemo command utility and you can use that project or learn how to make your own).

Kubernetes is currently experiencing a cambrian explosion[<sup>1</sup>](https://en.wikipedia.org/wiki/Cambrian_explosion) of deployment methodologies. Described below is an _opinionated_ approach with three guiding principles: 

- Minimal dependencies 
- Portability between cloud providers, baremetal, and local, with minimal alteration
- Image based deployments bake all components into one single image


If you just want to try it out skip to the [Quick start](https://github.com/cncf/demo/blob/master/Kubernetes/Docs/Quickstart.md).

## Three Groups

Kubernetes components are neatly split up into three distinct groups*.

<img src="arch.png" width="70%">

<sub>Diagram of a highly available kubernetes cluster</sub>


[etcd](https://github.com/coreos/etcd) is a reliable distributed key-value store, its where the cluster state is kept. The [Source of Truth](https://en.wikipedia.org/wiki/Single_source_of_truth). All other parts of Kubernetes are stateless. You could (and should) deploy and manage an etcd cluster completely independently, just as long as Kubernetes masters can connect and use it.

A highly available etcd is well covered by many other guides. The cncf demo and this document eschew such a setup for simplicity's sake. Instead we opt for a single Kubernetes master with etcd installed and available on 127.0.0.1.

<img src="k8s-simpler.png" width="70%">

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

<img src="sdn.png" width="70%">

In order to let Pod A (10.32.0.1) from one minion node (172.20.0.1) communicate with Pod B (10.32.0.3) on another minion node (172.20.0.2) we use an Overlay network. It is possible to achieve this sort of routing without an overlay network (and associated performance penalty) but an overlay is simpler to configure and more importantly it is **_portable_**.

CNI, the [Container Network Interface](https://github.com/containernetworking/cni), is a proposed standard for configuring network interfaces for Linux application containers. CNI is supported by Kubernetes, Apache Mesos and others.

