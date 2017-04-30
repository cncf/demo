variable "name" {}
variable "project" {}
variable "zone" {}
variable "endpoint" {}
variable "ca" {}
variable "admin" {}
variable "admin_key" {}


output "kubeconfig" { value = "${ data.template_file.kubeconfig.rendered }" }
