# Creating a Cluster

This demo has currently pinned Kubernetes to 1.3.

## Try demo on cloud provider

- git submodule update
- cd into Bootstrap/1.3/kubernetes/cluster
- export KUBERNETES_PROVIDER=aws;
- run kube-up.sh

The [official kubernetes deployment](hhttp://kubernetes.io/docs/getting-started-guides/aws/) scripts are under heavy development and this process will change in the future.

## Try demo on bare metal

- cd into Ansible
- Follow instructions in README.md

### For local Kubernetes clusters please try [minikube](https://github.com/kubernetes/minikube).

This demo repository is meant to run on the major cloud providers, bare metal, and locally. Currently under heavy development.


