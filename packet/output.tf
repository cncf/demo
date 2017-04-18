# output "fqdn_k8s" { value = "${ module.etcd.fqdn_lb}" }
# output "bastion_ip" { value = "${ module.bastion.bastion_ip}" }
# output "bastion_fqdn" { value = "${ module.bastion.bastion_fqdn}" }
# output "k8s_admin" { value = "${ k8s_admin}"}
# # fixme for use outside container
output "ssh_key_setup" { value = "eval $(ssh-agent) ; ssh-add ${ var.data_dir }/.ssh/id_rsa"}
output "ssh_via_bastion" { value = "ssh -At core@${ packet_device.bastion.network.0.address }" }
output "ssh_first_master" { value = "ssh -At core@${ module.etcd.first_master_ip }" }
output "ssh_second_master" { value = "ssh -At core@${ module.etcd.second_master_ip }" }
output "ssh_third_master" { value = "ssh -At core@${ module.etcd.third_master_ip }" }
output "ssh_first_worker" { value = "ssh -At core@${ module.worker.first_worker_ip }" }
output "ssh_second_worker" { value = "ssh -At core@${ module.worker.second_worker_ip }" }
output "ssh_third_worker" { value = "ssh -At core@${ module.worker.third_worker_ip }" }
# " ssh ${ var.admin_username }@etcd1.${ var.internal_tld }"}
