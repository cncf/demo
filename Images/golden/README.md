## Centos7 based golden Kubernetes image

This image builds on the [base image](https://github.com/cncf/demo/tree/master/Images/base),
a minimally modified Centos7 configured with sensible defaults for hosting a Kubernetes cluster.

It bakes in everything needed to run Kubernetes master and/or minion nodes into one AMI. It is suggested to configure an instance to bootstrap as a minion or master via userdata.

## Configuration via Userdata


Simply write a file named `kubernetes-master` _or_ `kubernetes-minion` and specify a `cluster_name` environment variable. That's it.
 

```

#!/bin/bash

set -ex

HOSTNAME_OVERRIDE=$(curl -s http://169.254.169.254/2007-01-19/meta-data/local-hostname | cut -d" " -f1)

cat << EOF > /etc/sysconfig/kubernetes-{master,minion}

CLUSTER_NAME={cncfdemo}
KUBELET_HOSTNAME=--hostname-override=$HOSTNAME_OVERRIDE

EOF

```

<sub>Note: The hostname override is an example specific to AWS. Adjust if needed.</sub>
                                  
## Customization Quickstart

Simply install and configure [packer](https://www.packer.io/) and fork this repo to customize.

> packer build packer.json

## Dependencies

- Packer 0.11+
- Ansible 2.1+ installed ([installation instructions] (http://docs.ansible.com/ansible/intro_installation.html))
