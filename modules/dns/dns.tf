resource "google_dns_managed_zone" "cncf" {
  name        = "${ var.name }"
  dns_name    = "${ var.internal-tld }."
  description = "${ var.name }"
}

resource "google_dns_record_set" "A-etcd" {
  name = "${ var.name }.${ var.internal-tld }."
  type = "A"
  ttl  = 300

  managed_zone = "${ google_dns_managed_zone.cncf.name }"

  rrdatas = [
    "${ var.master-ips }"
  ]
}

resource "google_dns_record_set" "A-etcds" {
  count = "${ var.master-node-count }"
  name = "${ var.name }${ count.index+1 }.${ var.internal-tld }."
  type = "A"
  ttl  = 300

  managed_zone = "${ google_dns_managed_zone.cncf.name }"

  rrdatas = [
    "${ element(var.master-ips, count.index) }"
  ]
}


# resource "azurerm_dns_a_record" "A-etcd"  {
#   name = "etcd"
#   zone_name = "${azurerm_dns_zone.cncf.name}"
#   resource_group_name = "${ var.name }"
#   ttl = "300"
#   records = [
#     "${ var.master-ips }"
#   ]
# }

# resource "azurerm_dns_a_record" "A-etcds" {
#   count = "${ length(var.master-ips) }"

#   name = "etcd${ count.index+1 }"
#   zone_name = "${azurerm_dns_zone.cncf.name}"
#   resource_group_name = "${ var.name }"
#   ttl = "300"
#   records = [
#     "${ element(var.master-ips, count.index) }"
#   ]
# }

# resource "azurerm_dns_a_record" "A-master" {
#   name = "master"
#   zone_name = "${azurerm_dns_zone.cncf.name}"
#   resource_group_name = "${ var.name }"
#   ttl = "300"
#   records = [ "${ var.master-ips }" ]
# }

# resource "azurerm_dns_a_record" "A-masters" {
#   count = "${ length(var.master-ips) }"
#   name = "master${ count.index+1 }"
#   zone_name = "${azurerm_dns_zone.cncf.name}"
#   resource_group_name = "${ var.name }"
#   ttl = "300"
#   records = [
#     "${ element(var.master-ips, count.index) }"
#   ]
# }

# resource "azurerm_dns_srv_record" "etcd-client-tcp" {
#   name = "_etcd-client._tcp"
#   zone_name = "${azurerm_dns_zone.cncf.name}"
#   resource_group_name = "${ var.name }"
#   ttl = "300"

#   record {
#     priority = 0
#     weight = 0
#     port = 2379
#     target = "etcd1.${ var.internal-tld }"
#   }

#   record {
#     priority = 0
#     weight = 0
#     port = 2379
#     target = "etcd2.${ var.internal-tld }"
#   }

#   record {
#     priority = 0
#     weight = 0
#     port = 2379
#     target = "etcd3.${ var.internal-tld }"
#   }

# }

# resource "azurerm_dns_srv_record" "etcd-server-tcp" {
#   name = "_etcd-server-ssl._tcp"
#   zone_name = "${azurerm_dns_zone.cncf.name}"
#   resource_group_name = "${ var.name }"
#   ttl = "300"

#   record {
#     priority = 0
#     weight = 0
#     port = 2380
#     target = "etcd1.${ var.internal-tld }"
#   }

#   record {
#     priority = 0
#     weight = 0
#     port = 2380
#     target = "etcd2.${ var.internal-tld }"
#   }

#   record {
#     priority = 0
#     weight = 0
#     port = 2380
#     target = "etcd3.${ var.internal-tld }"
#   }

# }
