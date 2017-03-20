# output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
output "internal-name-servers" { value = "${ azurerm_dns_zone.test.name_servers }" }
output "internal-zone-id" { value = "${ azurerm_dns_zone.test.zone_id }" }
output "name-servers-file" { value = "${ var.name-servers-file }" }
