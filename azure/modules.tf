# module "s3" {
#   source = "./modules/s3"
#   # depends-id = "${ module.vpc.depends-id }"

#   # bucket-prefix = "${ var.s3-bucket }"
#   # hyperkube-image = "${ var.k8s["hyperkube-image"] }"
#   # hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
#   # internal-tld = "${ var.internal-tld }"
#   name = "${ var.name }"
#   region = "${ var.aws["region"] }"
#   service-cluster-ip-range = "${ var.cidr["service-cluster"] }"
# }


module "vpc" {
  source = "./modules/vpc"

  #depends-id = ""
  #azs = "${ var.aws["azs"] }"
  #hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
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
/*
module "iam" {
  source = "./modules/iam"
  depends-id = "${ module.s3.depends-id }"

  bucket-prefix = "${ var.s3-bucket }"
  name = "${ var.name }"
}
*/

# moved to vpc - vm creation
# subnet-ids-private = "${ module.vpc.subnet-ids-private }"
# subnet-ids-public = "${ module.vpc.subnet-ids-public }"
# vpc-id = "${ module.vpc.id }"

module "route53" {
  # depends-id = "${ module.iam.depends-id }"
  source = "./modules/route53"
  name = "${ var.azure["resource-group"] }"
  etcd-ips = "${ var.etcd-ips }"
  internal-tld = "${ var.internal-tld }"
  location = "${ var.azure["location"] }"
}

 module "etcd" {
   # etcd-security-group-id = "${ module.security.etcd-id }"
   # external-elb-security-group-id = "${ module.security.external-elb-id }"
   # instance-profile-name = "${ module.iam.instance-profile-name-master }"
   # instance-type = "${ var.instance-type["etcd"] }"
   #depends-id = "${ module.route53.depends-id }"
   source = "./modules/etcd"
   # aws uses region = "${ var.aws["region"] }"
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
  # depends-id = "${ module.route53.depends-id }"

  # ami-id = "${ var.coreos-aws["ami"] }"
  # bucket-prefix = "${ var.s3-bucket }"
  # capacity = {
  #   desired = 3
  #   max = 5
  #   min = 3
  # }
  cluster-domain = "${ var.cluster-domain }"
  hyperkube-image = "${ var.k8s["hyperkube-image"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  dns-service-ip = "${ var.dns-service-ip }"
  # instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  # instance-type = "${ var.instance-type["worker"] }"
  internal-tld = "${ var.internal-tld }"
  ca = "${file("/cncf/data/.cfssl/ca.pem")}"
  ca-key = "${file("/cncf/data/.cfssl/ca-key.pem")}"
  k8s-admin = "${file("/cncf/data/.cfssl/k8s-admin.pem")}"
  k8s-admin-key = "${file("/cncf/data/.cfssl/k8s-admin-key.pem")}"
  k8s-apiserver = "${file("/cncf/data/.cfssl/k8s-apiserver.pem")}"
  k8s-apiserver-key = "${file("/cncf/data/.cfssl/k8s-apiserver-key.pem")}"
  k8s-etcd = "${file("/cncf/data/.cfssl/k8s-etcd.pem")}"
  k8s-etcd-key ="${file("/cncf/data/.cfssl/k8s-etcd-key.pem")}"
  k8s-worker ="${file("/cncf/data/.cfssl/k8s-worker.pem")}"
  k8s-worker-key ="${file("/cncf/data/.cfssl/k8s-worker-key.pem")}"

  # key-name = "${ var.aws["key-name"] }"
  # name = "${ var.name }"
  # region = "${ var.aws["region"] }"
  # security-group-id = "${ module.security.worker-id }"
  # subnet-ids = "${ module.vpc.subnet-ids-private }"
  # volume_size = {
  #   ebs = 250
  #   root = 52
  # }
  # vpc-id = "${ module.vpc.id }"
  # worker-name = "general"
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
