module "vpc" {
  source = "./modules/vpc"
  name = "${ var.name }"
  cidr = "${ var.cidr["vpc"] }"
  name-servers-file = "${ module.dns.name-servers-file }"
  location = "${ var.azure["location"] }"
 }

module "dns" {
  source = "./modules/dns"
  name = "${ var.name }"
  etcd-ips = "${ var.etcd-ips }"
  internal-tld = "${ var.internal-tld }"
}

 module "etcd" {
   source = "./modules/etcd"
   name = "${ var.name }"
   location = "${ var.azure["location"] }"
   admin-username = "${ var.admin-username }"
   subnet-id = "${ module.vpc.subnet-id }"
   storage-account = "${ azurerm_storage_account.cncf.name }"
   storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
   storage-container = "${ azurerm_storage_container.cncf.name }"
   availability-id = "${ azurerm_availability_set.cncf.id }"
   cluster-domain = "${ var.cluster-domain }"
   kubelet-image-url = "${ var.k8s["kubelet-image-url"] }"
   kubelet-image-tag = "${ var.k8s["kubelet-image-tag"] }"
   dns-service-ip = "${ var.dns-service-ip }"
   etcd-ips = "${ var.etcd-ips }"
   internal-tld = "${ var.internal-tld }"
   pod-ip-range = "${ var.cidr["pods"] }"
   service-cluster-ip-range = "${ var.cidr["service-cluster"] }"
   k8s-apiserver-tar = "${file("/cncf/data/.cfssl/k8s-apiserver.tar")}"
   cloud-config = "${file("/cncf/data/azure-config.json")}"
   # etcd-security-group-id = "${ module.security.etcd-id }"
   # external-elb-security-group-id = "${ module.security.external-elb-id }"
}


module "bastion" {
  source = "./modules/bastion"
  name = "${ var.name }"
  location = "${ var.azure["location"] }"
  admin-username = "${ var.admin-username }"
  subnet-id = "${ module.vpc.subnet-id }"
  storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
  storage-container = "${ azurerm_storage_container.cncf.name }"
  availability-id = "${ azurerm_availability_set.cncf.id }"
  internal-tld = "${ var.internal-tld }"
}

module "worker" {
  source = "./modules/worker"
  name = "${ var.name }"
  location = "${ var.azure["location"] }"
  admin-username = "${ var.admin-username }"
  subnet-id = "${ module.vpc.subnet-id }"
  storage-account = "${ azurerm_storage_account.cncf.name }"
  storage-primary-endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
  storage-container = "${ azurerm_storage_container.cncf.name }"
  availability-id = "${ azurerm_availability_set.cncf.id }"
  external-lb = "${ module.etcd.external-lb }"
  cluster-domain = "${ var.cluster-domain }"
  kubelet-image-url = "${ var.k8s["kubelet-image-url"] }"
  kubelet-image-tag = "${ var.k8s["kubelet-image-tag"] }"
  dns-service-ip = "${ var.dns-service-ip }"
  internal-tld = "${ var.internal-tld }"
  k8s-worker-tar = "${file("/cncf/data/.cfssl/k8s-worker.tar")}"
  cloud-config = "${file("/cncf/data/azure-config.json")}"
  worker-nodes = "${ var.worker-nodes }"
  # security-group-id = "${ module.security.worker-id }"
}


module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin-key-pem = "${ var.dir-ssl }/k8s-admin-key.pem"
  admin-pem = "${ var.dir-ssl }/k8s-admin.pem"
  ca-pem = "${ var.dir-ssl }/ca.pem"
  fqdn-k8s = "${ module.etcd.fqdn-lb }"
  name = "${ var.name }"
}


/*
module "azuresecurity" {
  source = "./modules/security"

  cidr-allow-ssh = "${ var.cidr["allow-ssh"] }"
  cidr-vpc = "${ var.cidr["vpc"] }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}
*/
