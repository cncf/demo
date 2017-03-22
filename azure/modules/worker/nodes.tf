resource "azurerm_network_interface" "cncf" {
  count               = "${ var.worker-node-count }"
  name                = "worker-interface${ count.index + 1 }"
  location            = "${ var.location }"
  resource_group_name = "${ var.name }"

  ip_configuration {
    name                          = "worker-nic${ count.index + 1 }"
    subnet_id                     = "${ var.subnet-id }"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "cncf" {
  count = "${ var.worker-node-count }"
  name                  = "worker-node${ count.index + 1 }"
  location              = "${ var.location }"
  availability_set_id   = "${ var.availability-id }"
  resource_group_name   = "${ var.name }"
  network_interface_ids = ["${ element(azurerm_network_interface.cncf.*.id, count.index) }"]
  vm_size               = "${ var.worker-vm-size }"

  storage_image_reference {
    publisher = "${ var.image-publisher }"
    offer     = "${ var.image-offer }"
    sku       = "${ var.image-sku }"
    version   = "${ var.image-version}"
  }

  storage_os_disk {
    name          = "worker-disks${ count.index + 1 }"
    vhd_uri       = "${ var.storage-primary-endpoint }${ var.storage-container }/worker-vhd${ count.index + 1 }.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "worker-node${ count.index + 1 }"
    admin_username = "${ var.admin-username }"
    admin_password = "Password1234!"
    custom_data = "${ element(data.template_file.cloud-config.*.rendered, count.index) }"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${ var.admin-username }/.ssh/authorized_keys"
      key_data = "${file("/cncf/data/.ssh/id_rsa.pub")}"
  }
 }
}

/*
resource "azurerm_virtual_machine_scale_set" "cncf" {
  name = "${ var.name }"
  location = "${ var.location }"
  resource_group_name = "${ var.name }"
  upgrade_policy_mode = "Manual"

  sku {
    name = "Standard_A0"
    tier = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "worker"
    admin_username = "${ var.admin-username }"
    admin_password = "Password1234"
    custom_data = "${ data.template_file.cloud-config.rendered }"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path = "/home/${ var.admin-username }/.ssh/authorized_keys"
     key_data = "${file("/cncf/data/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
      name = "TestNetworkProfile"
      primary = true
      ip_configuration {
        name = "TestIPConfiguration"
        subnet_id = "${ var.subnet-id }"
        # load_balancer_backend_address_pool_ids = ["${ var.external-lb }"] 
      }
  }

  storage_profile_os_disk {
    name = "osDiskProfile"
    caching       = "ReadWrite"
    create_option = "FromImage"
    vhd_containers = ["${ var.storage-primary-endpoint }${ var.storage-container }"]
  }

  storage_profile_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "1298.6.0"
  }
}
*/
