variable "name" {}
variable "master_ips" { type = "list" }
variable "master_node_count" {}
variable "domain" {}
variable "record_ttl" { default = "60" }
