#Gen Certs
resource "null_resource" "ssl_gen" {

  provisioner "local-exec" {
    command = <<EOF
${ path.module }/init-cfssl \
${ var.dir-ssl } \
${ azurerm_resource_group.cncf.location } \
${ var.internal-tld } \
${ var.k8s-service-ip }
EOF
  }

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = <<EOF
rm -rf ${ var.dir-ssl }
EOF
  }

}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "null_resource.ssl_gen" ]
}

