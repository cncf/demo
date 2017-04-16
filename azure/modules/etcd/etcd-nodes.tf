resource "azurerm_network_interface" "cncf" {
  count = "${ var.master_node_count }"
  name                = "etcd-interface${ count.index + 1 }"
  location            = "${ var.location }"
  resource_group_name = "${ var.name }"

  ip_configuration {
    name                          = "etcd-nic${ count.index + 1 }"
    subnet_id                     = "${ var.subnet-id }"
    private_ip_address_allocation = "dynamic"
    # private_ip_address            = "${ element( split(",", var.etcd-ips), count.index ) }"
    load_balancer_backend_address_pools_ids = ["${ azurerm_lb_backend_address_pool.cncf.id }"]
  }
}

resource "azurerm_virtual_machine" "cncf" {
  count = "${ var.master_node_count }"
  name                  = "etcd-master${ count.index + 1 }"
  location              = "${ var.location }"
  availability_set_id   = "${ var.availability-id }"
  resource_group_name = "${ var.name }"
  network_interface_ids = ["${ element(azurerm_network_interface.cncf.*.id, count.index) }"] 
  vm_size               = "${ var.master_vm_size }"

  storage_image_reference {
    publisher = "${ var.image_publisher }"
    offer     = "${ var.image_offer }"
    sku       = "${ var.image_sku }"
    version   = "${ var.image_version}"
  }

  storage_os_disk {
    name          = "etcd-disks${ count.index + 1 }"
    vhd_uri       = "${ var.storage-primary-endpoint }${ var.storage-container }/etcd-vhd${ count.index + 1 }.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "etcd-master${ count.index + 1 }"
    admin_username = "${ var.admin_username }"
    admin_password = "Password1234!"
    custom_data = "${ element(data.template_file.cloud-config.*.rendered, count.index) }"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${ var.admin_username }/.ssh/authorized_keys"
      key_data = "${file("/cncf/data/.ssh/id_rsa.pub")}"
  }
 }
}

data "template_file" "etcd-cloud-config" {
  count = "${ var.master_node_count }"
  template = "${ file( "${ path.module }/etcd-cloud-config.yml" )}"

  vars {
    # bucket = "${ var.s3_bucket }"
    cluster_domain = "${ var.cluster_domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns_service_ip = "${ var.dns_service_ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal_tld }"
    hostname = "etcd${ count.index + 1 }"
    kubelet_image_url = "${ var.kubelet_image_url }"
    kubelet_image_tag = "${ var.kubelet_image_tag }"
    internal_tld = "${ var.internal_tld }"
    pod_cidr = "${ var.pod_cidr }"
    location = "${ var.location }"
    service_cidr = "${ var.service_cidr }"
    k8s-apiserver-tar = "${ base64encode(var.k8s-apiserver-tar) }"
    node-ip = "${ element(azurerm_network_interface.cncf.*.private_ip_address, count.index) }"
    cloud-config = "${ base64encode(var.cloud-config) }"

  }
}
