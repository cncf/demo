# module "network" {
#   source = "./modules/network"
#   name = "${ var.name }"
#   cidr = "${ var.vpc_cidr }"
#   name_servers_file = "${ module.dns.name_servers_file }"
#   location = "${ var.location }"
#  }

module "dns" {
  source = "./modules/dns"
  name = "${ var.name }"
  master_ips = "${ module.etcd.master_ips }"
  public_master_ips = "${ module.etcd.public_master_ips }"
  public_worker_ips = "${ module.worker.public_worker_ips }"
  master_node_count = "${ var.master_node_count }"
  worker_node_count = "${ var.worker_node_count }"
  domain = "${ var.domain }"
}

module "etcd" {
  source                    = "./modules/etcd"
  name                      = "${ var.name }"
  etcd_discovery            = "${ var.data_dir }/etcd"
  master_node_count         = "${ var.master_node_count }"
  packet_project_id         = "${ var.packet_project_id }"
  packet_facility           = "${ var.packet_facility }"
  packet_billing_cycle      = "${ var.packet_billing_cycle }"
  packet_operating_system   = "${ var.packet_operating_system }"
  packet_master_device_plan = "${ var.packet_master_device_plan }"
  kubelet_image_url         = "${ var.kubelet_image_url }"
  kubelet_image_tag         = "${ var.kubelet_image_tag }"
  dns_service_ip            = "${ var.dns_service_ip }"
  cluster_domain            = "${ var.cluster_domain }"
  internal_tld              = "${ var.name }.${ var.domain }"
  pod_cidr                  = "${ var.pod_cidr }"
  service_cidr              = "${ var.service_cidr }"
  ca                        = "${file("${ var.data_dir }/.cfssl/ca.pem")}"
  k8s_etcd                  = "${file("${ var.data_dir }/.cfssl/k8s-etcd.pem")}"
  k8s_etcd_key              = "${file("${ var.data_dir }/.cfssl/k8s-etcd-key.pem")}"
  k8s_apiserver             = "${file("${ var.data_dir }/.cfssl/k8s-apiserver.pem")}"
  k8s_apiserver_key         = "${file("${ var.data_dir }/.cfssl/k8s-apiserver-key.pem")}"
  data_dir                  = "${ var.data_dir }"
}

# module "bastion" {
#   source = "./modules/bastion"
#   name = "${ var.name }"
#   location = "${ var.location }"
#   bastion_vm_size = "${ var.bastion_vm_size }"
#   image_publisher = "${ var.image_publisher }"
#   image_offer = "${ var.image_offer }"
#   image_sku = "${ var.image_sku }"
#   image_version = "${ var.image_version }"
#   admin_username = "${ var.admin_username }"
#   subnet_id = "${ module.network.subnet_id }"
#   storage_primary_endpoint = "${ azurerm_storage_account.cncf.primary_blob_endpoint }"
#   storage_container = "${ azurerm_storage_container.cncf.name }"
#   availability_id = "${ azurerm_availability_set.cncf.id }"
#   internal_tld = "${ var.internal_tld }"
#   data_dir = "${ var.data_dir }"
# }

module "worker" {
  source                    = "./modules/worker"
  name                      = "${ var.name }"
  worker_node_count         = "${ var.worker_node_count }"
  packet_project_id         = "${ var.packet_project_id }"
  packet_facility           = "${ var.packet_facility }"
  packet_billing_cycle      = "${ var.packet_billing_cycle }"
  packet_operating_system   = "${ var.packet_operating_system }"
  packet_worker_device_plan = "${ var.packet_worker_device_plan }"
  kubelet_image_url         = "${ var.kubelet_image_url }"
  kubelet_image_tag         = "${ var.kubelet_image_tag }"
  dns_service_ip            = "${ var.dns_service_ip }"
  cluster_domain            = "${ var.cluster_domain }"
  internal_tld              = "${ var.name }.${ var.domain }"
  pod_cidr                  = "${ var.pod_cidr }"
  service_cidr              = "${ var.service_cidr }"
  ca                        = "${file("${ var.data_dir }/.cfssl/ca.pem")}"
  k8s_worker                = "${file("${ var.data_dir }/.cfssl/k8s-worker.pem")}"
  k8s_worker_key            = "${file("${ var.data_dir }/.cfssl/k8s-worker-key.pem")}"
  data_dir                  = "${ var.data_dir }"
}

module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin_key_pem = "${ var.data_dir }/.cfssl/k8s-admin-key.pem"
  admin_pem = "${ var.data_dir }/.cfssl/k8s-admin.pem"
  ca_pem = "${ var.data_dir }/.cfssl/ca.pem"
  data_dir = "${ var.data_dir }"
  fqdn_k8s = "endpoint.${ var.name }.${ var.domain }"
  name = "${ var.name }"
}
