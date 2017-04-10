variable "allow_ssh_cidr" {}
variable "vpc_cidr" {}
variable "name" {}
variable "vpc-id" {}

output "bastion-id" { value = "${ aws_security_group.bastion.id }" }
output "etcd-id" { value = "${ aws_security_group.etcd.id }" }
output "external-elb-id" { value = "${ aws_security_group.external-elb.id }" }
output "worker-id" { value = "${ aws_security_group.worker.id }" }
