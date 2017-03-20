data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    # bucket = "${ var.bucket-prefix }"
    cluster-domain = "${ var.cluster-domain }"
    dns-service-ip = "${ var.dns-service-ip }"
    hyperkube-image = "${ var.hyperkube-image }"
    hyperkube-tag = "${ var.hyperkube-tag }"
    internal-tld = "${ var.internal-tld }"
    location = "${ var.location }"
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
    # ssl-tar = "/ssl/k8s-worker.tar"
  }
}
