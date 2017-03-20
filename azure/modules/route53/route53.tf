resource "azurerm_dns_zone" "test" {
  name = "${ var.internal-tld }"
  resource_group_name = "${ var.name }"
}

#Name Servers 
resource "null_resource" "ns_to_ip_files" {
  # Error running plan: 1 error(s) occurred:
  # * module.route53.null_resource.ns_to_ip_list: null_resource.ns_to_ip_list: value of 'count' cannot be computed
  # FIXME: hardcoding to  4
  count = 2
  depends_on = [ "azurerm_dns_zone.test" ]
  provisioner "local-exec" {
    # filename = "/dev/null"
    command = <<EOF
# grab ip for this nameserver into a file
dig +short ${ element(azurerm_dns_zone.test.name_servers,count.index) } > ${ var.name-servers-file }.${ count.index }.ip
EOF
  }
}

resource "null_resource" "ip_files_to_csv" {
  depends_on = [ "null_resource.ns_to_ip_files" ]
  provisioner "local-exec" {
    # filename = "/dev/null"
    command = <<EOF
# collect them all into a csv 
# wait for them all to appear
sleep 4
cat ${ var.name-servers-file }.*.ip \
| sed -n -e 'H;$${x;s/\n/,/g;s/^,//;p;}' \
| tr -d '\n' \
> ${ var.name-servers-file}
EOF
  }
}

resource "azurerm_dns_a_record" "A-etcd" {
  name = "etcd"
  zone_name = "${azurerm_dns_zone.test.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  records = [ "${ split(",", var.etcd-ips) }" ]
}

resource "azurerm_dns_a_record" "A-etcds" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  name = "etcd${ count.index+1 }"
  zone_name = "${azurerm_dns_zone.test.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  records = [
    "${ element(split(",", var.etcd-ips), count.index) }"
  ]
}

resource "azurerm_dns_cname_record" "CNAME-master" {
  name = "master"
  zone_name = "${azurerm_dns_zone.test.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  record = "etcd.${ var.internal-tld }"
}

resource "azurerm_dns_srv_record" "etcd-client-tcp" {
  name = "_etcd-client._tcp"
  zone_name = "${azurerm_dns_zone.test.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"

  record {
    priority = 0
    weight = 0
    port = 2379
    target = "etcd1.${ var.internal-tld }"
  }

  record {
    priority = 0
    weight = 0
    port = 2379
    target = "etcd2.${ var.internal-tld }"
  }

  record {
    priority = 0
    weight = 0
    port = 2379
    target = "etcd3.${ var.internal-tld }"
  }

}

resource "azurerm_dns_srv_record" "etcd-server-tcp" {
  name = "_etcd-server-ssl._tcp"
  zone_name = "${azurerm_dns_zone.test.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"

  record {
    priority = 0
    weight = 0
    port = 2380
    target = "etcd1.${ var.internal-tld }"
  }

  record {
    priority = 0
    weight = 0
    port = 2380
    target = "etcd2.${ var.internal-tld }"
  }
  
  record {
    priority = 0
    weight = 0
    port = 2380
    target = "etcd3.${ var.internal-tld }"
  }

}
# resource "aws_route53_zone" "internal" {
#   comment = "Kubernetes cluster DNS (internal)"
#   name = "${ var.internal-tld }"
#   tags {
#     builtWith = "terraform"
#     KubernetesCluster = "${ var.name }"
#     Name = "k8s-${ var.name }"
#   }
#   vpc_id = "${ var.vpc-id }"
# }

# resource "aws_route53_record" "A-etcd" {
#   name = "etcd"
#   records = [ "${ split(",", var.etcd-ips) }" ]
#   ttl = "300"
#   type = "A"
#   zone_id = "${ aws_route53_zone.internal.zone_id }"
# }

# resource "aws_route53_record" "A-etcds" {
#   count = "${ length( split(",", var.etcd-ips) ) }"

#   name = "etcd${ count.index+1 }"
#   ttl = "300"
#   type = "A"
#   records = [
#     "${ element(split(",", var.etcd-ips), count.index) }"
#   ]
#   zone_id = "${ aws_route53_zone.internal.zone_id }"
# }

# resource "aws_route53_record" "CNAME-master" {
#   name = "master"
#   records = [ "etcd.${ var.internal-tld }" ]
#   ttl = "300"
#   type = "CNAME"
#   zone_id = "${ aws_route53_zone.internal.zone_id }"
# }

# resource "aws_route53_record" "etcd-client-tcp" {
#   name = "_etcd-client._tcp"
#   ttl = "300"
#   type = "SRV"
#   records = [ "${ formatlist("0 0 2379 %v", aws_route53_record.A-etcds.*.fqdn) }" ]
#   zone_id = "${ aws_route53_zone.internal.zone_id }"
# }

# resource "aws_route53_record" "etcd-server-tcp" {
#   name = "_etcd-server-ssl._tcp"
#   ttl = "300"
#   type = "SRV"
#   records = [ "${ formatlist("0 0 2380 %v", aws_route53_record.A-etcds.*.fqdn) }" ]
#   zone_id = "${ aws_route53_zone.internal.zone_id }"
# }

# resource "null_resource" "dummy_dependency" {
#   depends_on = [
#     "aws_route53_record.etcd-server-tcp",
#     "aws_route53_record.A-etcd",
#   ]
# }
