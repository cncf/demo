data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    # bucket = "${ var.bucket-prefix }"
    cluster-domain = "${ var.cluster-domain }"
    dns-service-ip = "${ var.dns-service-ip }"
    kubelet-image-url = "${ var.k8s["kubelet-image-url"] }"
    kubelet-image-tag = "${ var.k8s["kubelet-image-tag"] }"
    internal-tld = "${ var.internal-tld }"
    location = "${ var.location }"
    k8s-worker-tar = "${ base64encode(var.k8s-worker-tar) }"
  }
}
