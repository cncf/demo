variable "name" { default = "packet" }
# required for now
variable "packet_project_id" { }

variable "internal_tld" { default = "packet.cncf.demo" }
variable "data_dir" { default = "/cncf/data/packet" }

# Azure Cloud Specific Settings
# New York Metro (EWR1)
# Silicon Valley (SJC1)
# Amsterdam, NL (AMS1)
# Tokyo, JP (NRT1)
variable "packet_facility"        { default = "nrt1" }

# VM Image and size
variable "admin_username" { default = "cncf"}
# https://www.terraform.io/docs/providers/packet/r/device.html#operating_system-1
variable "packet_operating_system"   { default = "1298.6.0" }
variable "master_vm_size"   { default = "Standard_A2" }
variable "worker_vm_size"   { default = "Standard_A2" }
variable "bastion_vm_size"   { default = "Standard_A2" }

# Kubernetes
variable "cluster_domain" { default = "cluster.local" }
variable "pod_cidr" { default = "10.2.0.0/16" }
variable "service_cidr"   { default = "10.3.0.0/24" }
variable "k8s_service_ip" { default = "10.3.0.1" }
variable "dns_service_ip" { default = "10.3.0.10" }
variable "master_node_count" { default = "3" }
variable "worker_node_count" { default = "3" }
# Autoscaling not supported by Kuberenetes on Azure yet
# variable "worker_node_min" { default = "3" }
# variable "worker_node_max" { default = "5" }

# Deployment Artifact Versions
# Hyperkube
# Set from https://quay.io/repository/coreos/hyperkube?tab=tags
variable "kubelet_image_url" { default = "quay.io/coreos/hyperkube"}
variable "kubelet_image_tag" { default = "v1.4.7_coreos.0"}
