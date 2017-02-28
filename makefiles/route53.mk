test-route53:
	@scripts/ssh ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem `terraform output -state /cncf/data/terraform.state bastion-ip` \
		"( nslookup etcd.`terraform output internal-tld` )"
	@scripts/ssh ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem `terraform output -state /cncf/data/terraform.state bastion-ip` \
		"( dig `terraform output internal-tld` ANY )"
	@scripts/ssh ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem `terraform output -state /cncf/data/terraform.state bastion-ip` \
	  "( dig +noall +answer SRV _etcd-server._tcp.`terraform output -state /cncf/data/terraform.state internal-tld` )"
	@scripts/ssh ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem `terraform output -state /cncf/data/terraform.state bastion-ip` \
		"( dig +noall +answer SRV _etcd-client._tcp.`terraform output internal-tld` )"
	@scripts/ssh ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem `terraform output -state /cncf/data/terraform.state bastion-ip` \
		"( dig +noall +answer etcd.`terraform output -state /cncf/data/terraform.state internal-tld` )"

.PHONY: test-route53
