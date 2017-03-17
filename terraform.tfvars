aws = {
  account-id = "751789298977"
  azs = "ap-southeast-2a,ap-southeast-2b,ap-southeast-2c"
  key-name = "ii-cncfdemo"
  region = "West US"
}
cidr = {
  allow-ssh = "103.26.16.226/32"
  pods = "10.2.0.0/16"
  service-cluster = "10.3.0.0/24"
  vpc = "10.0.0.0/16"
}
coreos-aws = {
  ami = "CoreOS Linux (Stable)"
}
k8s = {
    hyperkube-image = "quay.io/coreos/hyperkube"
    hyperkube-tag = "v1.4.7_coreos.0"
}
dns-service-ip = "10.3.0.10"
internal-tld = "test.kz8s"
k8s-service-ip = "10.3.0.1"
name = "test"
s3-bucket = "751789298977-test-ap-southeast-2"
etcd-ips = "10.0.10.10,10.0.10.11,10.0.10.12"
dir-ssl = "/cncf/data/.cfssl"
# # This is merged in with terraform.tfvars for override/existing VPC purposes.  Only to be used in conjunction with modules_override.tf
# etcd-url = "https://discovery.etcd.io/660fef748f3d3350492ae5939e00ecf4"

# # The existing VPC CIDR range, ensure that the the etcd, controller and worker IPs are in this range
# cidr.vpc = "10.0.0.0/16"

# # etcd server static IPs, ensure that they fall within the exisiting VPC public subnet range
# etcd-ips = "10.0.0.10,10.0.0.11,10.0.0.12"

# # Put your existing VPC info here:
# vpc-existing {
# 	id = "vpc-"
# 	gateway-id = "igw-"
# 	subnet-ids-public = "subnet-,subnet-"
# 	subnet-ids-private = "subnet-,subnet-"
# }
