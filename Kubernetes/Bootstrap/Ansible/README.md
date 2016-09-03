# Reference Installation of Kubernetes Cluster (Bare Metal)

## Cloud provider images

Simply install and configure Packer and fork this repo to customize. 

> packer build packer.json

## Requirements

You must have Ansible 2.1+ installed ([installation instructions] (http://docs.ansible.com/ansible/intro_installation.html)).

## Usage

### Preflight checks:

- Step 1: ssh -i ~/.ssh/your.key user@ip
  - Not found? To generate SSH keys in Mac OS X, run `ssh-keygen -t rsa`.
  - Add your private key to your ssh agent - `ssh-agent bash` and `ssh-add ~/.ssh/id_rsa`. 
  - Your public key is saved to the id_rsa.pub file and is the key you copy to your hosts - `ssh-copy-id user@123.45.56.78`
- Step 2: edit ansible.cfg with the path to your key and remote user 
- Step 3: ansible all -m ping

Notes: 
[ansible.cfg](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)
[Inventory Docs](http://docs.ansible.com/ansible/intro_inventory.html)

### Deploy

ansible-playbook playbooks/setup/main.yml -v
