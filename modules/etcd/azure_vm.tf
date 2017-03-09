resource "azurerm_network_interface" "test" {
  name                = "acctni"
  location            = "${ var.location }"
  resource_group_name = "${ var.name }"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${ var.subnet-id }"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm"
  location              = "West US"
  availability_set_id   = "${ var.availability-id }"
  resource_group_name = "${ var.name }"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "1298.5.0"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${ var.storage-primary-endpoint }${ var.storage-container }/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}

# resource "aws_instance" "etcd" {
#   count = "${ length( split(",", var.etcd-ips) ) }"

#   ami = "${ var.ami-id }"
#   associate_public_ip_address = false
#   iam_instance_profile = "${ var.instance-profile-name }"
#   instance_type = "${ var.instance-type }"
#   key_name = "${ var.key-name }"
#   private_ip = "${ element(split(",", var.etcd-ips), count.index) }"

#   root_block_device {
#     volume_size = 124
#     volume_type = "gp2"
#   }

#   source_dest_check = false
#   subnet_id = "${ element( split(",", var.subnet-ids-private), 0 ) }"

#   tags {
#     builtWith = "terraform"
#     depends-id = "${ var.depends-id }"
#     KubernetesCluster = "${ var.name }" # used by kubelet's aws provider to determine cluster
#     kz8s = "${ var.name }"
#     Name = "kz8s-etcd${ count.index + 1 }"
#     role = "etcd,apiserver"
#     version = "${ var.hyperkube-tag }"
#     visibility = "private"
#   }

#   user_data = "${ element(data.template_file.cloud-config.*.rendered, count.index) }"
#   vpc_security_group_ids = [ "${ var.etcd-security-group-id }" ]
# }

# resource "null_resource" "dummy_dependency" {
#   depends_on = [ "aws_instance.etcd" ]
# }
