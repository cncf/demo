# variable "depends-id" {}
variable "etcd-ips" {}
variable "internal-tld" {}
variable "name" {}
variable "location" {}
variable "name-servers-file" { default = "azure_dns_zone"}
# variable "vpc-id" {}

# output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
output "internal-name-servers" { value = "${ azurerm_dns_zone.test.name_servers }" }
output "internal-zone-id" { value = "${ azurerm_dns_zone.test.zone_id }" }
output "name-servers-file" { value = "${ var.name-servers-file }" }
