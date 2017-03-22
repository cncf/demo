variable "admin-key-pem" {}
variable "admin-pem" {}
variable "ca-pem" {}
variable "fqdn-k8s" {}
variable "name" {}


output "kubeconfig" { value = "${ data.template_file.kubeconfig.rendered }" }
