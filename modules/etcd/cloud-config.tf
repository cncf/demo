data "template_file" "cloud-config" {
  # count = "${ var.master-node-count }"
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
    k8s-apiserver-tar = "${ base64encode(var.k8s-apiserver-tar) }"
    # cloud-config = "${ base64encode(var.cloud-config) }"

  }
}

data "template_cloudinit_config" "myconfig" {
  count = "${ var.master-node-count }"
  gzip = false
  base64_encode = false

  part {
    content = "${ data.template_file.cloud-config.rendered }"
  }

  part {
    content = "${ var.k8s-apiserver-tar }"
  }
}


 # output "cloud-init-cruft" {
#   value = "${data.template_cloudinit_config.myconfig.0.rendered}"
# }
