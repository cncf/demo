resource "azurerm_public_ip" "test2" {
  name = "acceptanceTestPublicIp1"
  location = "${ var.location }"
  resource_group_name = "${ var.name }"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "test2" {
  name                = "acctni2"
  location            = "${ var.location }"
  resource_group_name = "${ var.name }"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${ var.subnet-id }"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${ azurerm_public_ip.test2.id }"
  }
}

resource "azurerm_virtual_machine" "tes2t" {
  name                  = "acctvm2"
  location              = "West US"
  availability_set_id   = "${ var.availability-id }"
  resource_group_name = "${ var.name }"
  network_interface_ids = ["${azurerm_network_interface.test2.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "1298.6.0"
  }

  storage_os_disk {
    name          = "disk2"
    vhd_uri       = "${ var.storage-primary-endpoint }${ var.storage-container }/disk2.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "${ var.admin-username }"
    admin_password = "Password1234!"
    custom_data = "${ data.template_file.user-data.rendered }"
    #custom_data = "${file("${path.module}/user-data2.yml")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path = "/home/${ var.admin-username }/.ssh/authorized_keys"
     key_data = "${file("/cncf/data/.ssh/id_rsa.pub")}"
    }
  }
}

data "template_file" "user-data" {
  template = "${ file( "${ path.module }/user-data.yml" )}"
  vars {
    internal-tld = "${ var.internal-tld }"
  }
}
