#output "fqdn_lb" { value = "${azurerm_public_ip.cncf.fqdn}" }
output "first_worker_ip" { value = "${ packet_device.workers.0.network.0.address }" }
output "second_worker_ip" { value = "${ packet_device.workers.1.network.0.address }" }
output "third_worker_ip" { value = "${ packet_device.workers.2.network.0.address }" }
output "worker_ips" { value = ["${ packet_device.workers.*.network.0.address }"] }
