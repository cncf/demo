module "vpc" {
  source = "./modules/vpc"
  name = "${ var.name }"
  cidr = "${ var.cidr }"
  # name-servers-file = "${ module.dns.name-servers-file }"
  region = "${ var.region }"
 }

# module "dns" {
#   source = "./modules/dns"
#   name = "${ var.name }"
#   internal-tld = "${ var.internal-tld }"
#   master-ips = "${ module.etcd.master-ips }"
# }

#  module "etcd" {
#    source = "./modules/etcd"
#    name = "${ var.name }"
#    location = "${ var.location }"
#    admin-username = "${ var.admin-username }"
#    master-node-count = "${ var.master-node-count }"
#    master-vm-size = "${ var.master-vm-size }"
#    image-publisher = "${ var.image-publisher }"
#    image-offer = "${ var.image-offer }"
#    image-sku = "${ var.image-sku }"
#    image-version = "${ var.image-version }"
#    subnet-id = "${ module.vpc.subnet-id }"
#    storage-account = "${ azurerm_storage_account.cncf.name }"
#    storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
#    storage-container = "${ azurerm_storage_container.cncf.name }"
#    availability-id = "${ azurerm_availability_set.cncf.id }"
#    cluster-domain = "${ var.cluster-domain }"
#    kubelet-image-url = "${ var.kubelet-image-url }"
#    kubelet-image-tag = "${ var.kubelet-image-tag }"
#    dns-service-ip = "${ var.dns-service-ip }"
#    internal-tld = "${ var.internal-tld }"
#    pod-cidr = "${ var.pod-cidr }"
#    service-cidr = "${ var.service-cidr }"
#    k8s-apiserver-tar = "${file("${ var.data-dir }/.cfssl/k8s-apiserver.tar")}"
#    cloud-config = "${file("${ var.data-dir }/azure-config.json")}"
#    # etcd-security-group-id = "${ module.security.etcd-id }"
#    # external-elb-security-group-id = "${ module.security.external-elb-id }"
# }


# module "bastion" {
#   source = "./modules/bastion"
#   name = "${ var.name }"
#   location = "${ var.location }"
#   bastion-vm-size = "${ var.bastion-vm-size }"
#   image-publisher = "${ var.image-publisher }"
#   image-offer = "${ var.image-offer }"
#   image-sku = "${ var.image-sku }"
#   image-version = "${ var.image-version }"
#   admin-username = "${ var.admin-username }"
#   subnet-id = "${ module.vpc.subnet-id }"
#   storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
#   storage-container = "${ azurerm_storage_container.cncf.name }"
#   availability-id = "${ azurerm_availability_set.cncf.id }"
#   internal-tld = "${ var.internal-tld }"
# }

# module "worker" {
#   source = "./modules/worker"
#   name = "${ var.name }"
#   location = "${ var.location }"
#   admin-username = "${ var.admin-username }"
#   worker-node-count = "${ var.worker-node-count }"
#   worker-vm-size = "${ var.worker-vm-size }"
#   image-publisher = "${ var.image-publisher }"
#   image-offer = "${ var.image-offer }"
#   image-sku = "${ var.image-sku }"
#   image-version = "${ var.image-version }"
#   subnet-id = "${ module.vpc.subnet-id }"
#   storage-account = "${ azurerm_storage_account.cncf.name }"
#   storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
#   storage-container = "${ azurerm_storage_container.cncf.name }"
#   availability-id = "${ azurerm_availability_set.cncf.id }"
#   external-lb = "${ module.etcd.external-lb }"
#   cluster-domain = "${ var.cluster-domain }"
#   kubelet-image-url = "${ var.kubelet-image-url }"
#   kubelet-image-tag = "${ var.kubelet-image-tag }"
#   dns-service-ip = "${ var.dns-service-ip }"
#   internal-tld = "${ var.internal-tld }"
#   k8s-worker-tar = "${file("${ var.data-dir }/.cfssl/k8s-worker.tar")}"
#   cloud-config = "${file("${ var.data-dir }/azure-config.json")}"
#   # security-group-id = "${ module.security.worker-id }"
# }


# module "kubeconfig" {
#   source = "./modules/kubeconfig"

#   admin-key-pem = "${ var.data-dir }/.cfssl/k8s-admin-key.pem"
#   admin-pem = "${ var.data-dir }/.cfssl/k8s-admin.pem"
#   ca-pem = "${ var.data-dir }/.cfssl/ca.pem"
#   fqdn-k8s = "${ module.etcd.fqdn-lb }"
#   name = "${ var.name }"
# }


# /*
# module "azuresecurity" {
#   source = "./modules/security"

#   cidr-allow-ssh = "${ var.cidr["allow-ssh"] }"
#   cidr-vpc = "${ var.cidr["vpc"] }"
#   name = "${ var.name }"
#   vpc-id = "${ module.vpc.id }"
# }
# */
