variable "name" {}
variable "region" {}
variable "s3_bucket" { default = "${ var.name}-demobucket"}
variable "kubelet_aci" {}
variable "kubelet_version" {}
variable "depends-id" {}
variable "internal_tld" {}
variable "service-cluster-ip-range" {}
variable "data_dir" {}
