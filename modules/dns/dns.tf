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

resource "google_dns_record_set" "CNAME-master" {
  name = "master_${ var.name }.${ var.internal-tld }."
  type = "CNAME"
  ttl  = 300

  managed_zone = "${ google_dns_managed_zone.cncf.name }"

  rrdatas = [
    "${ var.name }.${ var.internal-tld }."
  ]
}

resource "google_dns_record_set" "etcd-client-tcp" {
  name = "_etcd-client._tcp.${ var.internal-tld }."
  type = "SRV"
  ttl  = 300

  managed_zone = "${ google_dns_managed_zone.cncf.name }"

  rrdatas = [
    "${ formatlist("0 0 2379 %v", google_dns_record_set.A-etcds.*.name) }"
  ]
}

resource "google_dns_record_set" "etcd-server-tcp" {
  name = "_etcd-server-ssl._tcp.${ var.internal-tld }."
  type = "SRV"
  ttl  = 300

  managed_zone = "${ google_dns_managed_zone.cncf.name }"

  rrdatas = [
    "${ formatlist("0 0 2380 %v", google_dns_record_set.A-etcds.*.name) }"
  ]
}
