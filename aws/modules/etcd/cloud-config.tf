provider "gzip" {
  compressionlevel = "BestCompression"
}

resource "gzip_me" "ca" {
  input = "${ var.ca }"
}

resource "gzip_me" "k8s-etcd" {
  input = "${ var.k8s-etcd }"
}

resource "gzip_me" "k8s-etcd-key" {
  input = "${ var.k8s-etcd-key }"
}

resource "gzip_me" "k8s-apiserver" {
  input = "${ var.k8s-apiserver }"
}

resource "gzip_me" "k8s-apiserver-key" {
  input = "${ var.k8s-apiserver-key }"
}

data "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd_ips) ) }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster_domain = "${ var.cluster_domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns_service_ip = "${ var.dns_service_ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal_tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.kubelet_aci }:${ var.kubelet_version }"
    kubelet_aci = "${ var.kubelet_aci }"
    kubelet_version = "${ var.kubelet_version }"
    internal_tld = "${ var.internal_tld }"
    pod-ip-range = "${ var.pod-ip-range }"
    region = "${ var.region }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
    ca = "${ gzip_me.ca.output }"
    k8s-etcd = "${ gzip_me.k8s-etcd.output }"
    k8s-etcd-key = "${ gzip_me.k8s-etcd-key.output }"
    k8s-apiserver = "${ gzip_me.k8s-apiserver.output }"
    k8s-apiserver-key = "${ gzip_me.k8s-apiserver.output }"
    ssl_tar = "ssl/k8s-apiserver.tar.bz2"
    # bucket = "${var.s3_bucket}"
  }
}

