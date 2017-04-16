output "external-lb" { value = "${azurerm_lb_backend_address_pool.cncf.id }" }
output "fqdn-lb" { value = "${azurerm_public_ip.cncf.fqdn}" }
output "master-ips" { value = ["${ azurerm_network_interface.cncf.*.private_ip_address }"] }
