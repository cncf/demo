variable "location" {}
variable "subnet-id" {}
variable "name" {}
variable "master_vm_size" {}
variable "master_node_count" {}
variable "image_publisher" {}
variable "image_offer"     {}
variable "image_sku"       {}
variable "image_version"   {}
variable "availability-id" {}
variable "storage-account" {}
variable "storage-primary-endpoint" {}
variable "storage-container" {}
variable "k8s-apiserver-tar" {}
variable "cluster_domain" {}
variable "dns_service_ip" {}
variable "internal_tld" {}
variable "pod_cidr" {}
variable "service_cidr" {}
variable "admin_username" {}
variable "kubelet_image_url" {}
variable "kubelet_image_tag" {}
variable "cloud-config" {}

# variable "etcd-security-group-id" {}
# variable "external-elb-security-group-id" {}
