# Creating a Cluster

This demo has currently pinned Kubernetes to 1.3.

## Try demo on cloud provider

Simply execute the relevant bootstrap python script. (Python and Boto3 are the only dependencies)

> bootstrap_aws.py -vv

Increase the verbosity to see exactly what's being created.

If it is neccessary to use your own Role, SecurityGroup, Key, 'etc, everything is fully customizable via command line flags.


## Try demo on bare metal

- cd into Ansible
- Follow instructions in README.md

### For local Kubernetes clusters please try [minikube](https://github.com/kubernetes/minikube).

This demo repository is meant to run on the major cloud providers, bare metal, and locally. Currently under heavy development.


