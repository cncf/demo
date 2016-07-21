# Reference Installation of Kubernetes Cluster (Bare Metal)

## Cloud provider images

Simply install and configure Packer and fork this repo to customize. 

> packer build packer.json

## Requirements

You must have ansible 2.1+ installed.

## Usage

### Preflight checks:

- Step 1: ssh -i ~/.ssh/your.key user@ip
- Step 2: edit ansible.cfg with the path to your key and remote user 
- Step 3: ansible all -m ping

Notes: 
[ansible.cfg](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)
[Inventory Docs](http://docs.ansible.com/ansible/intro_inventory.html)

### Deploy

ansible-playbook playbooks/setup/main.yml 
