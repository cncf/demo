# Kuberentes Postmortem

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