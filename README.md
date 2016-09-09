# Quickstart Guide
Getting started with the `cncfdemo` is a three-step process:

1. [Install dependencies] (#dependencies)
2. [Create a Kubernetes cluster, running Prometheus] (#cluster)
3. [Run demo apps] (#demo)

## 1. Install Dependencies <a id="dependencies"></a>

1. Run `brew install kubernetes-cli` 

  If your package manager does not have `kubectl`, simply [download a binary release](https://github.com/kubernetes/kubernetes/releases) and add `kubectl` to your path. See [Installing and Setting up kubectl] (http://kubernetes.io/docs/user-guide/prereqs/) for platform-specific installation instructions.

2. Run `pip install cncfdemo`

   pip is the python package manager. It is strongly recommended to also use a dedicated python virtualenv. For detailed install instructions for your platform read: [The Hitchhiker's Guide to Python](http://docs.python-guide.org/en/latest/starting/install/osx/#setuptools-pip). 
  
## 2. Create Cluster <a id="cluster"></a>

1. `cncfdemo bootstrap aws`

  AWS is used as an example. Substitute with your provider of choice. 
  
  <sub>**Note**: Grab a beverage, this step takes several minutes.</sub>
  

## 3. Run Demo <a id="demo"></a>

1. Run `cncfdemo start`
2. Browse to [countly.cncfdemo.io](countly.cncfdemo.io)
3. Run `cncfdemo benchmark --time 5m --save-html`
 


# CNCF Technologies Demonstration
The goal of this project is to demonstrate each of the technologies that have been adopted by the [Cloud Native Computing Foundation] (http://cncf.io) (CNCF) in a publicly available repository in order to facilitate their understanding through simple deployment tooling and by providing sample applications as common-ground for conversation. This project will enable replicable deployments and facilitate quantification of performance, latency, throughput, and cost between various deployment models.

## Projects
1. Kubernetes - [Project] (http://kubernetes.io), [Source] (https://github.com/kubernetes/kubernetes)
2. Prometheus - [Project] (https://prometheus.io), [Source] (https://github.com/prometheus)

## Summary of Sample Applications
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

## Supported Deployments
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

## Getting Started
* [Quick Start] (https://github.com/cncf/demo/blob/master/Kubernetes/Docs/Quickstart.md)

## An Open Commitment
The project output will be an open source Github repo that will become widely referenced within the CNCF community. All work will occur on a public repo, all externally referenced projects will be open source, and this project itself will be licensed under Apache 2.0. 

## Disclaimer
Note that these are explicitly marketing demos, not reference stacks. The CNCF’s [Technical Oversight Committee] (https://github.com/cncf/toc) will over time be adopting additional projects and may eventually publish reference stacks. By contrast, this project is designed to take the shortest possible path to successful multi-cloud deployments of diverse applications.

# Details of Sample Applications 
## Countly <a id="countly"></a>
Countly is an open source web & mobile analytics and marketing platform. It provides insights about user actions.

## Configuration Files
Two configuration files used to dictate the behavior of this demo application are [api.js] (configMaps/countly/api.js) and [frontend.js] (configMaps/countly/frontend.js). Each configuration file contains only one change from the default configurationonly line changed from the default config:

  `Host: "mongos:default"`

By setting `Host` to "mongos.default", the Countly application looks for its MongoDB servers at the address "mongos.default". The "mongos.default" reference resolves to a Kubernetes service called mongos. The .default namespace is the default top-level domain for pods and services deployed in Kubernetes.

