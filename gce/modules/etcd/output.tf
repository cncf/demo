output "external-lb" { value = "${google_compute_forwarding_rule.external.ip_address }" }
# output "fqdn-lb" { value = "${azurerm_public_ip.cncf.fqdn}" }


# # output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
# # output "external-elb" { value = "${ aws_elb.external.dns_name }" }
# # output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.public_ip) }" }
# output "master-ips" { value = ["${ google_compute_instance.cncf.*.network_interface.0.address }"] }
