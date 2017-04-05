#resource "null_resource" "dummy_dependency" {
#  depends_on = [
#    "aws_vpc.main",
#    "aws_nat_gateway.nat"
#  ]
#}


resource "azurerm_virtual_network" "cncf" {
  name                = "${ var.name }"
  resource_group_name = "${ var.name }"
  address_space       = ["${ var.cidr }"]
  location            = "${ var.location }"
  dns_servers         = [
    "${ element(split( ",", file(var.name-servers-file) ),0) }",
    "${ element(split( ",", file(var.name-servers-file) ),1) }",
    "8.8.8.8"
  ]
  # getting dns servers in list form was difficult
  # module.vpc.azurerm_virtual_network.main: Creating...
  # address_space.#:     "" => "1"
  # address_space.0:     "" => "10.0.0.0/16"
  # dns_servers.#:       "" => "4"
  # dns_servers.0:       "" => "40.90.4.9"
  # dns_servers.1:       "" => "13.107.24.9"
  # dns_servers.2:       "" => "64.4.48.9"
  # dns_servers.3:       "" => "13.107.160.9"

  # tags {
   #builtWith = "terraform"
   #KubernetesCluster = "${ var.name }"
   #z8s = "${ var.name }"
   #Name = "kz8s-${ var.name }"
   #version = "${ var.hyperkube-tag }"
   #visibility = "private,public"
  #}
}

resource "azurerm_route_table" "cncf" {
  name                = "${ var.name }"
  location            = "${ var.location }"
  resource_group_name = "${ var.name }"
}
