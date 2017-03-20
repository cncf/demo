output "external-lb" { value = "${azurerm_lb_backend_address_pool.test.id }" }
output "fqdn-lb" { value = "${azurerm_public_ip.test.fqdn}" }


# output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
# output "external-elb" { value = "${ aws_elb.external.dns_name }" }
# output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.public_ip) }" }

