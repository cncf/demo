data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster-domain = "${ var.cluster-domain }"
    dns-service-ip = "${ var.dns-service-ip }"
    kubelet-image-url = "${ var.kubelet-image-url }"
    kubelet-image-tag = "${ var.kubelet-image-tag }"
    internal-tld = "${ var.internal-tld }"
    ca = "${ base64encode(var.ca) }"
    k8s-worker = "${ base64encode(var.k8s-worker)  }"
    k8s-worker-key = "${ base64encode(var.k8s-worker-key) }"
    name = "${ var.name }"
    domain = "${ var.domain }"
    # cloud-config = "${ base64encode(var.cloud-config) }"
  }
}
