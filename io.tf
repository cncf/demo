# Configure the Microsoft Azure Provider
provider "azurerm" { }

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "${ var.azure["resource-group"] }"
  location = "${ var.azure["location"] }"

  }

resource "azurerm_storage_account" "test" {
  name                = "accsa123123"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  account_type        = "Standard_LRS"

  # tags {
  #   environment = "staging"
  # }
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  resource_group_name = "${ azurerm_resource_group.main.name }"
  storage_account_name  = "${ azurerm_storage_account.test.name }"
  container_access_type = "private"
}

resource "azurerm_availability_set" "test" {
  name = "acceptanceTestAvailabilitySet1"
  location = "${ var.azure["location"] }"
  resource_group_name = "${azurerm_resource_group.main.name}"

}

# variables
variable "azure" {
  default = {
    resource-group = "deploy"
    location = "West US"
    azs = ""
    key-name = ""
    region = ""
  }
}
variable "cidr" {
  default = {
    allow-ssh = "0.0.0.0/0"
    pods = "10.2.0.0/16"
    service-cluster = "10.3.0.0/24"
    vpc = "10.0.0.0/16"
  }
}
variable "cluster-domain" { default = "cluster.local" }
variable "coreos-aws" {
  default = {
    ami = ""
    channel = ""
    type = ""
  }
}
variable "dns-service-ip" { default = "10.3.0.10" }
variable "etcd-ips" { default = "10.0.10.10,10.0.10.11,10.0.10.12" }
variable "instance-type" {
  default = {
    bastion = "t2.nano"
    etcd = "m3.medium"
    worker = "m3.medium"
  }
}
variable "internal-tld" {}
variable "k8s" {
  default = {
    hyperkube-image = "quay.io/coreos/hyperkube"
    hyperkube-tag = "v1.5.1_coreos.0"
  }
}
variable "k8s-service-ip" { default = "10.3.0.1" }
variable "name" {}
variable "s3-bucket" {}
variable "vpc-existing" {
  default = {
    id = ""
    gateway-id = ""
    subnet-ids-public = ""
    subnet-ids-private = ""
  }
}
variable "dir-ssl" { default = "/cncf/data/.cfssl" }
variable "dir-key-pair" { default = "/cncf/data"}


# outputs
#output "availability-id" { value = "${ azurerm_availability_set.test.id }" }
#output "azs" { value = "${ var.aws["azs"] }" }
#output "bastion-ip" { value = "${ module.bastion.ip }" }
#output "cluster-domain" { value = "${ var.cluster-domain }" }
#output "dns-service-ip" { value = "${ var.dns-service-ip }" }
#output "etcd1-ip" { value = "${ element( split(",", var.etcd-ips), 0 ) }" }
#output "external-elb" { value = "${ module.etcd.external-elb }" }
#output "internal-tld" { value = "${ var.internal-tld }" }
#output "name" { value = "${ var.name }" }
#output "region" { value = "${ var.aws["region"] }" }
#output "s3-bucket" { value = "${ var.s3-bucket }" }
#output "subnet-ids-private" { value = "${ module.vpc.subnet-ids-private }" }
#output "subnet-ids-public" { value = "${ module.vpc.subnet-ids-public }" }
#output "worker-autoscaling-group-name" { value = "${ module.worker.autoscaling-group-name }" }
output "fqdn-k8s" { value = "${ module.etcd.fqdn-lb}" }
#Gen Certs
resource "null_resource" "ssl_gen" {

  provisioner "local-exec" {
    command = <<EOF
${ path.module }/init-cfssl \
${ var.dir-ssl } \
${ azurerm_resource_group.main.location } \
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

#Add AWS Keypair
#resource "null_resource" "aws_keypair" {

#  provisioner "local-exec" {
#    command = <<EOF
#aws --region ${ var.aws ["region"] } ec2 create-key-pair \
# --key-name  ${ var.aws["key-name"] } \
# --query 'KeyMaterial' \
# --output text \
# > ${ var.dir-key-pair }/${ var.aws["key-name"] }.pem
#chmod 400 ${ var.dir-key-pair }/${ var.aws["key-name"] }.pem
#EOF
# }

#  provisioner "local-exec" {
#    when = "destroy"
#    on_failure = "continue"
#    command = <<EOF
#aws --region ${ var.aws["region"] } ec2 delete-key-pair --key-name ${ var.aws["key-name"] } || true
#rm -rf ${ var.dir-key-pair }/${ var.aws["key-name"] }.pem
#    EOF
# }

#}
