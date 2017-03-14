data "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    # bucket = "${ var.bucket-prefix }"
    cluster-domain = "${ var.cluster-domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns-service-ip = "${ var.dns-service-ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.hyperkube-image }:${ var.hyperkube-tag }"
    hyperkube-image = "${ var.hyperkube-image }"
    hyperkube-tag = "${ var.hyperkube-tag }"
    internal-tld = "${ var.internal-tld }"
    pod-ip-range = "${ var.pod-ip-range }"
    location = "${ var.location }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
    # ssl-tar = "ssl/k8s-apiserver.tar"
    ca = "${ var.ca }"
    ca-key = "${ var.ca-key }"
    k8s-admin = "${ var.k8s-admin }"
    k8s-admin-key = "${ var.k8s-admin-key }"
    k8s-apiserver = "${ var.k8s-apiserver }"
    k8s-apiserver-key = "${ var.k8s-apiserver-key }"
    k8s-etcd = "${ var.k8s-etcd }"
    k8s-etcd-key = "${ var.k8s-etcd-key }"
    k8s-worker = "${ var.k8s-worker }"
    k8s-worker-key = "${ var.k8s-worker-key }"

  }
}
