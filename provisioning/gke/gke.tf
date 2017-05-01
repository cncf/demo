provider "google" {}

resource "null_resource" "file" {

  provisioner "local-exec" {
    command = <<LOCAL_EXEC
echo "${ var.ca }" > /cncf/ca.pem
echo "${ var.admin}" > /cncf/admin.pem
echo "${ var.admin_key}" > /cncf/admin_key.pem
LOCAL_EXEC
  }
}
