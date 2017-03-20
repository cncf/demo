module "vpc" {
  source = "./modules/vpc"
  cidr = "${ var.cidr["vpc"] }"
  name = "${ var.azure["resource-group"] }"
  name-servers-file = "${ module.route53.name-servers-file }"
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

module "route53" {
  source = "./modules/route53"
  name = "${ var.azure["resource-group"] }"
  etcd-ips = "${ var.etcd-ips }"
  internal-tld = "${ var.internal-tld }"
  location = "${ var.azure["location"] }"
}

 module "etcd" {
   source = "./modules/etcd"
   location = "${ var.azure["location"] }"
   subnet-id = "${ module.vpc.subnet-id }"
   name = "${ var.azure["resource-group"] }"
   storage-account = "${ azurerm_storage_account.test.name }"
   storage-primary-endpoint = "${ azurerm_storage_account.test.primary_blob_endpoint }"
   storage-container = "${ azurerm_storage_container.test.name }"
   availability-id = "${ azurerm_availability_set.test.id }"
   cluster-domain = "${ var.cluster-domain }"
   hyperkube-image = "${ var.k8s["hyperkube-image"] }"
   hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
   dns-service-ip = "${ var.dns-service-ip }"
   etcd-ips = "${ var.etcd-ips }"
   internal-tld = "${ var.internal-tld }"
   pod-ip-range = "${ var.cidr["pods"] }"
   service-cluster-ip-range = "${ var.cidr["service-cluster"] }"
   etcd-url = "${ var.etcd-url }"
   k8s-apiserver-tar = "${file("/cncf/data/.cfssl/k8s-apiserver.tar")}"
   # etcd-security-group-id = "${ module.security.etcd-id }"
   # external-elb-security-group-id = "${ module.security.external-elb-id }"
}


module "bastion" {
  source = "./modules/bastion"
  location = "${ var.azure["location"] }"
  subnet-id = "${ module.vpc.subnet-id }"
  name = "${ var.azure["resource-group"] }"
  storage-primary-endpoint = "${ azurerm_storage_account.test.primary_blob_endpoint }"
  storage-container = "${ azurerm_storage_container.test.name }"
  availability-id = "${ azurerm_availability_set.test.id }"
  internal-tld = "${ var.internal-tld }"
}

module "worker" {
  source = "./modules/worker"
  location = "${ var.azure["location"] }"
  subnet-id = "${ module.vpc.subnet-id }"
  name = "${ var.azure["resource-group"] }"
  storage-account = "${ azurerm_storage_account.test.name }"
  storage-primary-endpoint = "${ azurerm_storage_account.test.primary_blob_endpoint }"
  storage-container = "${ azurerm_storage_container.test.name }"
  availability-id = "${ azurerm_availability_set.test.id }"
  external-lb = "${ module.etcd.external-lb }"
  cluster-domain = "${ var.cluster-domain }"
  hyperkube-image = "${ var.k8s["hyperkube-image"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  dns-service-ip = "${ var.dns-service-ip }"
  internal-tld = "${ var.internal-tld }"
  k8s-worker-tar = "${file("/cncf/data/.cfssl/k8s-worker.tar")}"
  # security-group-id = "${ module.security.worker-id }"
}

/*
module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin-key-pem = "${ var.dir-ssl }/k8s-admin-key.pem"
  admin-pem = "${ var.dir-ssl }/k8s-admin.pem"
  ca-pem = "${ var.dir-ssl }/ca.pem"
  master-elb = "${ module.etcd.external-elb }"
  name = "${ var.name }"
}
*/
