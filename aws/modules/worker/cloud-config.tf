resource "gzip_me" "ca" {
  input = "${ var.ca }"
}

resource "gzip_me" "k8s_worker" {
  input = "${ var.k8s_worker }"
}

resource "gzip_me" "k8s_worker_key" {
  input = "${ var.k8s_worker_key }"
}

data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster_domain = "${ var.cluster_domain }"
    dns_service_ip = "${ var.dns_service_ip }"
    kubelet_aci = "${ var.kubelet_aci }"
    kubelet_version = "${ var.kubelet_version }"
    internal_tld = "${ var.internal_tld }"
    region = "${ var.region }"
    ca = "${ gzip_me.ca.output }"
    k8s_worker = "${ gzip_me.k8s_worker.output }"
    k8s_worker_key = "${ gzip_me.k8s_worker_key.output }"
  }
}
