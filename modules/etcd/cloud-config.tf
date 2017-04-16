data "template_file" "cloud-config" {
  count = "${ var.master-node-count }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster-domain = "${ var.cluster-domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns-service-ip = "${ var.dns-service-ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    kubelet-image-url = "${ var.kubelet-image-url }"
    kubelet-image-tag = "${ var.kubelet-image-tag }"
    internal-tld = "${ var.internal-tld }"
    pod-cidr = "${ var.pod-cidr }"
    service-cidr = "${ var.service-cidr }"
    ca = "${ base64encode(var.ca) }"
    k8s-etcd = "${ base64encode(var.k8s-etcd) }"
    k8s-etcd-key = "${ base64encode(var.k8s-etcd-key) }"
    k8s-apiserver = "${ base64encode(var.k8s-apiserver) }"
    k8s-apiserver-key = "${ base64encode(var.k8s-apiserver-key) }"
    name-servers-file = "${ var.name-servers-file }"
    # cloud-config = "${ base64encode(var.cloud-config) }"

  }
}

