resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.s3_bucket }"
  force_destroy = true

  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    Name = "kz8s-${ var.name }"
  }

  provisioner "local-exec" {
    command = <<EOF
REGION=${ var.region } \
DIR_SSL=${ var.data_dir }/.cfssl \
${ path.module }/s3-cp ${ var.s3_bucket }
EOF

  }

  region = "${ var.region }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "aws_s3_bucket.ssl" ]
}
