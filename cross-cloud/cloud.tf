module "aws" {
  source       = "../aws"
  name         = "${ var.name }-aws"
  internal_tld = "${ var.name }-aws.cncf.demo"
  data_dir     = "${ var.data_dir }/aws"
}

module "azure" {
  source                    = "../azure"
  name                      = "${ var.name }azure"
  internal_tld = "${ var.name }-azure.cncf.demo"
  data_dir                  = "${ var.data_dir }/azure"
}

module "packet" {
  source                    = "../packet"
  name                      = "${ var.name }-packet"
  data_dir                  = "${ var.data_dir }/packet"
  packet_project_id         = "${ var.packet_project_id }"
}

module "aws-kubeconfig" {
  source = "../kubeconfig"
  admin_key_pem = "${ var.data_dir }/aws/.cfssl/k8s-admin-key.pem"
  admin_pem = "${ var.data_dir }/aws/.cfssl/k8s-admin.pem"
  ca_pem = "${ var.data_dir }/aws/.cfssl/ca.pem"
  data_dir = "${ var.data_dir }"
  fqdn_k8s = "${ module.aws.external_elb }"
  name = "${ var.name }"
}

module "azure-kubeconfig" {
  source = "../kubeconfig"
  admin_key_pem = "${ var.data_dir }/azure/.cfssl/k8s-admin-key.pem"
  admin_pem = "${ var.data_dir }/azure/.cfssl/k8s-admin.pem"
  ca_pem = "${ var.data_dir }/azure/.cfssl/ca.pem"
  data_dir = "${ var.data_dir }"
  fqdn_k8s = "${ module.azure.fqdn_k8s }"
  name = "${ var.name }"
}

module "packet-kubeconfig" {
  source = "../kubeconfig"
  admin_key_pem = "${ var.data_dir }/packet/.cfssl/k8s-admin-key.pem"
  admin_pem = "${ var.data_dir }/packet/.cfssl/k8s-admin.pem"
  ca_pem = "${ var.data_dir }/packet/.cfssl/ca.pem"
  data_dir = "${ var.data_dir }"
  fqdn_k8s = "${ module.azure.fqdn_k8s }"
  name = "${ var.name }"
}
