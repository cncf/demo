#resource "null_resource" "dummy_dependency" {
#  depends_on = [
#    "aws_vpc.main",
#    "aws_nat_gateway.nat"
#  ]
#}


resource "azurerm_virtual_network" "main" {
  name                = "virtualNetwork"
  resource_group_name = "${ var.name }"
  address_space       = ["${ var.cidr }"]
  location            = "West US"
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  #tags {
   #builtWith = "terraform"
   #KubernetesCluster = "${ var.name }"
   #z8s = "${ var.name }"
   #Name = "kz8s-${ var.name }"
   #version = "${ var.hyperkube-tag }"
   #visibility = "private,public"
  #}
}
