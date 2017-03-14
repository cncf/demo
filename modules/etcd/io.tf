variable "location" {}
variable "subnet-id" {}
variable "name" {}
variable "availability-id" {}
variable "storage-account" {}
variable "storage-primary-endpoint" {}
variable "storage-container" {}


# variable "ami-id" {}
# variable "bucket-prefix" {}
variable "cluster-domain" {}
variable "hyperkube-image" {}
variable "hyperkube-tag" {}
# variable "depends-id" {}
variable "dns-service-ip" {}
variable "etcd-ips" {}
# variable "etcd-security-group-id" {}
# variable "external-elb-security-group-id" {}
# variable "instance-profile-name" {}
# variable "instance-type" {}
variable "internal-tld" {}
# variable "key-name" {}
# variable "name" {}
variable "pod-ip-range" {}
# variable "region" {}
variable "service-cluster-ip-range" {}
# variable "subnet-ids-private" {}
# variable "subnet-ids-public" {}
# variable "vpc-id" {}

output "external-lb" { value = "${azurerm_lb_backend_address_pool.test.id }" }
output "fqdn-lb" { value = "${azurerm_public_ip.test.fqdn}" }
# output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
# output "external-elb" { value = "${ aws_elb.external.dns_name }" }
# output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.public_ip) }" }

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
