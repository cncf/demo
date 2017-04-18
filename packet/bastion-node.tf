resource "packet_device" "bastion" {
  hostname                = "bastion"
  # baremental_0-3 storage_1-2
  plan            = "baremetal_0"
  facility = "${ var.packet_facility }"
  operating_system = "coreos_stable"
  billing_cycle = "hourly"
  project_id = "${ var.packet_project_id }"
  user_data = "${ data.template_file.bastion-user-data.rendered }"
}

data "template_file" "bastion-user-data" {
  template = "${ file( "${ path.module }/bastion-user-data.yml" )}"
  vars {
    internal_tld = "${ var.internal_tld }"
  }
}
