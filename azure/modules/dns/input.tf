variable "internal_tld" {}
variable "name" {}
variable "name_servers_file" { default = "azure_dns_zone"}
variable "master_ips" { type = "list" }
variable "master_node_count" {}
