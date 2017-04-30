module "vpc" {
  source = "./modules/vpc"
  name = "${ var.name }"
  cidr = "${ var.cidr }"
  region = "${ var.region }"
}

module "cluster" {
  source = "./modules/cluster"
  name = "${ var.name }"
  region = "${ var.region }"
  zone = "${ var.zone }"
  project = "${ var.project}"
  node_count = "${ var.node_count }"
  network = "${ var.name }"
  subnetwork = "${ var.name }"
  node_version = "${ var.node_version }"
  master_user = "${ var.master_user }"
  master_password = "${ var.master_password }"
  vm_size = "${ var.vm_size }"
  node_pool_count = "${ var.node_pool_count }"
}

module "kubeconfig" {
  source = "./modules/kubeconfig"
  name = "${ var.name }"
  project = "${ var.project }"
  zone = "${ var.zone }"
  endpoint = "${ module.cluster.endpoint }"
  ca = "${ module.cluster.ca }"
  admin = "${ module.cluster.admin }"
  admin_key = "${ module.cluster.admin_key }"
}
