variable "location" {}
variable "subnet-id" {}
variable "name" {}
variable "master-vm-size" {}
variable "master-node-count" {}
variable "image-publisher" {}
variable "image-offer"     {}
variable "image-sku"       {}
variable "image-version"   {}
variable "availability-id" {}
variable "storage-account" {}
variable "storage-primary-endpoint" {}
variable "storage-container" {}
variable "k8s-apiserver-tar" {}
variable "cluster-domain" {}
variable "dns-service-ip" {}
variable "internal-tld" {}
variable "pod-cidr" {}
variable "service-cidr" {}
variable "admin-username" {}
variable "kubelet-image-url" {}
variable "kubelet-image-tag" {}
variable "cloud-config" {}

# variable "etcd-security-group-id" {}
# variable "external-elb-security-group-id" {}
