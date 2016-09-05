# Reference Installation of Kubernetes Cluster (Bare Metal)

## Cloud provider images

Simply install and configure Packer and fork this repo to customize. 

> packer build packer.json

## Dependencies

- Ansible 2.1+ installed ([installation instructions] (http://docs.ansible.com/ansible/intro_installation.html))

## Usage

### Preflight checks:

1. Step 1: ssh -i ~/.ssh/your.key user@ip
  - Not found? To generate SSH keys in Mac OS X, run `ssh-keygen -t rsa`.
  - Add your private key to your ssh agent - `ssh-agent bash` and `ssh-add ~/.ssh/id_rsa`. 
  - Your public key is saved to the id_rsa.pub file and is the key you copy to your hosts - `ssh-copy-id user@123.45.56.78`
1. edit `ansible.cfg` with the path to your key and remote user 
2. edit inventory file to reflect target nodes
1. confirm successful communication with all nodes in inventory `ansible all -m ping`

Notes: 
[ansible.cfg](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)
[Inventory Docs](http://docs.ansible.com/ansible/intro_inventory.html)

### Deploy

1. `ansible-playbook playbooks/setup/main.yml -vvvv`
2. Identify the node's role by creating _/etc/sysconfig/kubernetes-masters_ or */etc/sysconfig/kubernetes-minions*
  
  ```
  CLUSTER_NAME=cncfdemo
  CLOUD_PROVIDER=--cloud-provider=aws  // Leave cloud_provider blank for bare metal installations
  KUBELET_HOSTNAME=--hostname-override=ip-172-20-0-12.us-west-2.compute.internal
  ```
3. Restart node
