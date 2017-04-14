variable "ami-id" {}
variable "capacity" {
  default = {
    desired = 5
    max = 5
    min = 3
  }
}
variable "cluster_domain" {}
variable "kubelet_aci" {}
variable "kubelet_version" {}
variable "depends-id" {}
variable "dns_service_ip" {}
variable "instance-type" {}
variable "internal_tld" {}
variable "key-name" {}
variable "name" {}
variable "region" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "volume_size" {
  default = {
    ebs = 250
    root = 52
  }
}
variable "vpc-id" {}
variable "worker-name" {}
variable "instance-profile-name" {}
variable "s3_bucket" {}
