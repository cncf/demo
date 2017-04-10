provider "aws" { region = "${ var.aws_region }" }

# Add AWS Keypair
resource "null_resource" "aws_keypair" {

  provisioner "local-exec" {
    command = <<EOF
aws --region ${ var.aws_region } ec2 create-key-pair \
 --key-name  ${ var.aws_key_name } \
 --query 'KeyMaterial' \
 --output text \
 > ${ var.data_dir }/${ var.aws_key_name }.pem
chmod 400 ${ var.data_dir }/${ var.aws_key_name }.pem
EOF
  }

}

resource "null_resource" "dummy_dependency2" {
  depends_on = [ "null_resource.aws_keypair" ]
}


# Clean-up Destroy
resource "null_resource" "cleanup" {

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = <<EOF
aws --region ${ var.aws_region } ec2 delete-key-pair --key-name ${ var.aws_key_name } || true
rm -rf ${ var.data_dir }/${ var.aws_key_name }.pem
rm -rf ${ var.data_dir }/.cfssl
rm -rf /cncf/data/terraform.tfstate*
rm -rf /cncf/data/kubeconfig
rm -rf /cncf/data/awsconfig
rm -rf /cncf/data/.terraform
rm -rf /cncf/data/tmp
EOF
  }

}

resource "null_resource" "dummy_dependency3" {
  depends_on = [ "null_resource.cleanup" ]
}
