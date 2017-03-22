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
    kubelet-image-url = "${ var.kubelet-image-url }"
    kubelet-image-tag = "${ var.kubelet-image-tag }"
    internal-tld = "${ var.internal-tld }"
    pod-ip-range = "${ var.pod-ip-range }"
    location = "${ var.location }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
    k8s-apiserver-tar = "${ base64encode(var.k8s-apiserver-tar) }"
    node-ip = "${ element(azurerm_network_interface.cncf.*.private_ip_address, count.index) }"
    cloud-config = "${ base64encode(var.cloud-config) }"

  }
}
