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




# resource "aws_elb" "external" {
#   name = "kz8s-apiserver-${replace(var.name, "/(.{0,17})(.*)/", "$1")}"

#   cross_zone_load_balancing = false

#   health_check {
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#     timeout = 3
#     target = "HTTP:8080/"
#     interval = 30
#   }

#   instances = [ "${ aws_instance.etcd.*.id }" ]
#   idle_timeout = 3600

#   listener {
#     instance_port = 443
#     instance_protocol = "tcp"
#     lb_port = 443
#     lb_protocol = "tcp"
#   }

#   security_groups = [ "${ var.external-elb-security-group-id }" ]
#   subnets = [ "${ split(",", var.subnet-ids-public) }" ]

#   tags {
#     builtWith = "terraform"
#     kz8s = "${ var.name }"
#     Name = "kz8s-apiserver"
#     role = "apiserver"
#     version = "${ var.hyperkube-tag }"
#     visibility = "public"
#     KubernetesCluster = "${ var.name }"
#   }
# }
