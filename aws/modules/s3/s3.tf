resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.s3_bucket }"
  force_destroy = true

  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    Name = "kz8s-${ var.name }"
    version = "${ var.kubelet_version }"
  }

  provisioner "local-exec" {
    command = <<EOF
HYPERKUBE=${ var.kubelet_aci }:${ var.kubelet_version } \
INTERNAL_TLD=${ var.internal_tld } \
REGION=${ var.region } \
SERVICE_CLUSTER_IP_RANGE=${ var.service-cluster-ip-range } \
DIR_SSL=${ var.data_dir }/.cfssl \
${ path.module }/s3-cp ${ var.s3_bucket }
EOF

  }

  region = "${ var.region }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "aws_s3_bucket.ssl" ]
}
