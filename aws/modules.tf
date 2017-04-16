module "vpc" {
  source = "./modules/vpc"
  depends-id = ""

  azs = "${ var.aws_azs }"
  cidr = "${ var.vpc_cidr }"
  kubelet_version = "${ var.kubelet_version }"
  name = "${ var.name }"
  region = "${ var.aws_region }"
}

module "security" {
  source = "./modules/security"

  allow_ssh_cidr = "${ var.allow_ssh_cidr }"
  vpc_cidr = "${ var.vpc_cidr }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}


module "iam" {
  source = "./modules/iam"
  # depends-id = "${ module.s3.depends-id }"
  # s3_bucket = "${ module.s3.bucket }"
  name = "${ var.name }"
}


module "route53" {
  source = "./modules/route53"

  etcd_ips = "${ var.etcd_ips }"
  internal_tld = "${ var.internal_tld }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}

module "etcd" {
  source = "./modules/etcd"
  depends-id = "${ module.route53.depends-id }"
  instance-profile-name = "${ module.iam.instance-profile-name-master }"

  ami-id = "${ var.aws_image_ami }"
  cluster_domain = "${ var.cluster_domain }"
  kubelet_aci = "${ var.kubelet_aci }"
  kubelet_version = "${ var.kubelet_version }"
  dns_service_ip = "${ var.dns_service_ip }"
  etcd_ips = "${ var.etcd_ips }"
  etcd-security-group-id = "${ module.security.etcd-id }"
  external-elb-security-group-id = "${ module.security.external-elb-id }"
  instance-type = "${ var.aws_master_vm_size }"
  internal_tld = "${ var.internal_tld }"
  key-name = "${ var.aws_key_name }"
  name = "${ var.name }"
  pod-ip-range = "${ var.pod_cidr }"
  region = "${ var.aws_region }"
  service-cluster-ip-range = "${ var.service_cidr }"
  subnet-ids-private = "${ module.vpc.subnet-ids-private }"
  subnet-ids-public = "${ module.vpc.subnet-ids-public }"
  vpc-id = "${ module.vpc.id }"
  ca = "${file("${ var.data_dir }/.cfssl/ca.pem")}"
  k8s-etcd = "${file("${ var.data_dir }/.cfssl/k8s-etcd.pem")}"
  k8s-etcd-key = "${file("${ var.data_dir }/.cfssl/k8s-etcd-key.pem")}"
  k8s-apiserver = "${file("${ var.data_dir }/.cfssl/k8s-apiserver.pem")}"
  k8s-apiserver-key = "${file("${ var.data_dir }/.cfssl/k8s-apiserver-key.pem")}"
}

module "bastion" {
  source = "./modules/bastion"
  depends-id = "${ module.etcd.depends-id }"

  ami-id = "${ var.aws_image_ami }"
  instance-type = "${ var.aws_bastion_vm_size }"
  internal_tld = "${ var.internal_tld }"
  key-name = "${ var.aws_key_name }"
  name = "${ var.name }"
  security-group-id = "${ module.security.bastion-id }"
  subnet-ids = "${ module.vpc.subnet-ids-public }"
  vpc-id = "${ module.vpc.id }"
}

module "worker" {
  source = "./modules/worker"
  depends-id = "${ module.route53.depends-id }"
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"

  ami-id = "${ var.aws_image_ami }"
  capacity = {
    desired = 3
    max = 5
    min = 3
  }
  cluster_domain = "${ var.cluster_domain }"
  kubelet_aci = "${ var.kubelet_aci }"
  kubelet_version = "${ var.kubelet_version }"
  dns_service_ip = "${ var.dns_service_ip }"
  instance-type = "${ var.aws_worker_vm_size }"
  internal_tld = "${ var.internal_tld }"
  key-name = "${ var.aws_key_name }"
  name = "${ var.name }"
  region = "${ var.aws_region }"
  security-group-id = "${ module.security.worker-id }"
  subnet-ids = "${ module.vpc.subnet-ids-private }"
  ca = "${file("${ var.data_dir }/.cfssl/ca.pem")}"
  k8s-worker = "${file("${ var.data_dir }/.cfssl/k8s-worker.pem")}"
  k8s-worker-key = "${file("${ var.data_dir }/.cfssl/k8s-worker-key.pem")}"

  volume_size = {
    ebs = 250
    root = 52
  }
  vpc-id = "${ module.vpc.id }"
  worker-name = "general"
}

module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin-key-pem = "${ var.data_dir }/k8s-admin-key.pem"
  admin-pem = "${ var.data_dir }/k8s-admin.pem"
  ca-pem = "${ var.data_dir }/ca.pem"
  master-elb = "${ module.etcd.external-elb }"
  name = "${ var.name }"
}
