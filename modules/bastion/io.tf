# variable "ami-id" {}
# variable "bucket-prefix" {}
# variable "cidr-allow-ssh" {}
# variable "depends-id" {}
# variable "instance-type" {}
# variable "internal-tld" {}
# variable "key-name" {}
# variable "security-group-id" {}
# variable "subnet-ids" {}
# variable "vpc-id" {}
#
variable "location" {}
variable "subnet-id" {}
variable "name" {}
variable "storage-primary-endpoint" {}
variable "storage-container" {}
variable "availability-id" {}


#output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
#output "ip" { value = "${ aws_instance.bastion.public_ip }" }
output "bastion-ip" { value = "${azurerm_public_ip.test2.ip_address}" }
