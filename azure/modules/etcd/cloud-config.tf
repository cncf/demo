data "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    # bucket = "${ var.bucket-prefix }"
    etcd-url = "${ var.etcd-url }"
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
    k8s-apiserver-tar64 = "${ base64encode(var.k8s-apiserver-tar) }"
    node-ip = "${ element(azurerm_network_interface.test.*.private_ip_address, count.index) }"

  }
}
