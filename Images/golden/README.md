## Centos7 based golden Kubernetes image

This image builds on the [base image](https://github.com/cncf/demo/tree/master/Images/base),
a minimally modified Centos7 configured with sensible defaults for hosting a Kubernetes cluster.

It bakes in everything needed to run Kubernetes master and/or minion nodes into one AMI.
An instance is configured to bootstrap as a minion or master via userdata.

## Quickstart

Simply install and configure [packer](https://www.packer.io/) and fork this repo to customize.

> packer build packer.json

## Dependencies

- Packer 0.11+
- Ansible 2.1+ installed ([installation instructions] (http://docs.ansible.com/ansible/intro_installation.html))
