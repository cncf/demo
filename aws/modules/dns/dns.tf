resource "aws_route53_zone" "internal" {
  comment = "Kubernetes cluster DNS (internal)"
  name = "${ var.internal_tld }"
  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    Name = "k8s-${ var.name }"
  }
  vpc_id = "${ var.vpc_id }"
}

resource "aws_route53_record" "A-etcd" {
  name = "etcd"
  records = [ "${ var.master_ips }" ]
  ttl = "300"
  type = "A"
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "A-etcds" {
  name = "etcd${ count.index+1 }"
  count = "${ var.master_node_count }"
  ttl = "300"
  type = "A"
  records = [ "${ element(var.master_ips, count.index) }" ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "CNAME-master" {
  name = "master"
  records = [ "etcd.${ var.internal_tld }" ]
  ttl = "300"
  type = "CNAME"
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-client-tcp" {
  name = "_etcd-client._tcp"
  ttl = "300"
  type = "SRV"
  records = [ "${ formatlist("0 0 2379 %v", aws_route53_record.A-etcds.*.fqdn) }" ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-server-tcp" {
  name = "_etcd-server-ssl._tcp"
  ttl = "300"
  type = "SRV"
  records = [ "${ formatlist("0 0 2380 %v", aws_route53_record.A-etcds.*.fqdn) }" ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_route53_record.etcd-server-tcp",
    "aws_route53_record.A-etcd",
  ]
}
