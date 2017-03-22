#Create SSH Keypair
resource "null_resource" "sshkey_gen" {

  provisioner "local-exec" {
    command = <<EOF
mkdir -p /cncf/data/.ssh
ssh-keygen -t rsa -f /cncf/data/.ssh/id_rsa -N ''
EOF
  }

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = <<EOF
rm -rf /cncf/data/.ssh/id*
EOF
 }
}

resource "null_resource" "dummy_dependency2" {
  depends_on = [ "null_resource.sshkey_gen" ]
}
