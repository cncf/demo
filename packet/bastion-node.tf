resource "packet_device" "bastion" {
  hostname = "bastion"
  plan = "baremetal_0"
  operating_system = "coreos_stable"
  user_data = "${ data.template_file.bastion-user-data.rendered }"
  billing_cycle = "hourly"
  facility = "${ var.packet_facility }"
  project_id = "${ var.packet_project_id }"
}

data "template_file" "bastion-user-data" {
  template = "${ file( "${ path.module }/bastion-user-data.yml" )}"
  vars {
    internal_tld = "${ var.internal_tld }"
  }
}
