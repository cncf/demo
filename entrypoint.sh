#!/bin/bash
#
# RUN ENTRYPOINT.

set -e
RED='\033[0;31m'
NC='\033[0m' # No Color
export TF_VAR_name="$2"

# Run CMD
if [ "$1" = "azure" ] ; then
    terraform get /azure && \
    terraform apply -target null_resource.sshkey_gen /azure && \
    terraform apply -target null_resource.ssl_gen /azure && \
    terraform apply -target null_resource.cloud_gen /azure && \
    terraform apply -target module.dns.null_resource.dns_gen /azure && \
    terraform apply -target module.etcd.azurerm_network_interface.cncf /azure && \
    time terraform apply /azure && printf "${RED}\n#Commands to Configue Kubectl \n\n" && printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/ \n\n' && printf 'export KUBECONFIG=$(pwd)/data/kubeconfig \n\n'${NC}
elif [ "$1" = "azure-destroy" ] ; then
    time terraform destroy -force /azure
fi

