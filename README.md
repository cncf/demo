# CNCF Technologies Demonstration
The goal of this project is to demonstrate each of the technologies that have been adopted by the [Cloud Native Computing Foundation] (http://cncf.io) (CNCF) in a publicly available repository in order to facilitate their understanding through simple deployment tooling and by providing sample applications as common-ground for conversation. This project will enable replicable deployments and facilitate quantification of performance, latency, throughput, and cost between various deployment models.

## Projects
The following projects have been incorporated into this demo program. As new projects are adopted by the CNCF, subsequently, they will be incorporated here. 

1. Kubernetes - [Project] (http://kubernetes.io), [Source] (https://github.com/kubernetes/kubernetes)
2. Prometheus - [Project] (https://prometheus.io), [Source] (https://github.com/prometheus)


## Sample Applications
1. Count.ly - [Project] (https://count.ly), [Source] (https://github.com/countly/countly-server) 
  * Goals:
    1. demonstrate autoscaling of Countly
    2. illustrate background, lower priority jobs vs foreground, higher priority jobs

2. Boinc - [Project] (http://boinc.berkeley.edu), [Source] (https://github.com/BOINC)
  * Goals:
    1. demonstrate grid computing use case
    2. contribute cycles to curing [Zika] (https://en.wikipedia.org/wiki/Zika_virus) in IBM [World Community Grid] (https://www.worldcommunitygrid.org)

## Open
The project output will be an open source Github repo that will become widely referenced within the CNCF community. All work will occur on a public repo, all externally referenced projects will be open source, and this project itself will be licensed under Apache 2.0. 

## Disclaimer
Note that these are explicitly marketing demos, not reference stacks. The CNCF’s [Technical Oversight Committee] (https://github.com/cncf/toc) will over time be adopting additional projects and may eventually publish reference stacks. By contrast, this project is designed to take the shortest possible path to successful multi-cloud deployments of diverse applications.

## Supported Deployments
A variety of deployments models will be supported. Support for each deployment model will be delivered in this order of priority:

1. Local (to your machine)
2. [CNCF Community Cluster] (#cncf-cluster)
3. AWS
4. Azure
5. GCP
6. Packet

Given this breadth of supported deployment models using the same sample applications, performance, cost, etc. characteristics between this variety of clusters may be compared.

## CNCF Community Cluster <a id="cncf-cluster"></a>
Donated by Intel, a 1,000 node cluster of servers is running in Switch, Las Vegas, to be used by the CNCF community. Visit these links for a description of the cluster [project page] (https://cncf.io/cluster) or to be involved in the [cluster community] (https://github.com/cncf/cluster). 

## Getting Started
* [Quick Start] (https://github.com/cncf/demo/blob/master/Kubernetes/Docs/Quickstart.md)
