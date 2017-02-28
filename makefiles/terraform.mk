.terraform: ; terraform get

terraform.tfvars:
	@./scripts/init-variables \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} \
		${INTERNAL_TLD} ${CLUSTER_NAME} `scripts/myip` ${CIDR_VPC} ${CIDR_PODS} \
		${CIDR_SERVICE_CLUSTER} ${K8S_SERVICE_IP} ${K8S_DNS_IP} ${ETCD_IPS} ${HYPERKUBE_IMAGE} ${HYPERKUBE_TAG}

module.%:
	@echo "${BLUE}❤ make $@ - commencing${NC}"
	@time terraform apply -state /cncf/data/terraform.state -target $@
	@echo "${GREEN}✓ make $@ - success${NC}"
	@sleep 5.2

## terraform apply
apply: plan
	@echo "${BLUE}❤ terraform apply - commencing${NC}"
	terraform apply -state /cncf/data/terraform.state
	@echo "${GREEN}✓ make $@ - success${NC}"

## terraform destroy
destroy: ; terraform destroy -force -state /cncf/data/terraform.state || true

## terraform get
get: ; terraform get

## generate variables
init: terraform.tfvars

## terraform plan
plan: get init
	terraform validate
	@echo "${GREEN}✓ terraform validate - success${NC}"
	terraform plan -state /cncf/data/terraform.state -out terraform.tfplan

## terraform show
show: ; terraform show /cncf/data/terraform.state

.PHONY: apply destroy get init module.% plan show
