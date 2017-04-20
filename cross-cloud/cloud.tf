module "aws" {
  source       = "../aws"
  name         = "${ var.name }-aws"
  internal_tld = "${ var.name }-aws.cncf.demo"
  data_dir     = "${ var.data_dir }/aws"
}

module "azure" {
  source                    = "../azure"
  name                      = "${ var.name }azure"
  internal_tld = "${ var.name }-azure.cncf.demo"
  data_dir                  = "${ var.data_dir }/azure"
}

module "packet" {
  source                    = "../packet"
  name                      = "${ var.name }-packet"
  data_dir                  = "${ var.data_dir }/packet"
  packet_project_id         = "${ var.packet_project_id }"
}
