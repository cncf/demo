resource "azurerm_public_ip" "test" {
  name = "PublicIPForLB"
  location = "${ var.location }"
  resource_group_name = "${ var.name }"
  public_ip_address_allocation = "static"
  domain_name_label = "k8soeu"
}

resource "azurerm_lb" "test" {
  name = "TestLoadBalancer"
  location = "${ azurerm_public_ip.test.location }"
  resource_group_name = "${ azurerm_public_ip.test.resource_group_name }"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_lb_rule" "test" {
  resource_group_name = "${azurerm_public_ip.test.resource_group_name}"
  loadbalancer_id = "${azurerm_lb.test.id}"
  name = "LBRule"
  protocol = "Tcp"
  frontend_port = 443
  backend_port = 443
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "test" {
  resource_group_name = "${azurerm_public_ip.test.resource_group_name}"
  loadbalancer_id = "${azurerm_lb.test.id}"
  name = "K8s-Probe"
  port = 443
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = "${ azurerm_public_ip.test.resource_group_name }"
  loadbalancer_id = "${azurerm_lb.test.id}"
  name = "BackEndAddressPool"
}
