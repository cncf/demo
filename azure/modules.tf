module "vpc" {
  source = "./modules/vpc"
  name = "${ var.name }"
  cidr = "${ var.vpc_cidr }"
  name-servers-file = "${ module.dns.name-servers-file }"
  location = "${ var.location }"
 }

module "dns" {
  source = "./modules/dns"
  name = "${ var.name }"
  internal_tld = "${ var.internal_tld }"
  master-ips = "${ module.etcd.master-ips }"
}

 module "etcd" {
   source = "./modules/etcd"
   name = "${ var.name }"
   location = "${ var.location }"
   admin_username = "${ var.admin_username }"
   master_node_count = "${ var.master_node_count }"
   master_vm_size = "${ var.master_vm_size }"
   image_publisher = "${ var.image_publisher }"
   image_offer = "${ var.image_offer }"
   image_sku = "${ var.image_sku }"
   image_version = "${ var.image_version }"
   subnet-id = "${ module.vpc.subnet-id }"
   storage-account = "${ azurerm_storage_account.cncf.name }"
   storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
   storage-container = "${ azurerm_storage_container.cncf.name }"
   availability-id = "${ azurerm_availability_set.cncf.id }"
   cluster_domain = "${ var.cluster_domain }"
   kubelet_image_url = "${ var.kubelet_image_url }"
   kubelet_image_tag = "${ var.kubelet_image_tag }"
   dns_service_ip = "${ var.dns_service_ip }"
   internal_tld = "${ var.internal_tld }"
   pod_cidr = "${ var.pod_cidr }"
   service_cidr = "${ var.service_cidr }"
   k8s-apiserver-tar = "${file("${ var.data_dir }/.cfssl/k8s-apiserver.tar")}"
   cloud-config = "${file("${ var.data_dir }/azure-config.json")}"
   # etcd-security-group-id = "${ module.security.etcd-id }"
   # external-elb-security-group-id = "${ module.security.external-elb-id }"
}


module "bastion" {
  source = "./modules/bastion"
  name = "${ var.name }"
  location = "${ var.location }"
  bastion_vm_size = "${ var.bastion_vm_size }"
  image_publisher = "${ var.image_publisher }"
  image_offer = "${ var.image_offer }"
  image_sku = "${ var.image_sku }"
  image_version = "${ var.image_version }"
  admin_username = "${ var.admin_username }"
  subnet-id = "${ module.vpc.subnet-id }"
  storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
  storage-container = "${ azurerm_storage_container.cncf.name }"
  availability-id = "${ azurerm_availability_set.cncf.id }"
  internal_tld = "${ var.internal_tld }"
}

module "worker" {
  source = "./modules/worker"
  name = "${ var.name }"
  location = "${ var.location }"
  admin_username = "${ var.admin_username }"
  worker_node_count = "${ var.worker_node_count }"
  worker_vm_size = "${ var.worker_vm_size }"
  image_publisher = "${ var.image_publisher }"
  image_offer = "${ var.image_offer }"
  image_sku = "${ var.image_sku }"
  image_version = "${ var.image_version }"
  subnet-id = "${ module.vpc.subnet-id }"
  storage-account = "${ azurerm_storage_account.cncf.name }"
  storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
  storage-container = "${ azurerm_storage_container.cncf.name }"
  availability-id = "${ azurerm_availability_set.cncf.id }"
  external-lb = "${ module.etcd.external-lb }"
  cluster_domain = "${ var.cluster_domain }"
  kubelet_image_url = "${ var.kubelet_image_url }"
  kubelet_image_tag = "${ var.kubelet_image_tag }"
  dns_service_ip = "${ var.dns_service_ip }"
  internal_tld = "${ var.internal_tld }"
  k8s-worker-tar = "${file("${ var.data_dir }/.cfssl/k8s-worker.tar")}"
  cloud-config = "${file("${ var.data_dir }/azure-config.json")}"
  # security-group-id = "${ module.security.worker-id }"
}


module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin-key-pem = "${ var.data_dir }/.cfssl/k8s-admin-key.pem"
  admin-pem = "${ var.data_dir }/.cfssl/k8s-admin.pem"
  ca-pem = "${ var.data_dir }/.cfssl/ca.pem"
  fqdn-k8s = "${ module.etcd.fqdn-lb }"
  name = "${ var.name }"
}


/*
module "azuresecurity" {
  source = "./modules/security"

  allow_ssh_cidr = "${ var.cidr["allow-ssh"] }"
  vpc_cidr = "${ var.cidr["vpc"] }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}
*/
