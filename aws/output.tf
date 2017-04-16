# outputs
output "azs" { value = "${ var.aws_azs }" }
output "bastion-ip" { value = "${ module.bastion.ip }" }
output "cluster_domain" { value = "${ var.cluster_domain }" }
output "dns_service_ip" { value = "${ var.dns_service_ip }" }
output "etcd1-ip" { value = "${ element( split(",", var.etcd_ips), 0 ) }" }
output "external-elb" { value = "${ module.etcd.external-elb }" }
output "internal_tld" { value = "${ var.internal_tld }" }
output "name" { value = "${ var.name }" }
output "region" { value = "${ var.aws_region }" }
output "subnet-ids-private" { value = "${ module.vpc.subnet-ids-private }" }
output "subnet-ids-public" { value = "${ module.vpc.subnet-ids-public }" }
output "worker-autoscaling-group-name" { value = "${ module.worker.autoscaling-group-name }" }
output "ssh-key-setup" { value = "eval $(ssh-agent) ; ssh-add ${ var.data_dir}/${ var.name}.pem" }
output "ssh-via-bastion" { value = "ssh -At ${ var.admin_username }@${ module.bastion.ip } ssh ${ var.admin_username }@etcd1.${ var.internal_tld }"}

