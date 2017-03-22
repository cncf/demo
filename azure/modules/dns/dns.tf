resource "azurerm_dns_zone" "cncf" {
  name = "${ var.internal-tld }"
  resource_group_name = "${ var.name }"
}

#Name Servers
resource "null_resource" "dns_dig" {
  # Error running plan: 1 error(s) occurred:
  # * module.dns.null_resource.ns_to_ip_list: null_resource.ns_to_ip_list: value of 'count' cannot be computed
  # FIXME: hardcoding to 2
  # we only need 2 dns servers
  count = 2
  depends_on = [ "azurerm_dns_zone.cncf" ]
  provisioner "local-exec" {
    # filename = "/dev/null"
    command = <<EOF
# grab ip for this nameserver into a file
dig +short ${ element(azurerm_dns_zone.cncf.name_servers,count.index) } > ${ var.name-servers-file }.${ count.index }.ip
EOF
  }
}

resource "null_resource" "dns_gen" {
  depends_on = [ "null_resource.dns_dig" ]
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

resource "azurerm_dns_a_record" "A-etcd"  {
  name = "etcd"
  zone_name = "${azurerm_dns_zone.cncf.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  records = [
    "${ var.master-ips }"
  ]
}

resource "azurerm_dns_a_record" "A-etcds" {
  count = "${ length(var.master-ips) }"

  name = "etcd${ count.index+1 }"
  zone_name = "${azurerm_dns_zone.cncf.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  records = [
    "${ element(var.master-ips, count.index) }"
  ]
}

resource "azurerm_dns_a_record" "A-master" {
  name = "master"
  zone_name = "${azurerm_dns_zone.cncf.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  records = [ "${ var.master-ips }" ]
}

resource "azurerm_dns_a_record" "A-masters" {
  count = "${ length(var.master-ips) }"
  name = "master${ count.index+1 }"
  zone_name = "${azurerm_dns_zone.cncf.name}"
  resource_group_name = "${ var.name }"
  ttl = "300"
  records = [
    "${ element(var.master-ips, count.index) }"
  ]
}

resource "azurerm_dns_srv_record" "etcd-client-tcp" {
  name = "_etcd-client._tcp"
  zone_name = "${azurerm_dns_zone.cncf.name}"
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
  zone_name = "${azurerm_dns_zone.cncf.name}"
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
