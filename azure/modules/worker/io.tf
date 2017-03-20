variable "location" {}
variable "subnet-id" {}
variable "name" {}
variable "storage-account" {}
variable "storage-primary-endpoint" {}
variable "storage-container" {}
variable "availability-id" {}
variable "external-lb" {}

# variable "ami-id" {}
# variable "bucket-prefix" {}
# variable "capacity" {
#   default = {
#     desired = 5
#     max = 5
#     min = 3
#   }
# }
variable "cluster-domain" {}
variable "hyperkube-image" {}
variable "hyperkube-tag" {}
# variable "depends-id" {}
variable "dns-service-ip" {}
# variable "instance-profile-name" {}
# variable "instance-type" {}
variable "internal-tld" {}
# variable "key-name" {}
# variable "name" {}
# variable "region" {}
# variable "security-group-id" {}
# variable "subnet-ids" {}
# variable "volume_size" {
#   default = {
#     ebs = 250
#     root = 52
#   }
# }
# variable "vpc-id" {}
# variable "worker-name" {}

# output "autoscaling-group-name" { value = "${ aws_autoscaling_group.worker.name }" }
# output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }

variable "ca" {}
variable "ca-key" {}
variable "k8s-admin" {}
variable "k8s-admin-key" {}
variable "k8s-apiserver" {}
variable "k8s-apiserver-key" {}
variable "k8s-etcd" {}
variable "k8s-etcd-key" {}
variable "k8s-worker" {}
variable "k8s-worker-key"  {}
