# variable "depends-id" {}
variable "internal-tld" {}
variable "name" {}
variable "name-servers-file" { default = "azure_dns_zone"}
variable "master-ips" { type = "list" }
# variable "vpc-id" {}
