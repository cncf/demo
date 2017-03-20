cidr = {
  allow-ssh = "103.26.16.226/32"
  pods = "10.2.0.0/16"
  service-cluster = "10.3.0.0/24"
  vpc = "10.0.0.0/16"
}

# Add CoreOS Versions etc

k8s = {
    hyperkube-image = "quay.io/coreos/hyperkube"
    hyperkube-tag = "v1.4.7_coreos.0"
}

dns-service-ip = "10.3.0.10"
internal-tld = "test.kz8s"
k8s-service-ip = "10.3.0.1"
name = "test"
etcd-ips = "10.0.10.10,10.0.10.11,10.0.10.12"
dir-ssl = "/cncf/data/.cfssl"
# # This is merged in with terraform.tfvars for override/existing VPC purposes.  Only to be used in conjunction with modules_override.tf

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
