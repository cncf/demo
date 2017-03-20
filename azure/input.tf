variable "name" {}

variable "azure" {
  default = {
    resource-group = "deploy"
    location = "West US"
  }
}

variable "cidr" {
  default = {
    allow-ssh = "0.0.0.0/0"
    pods = "10.2.0.0/16"
    service-cluster = "10.3.0.0/24"
    vpc = "10.0.0.0/16"
  }
}

variable "cluster-domain" { default = "cluster.local" }
variable "dns-service-ip" { default = "10.3.0.10" }
variable "etcd-ips" { default = "10.0.10.10,10.0.10.11,10.0.10.12" }
variable "instance-type" {
  default = {
    bastion = "t2.nano"
    etcd = "m3.medium"
    worker = "m3.medium"
  }
}
variable "internal-tld" {}

# Set from https://quay.io/repository/coreos/hyperkube?tab=tags
variable "k8s" {
  default = {
    kubelet-image-url = "quay.io/coreos/hyperkube"
    kubelet-image-tag = "v1.5.1_coreos.0"
  }
}

variable "k8s-service-ip" { default = "10.3.0.1" }

variable "vpc-existing" {
  default = {
    id = ""
    gateway-id = ""
    subnet-ids-public = ""
    subnet-ids-private = ""
  }
}
variable "dir-ssl" { default = "/cncf/data/.cfssl" }
variable "dir-key-pair" { default = "/cncf/data"}
variable "admin-username" { default = "cncf"}
