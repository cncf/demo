resource "gzip_me" "ca" {
  input = "${ var.ca }"
}

resource "gzip_me" "k8s_etcd" {
  input = "${ var.k8s_etcd }"
}

resource "gzip_me" "k8s_etcd_key" {
  input = "${ var.k8s_etcd_key }"
}

resource "gzip_me" "k8s_apiserver" {
  input = "${ var.k8s_apiserver }"
}

resource "gzip_me" "k8s_apiserver_key" {
  input = "${ var.k8s_apiserver_key }"
}

data "template_file" "kube-apiserver" {
  template = "${ file( "${ path.module }/kube-apiserver.yml" )}"

  vars {
    internal_tld = "${ var.internal_tld }"
    service_cidr = "${ var.service_cidr }"
    hyperkube = "${ var.kubelet_aci }:${ var.kubelet_version }"
    kubelet_aci = "${ var.kubelet_aci }"
    kubelet_version = "${ var.kubelet_version }"
  }
}

resource "gzip_me" "kube-apiserver" {
  input = "${ data.template_file.kube-apiserver.rendered }"
}

data "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd_ips) ) }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster_domain = "${ var.cluster_domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns_service_ip = "${ var.dns_service_ip }"
    fqdn = "etcd${ count.index + 1 }.${ var.internal_tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.kubelet_aci }:${ var.kubelet_version }"
    kubelet_aci = "${ var.kubelet_aci }"
    kubelet_version = "${ var.kubelet_version }"
    internal_tld = "${ var.internal_tld }"
    pod_cidr = "${ var.pod_cidr }"
    region = "${ var.region }"
    service_cidr = "${ var.service_cidr }"
    ca = "${ gzip_me.ca.output }"
    k8s_etcd = "${ gzip_me.k8s_etcd.output }"
    k8s_etcd_key = "${ gzip_me.k8s_etcd_key.output }"
    k8s_apiserver = "${ gzip_me.k8s_apiserver.output }"
    k8s_apiserver_key = "${ gzip_me.k8s_apiserver_key.output }"
    kube-apiserver-yml = "${ gzip_me.kube-apiserver.output }"
  }
}



# data "template_file" "kube-controller-manager"

# data "template_file" "kube-proxy"

# data "template_file" "kube-scheduler"
