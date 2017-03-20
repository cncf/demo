resource "azurerm_virtual_machine_scale_set" "test" {
  name = "mytestscaleset-1"
  location = "${ var.location }"
  # availability_set_id   = "${ var.availability-id }"
  resource_group_name = "${ var.name }"
  upgrade_policy_mode = "Manual"

  sku {
    name = "Standard_A0"
    tier = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username = "dlx"
    admin_password = "Passwword1234"
    custom_data = "${ data.template_file.cloud-config.rendered }"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path = "/home/dlx/.ssh/authorized_keys"
     key_data = "${file("/cncf/data/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
      name = "TestNetworkProfile"
      primary = true
      ip_configuration {
        name = "TestIPConfiguration"
        subnet_id = "${ var.subnet-id }"
        load_balancer_backend_address_pool_ids = ["${ var.external-lb }"] 
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
    version   = "1298.5.0"
  }
}

/*
resource "aws_launch_configuration" "worker" {
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = "${ var.volume_size["ebs"] }"
    volume_type = "gp2"
  }

  iam_instance_profile = "${ var.instance-profile-name }"
  image_id = "${ var.ami-id }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"

  # Storage
  root_block_device {
    volume_size = "${ var.volume_size["root"] }"
    volume_type = "gp2"
  }

  security_groups = [
    "${ var.security-group-id }",
  ]

  user_data = "${ data.template_file.cloud-config.rendered }"

  /*lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  name = "worker-${ var.worker-name }-${ var.name }"

  desired_capacity = "${ var.capacity["desired"] }"
  health_check_grace_period = 60
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${ aws_launch_configuration.worker.name }"
  max_size = "${ var.capacity["max"] }"
  min_size = "${ var.capacity["min"] }"
  vpc_zone_identifier = [ "${ split(",", var.subnet-ids) }" ]

  tag {
    key = "builtWith"
    value = "terraform"
    propagate_at_launch = true
  }

  tag {
    key = "depends-id"
    value = "${ var.depends-id }"
    propagate_at_launch = false
  }

  # used by kubelet's aws provider to determine cluster
  tag {
    key = "KubernetesCluster"
    value = "${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "kz8s"
    value = "${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "Name"
    value = "kz8s-worker"
    propagate_at_launch = true
  }

  tag {
    key = "role"
    value = "worker"
    propagate_at_launch = true
  }

  tag {
    key = "version"
    value = "${ var.hyperkube-tag }"
    propagate_at_launch = true
  }

  tag {
    key = "visibility"
    value = "private"
    propagate_at_launch = true
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_autoscaling_group.worker",
    "aws_launch_configuration.worker",
  ]
}
*/
