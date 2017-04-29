#!/bin/bash
#
# RUN ENTRYPOINT.

set -e
RED='\033[0;31m'
NC='\033[0m' # No Color

export TF_VAR_name="$2"
export TF_VAR_internal_tld=${TF_VAR_name}.cncf.demo
export TF_VAR_data_dir=/cncf/data/${TF_VAR_name}
# tfstate, sslcerts, and ssh keys are currently stored in TF_VAR_data_dir
mkdir -p $TF_VAR_data_dir
cd $TF_VAR_data_dir
 
# Run CMD
if [ "$1" = "aws-deploy" ] ; then
    terraform get /build/aws && \
        terraform apply -target null_resource.ssl_gen /build/aws && \
        time terraform apply /deploy/aws && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/ \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/kubeconfig \n\n'${NC}
elif [ "$1" = "aws-destroy" ] ; then
    write_aws_config
    time terraform destroy -force /build/aws
elif [ "$1" = "azure-deploy" ] ; then
    # There are some dependency issues around cert,sshkey,k8s_cloud_config, and dns
    # since they use files on disk that are created on the fly
    # should probably move these to data resources
    terraform get /build/azure && \
        terraform apply -target null_resource.sshkey_gen /build/azure && \
        terraform apply -target null_resource.ssl_gen /build/azure && \
        terraform apply -target null_resource.cloud_gen /build/azure && \
        terraform apply -target module.dns.null_resource.dns_gen /build/azure && \
        terraform apply -target module.etcd.azurerm_network_interface.cncf /build/azure && \
        time terraform apply /build/azure && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "azure-destroy" ] ; then
    time terraform destroy -force /build/azure
elif [ "$1" = "packet-deploy" ] ; then
    terraform get /build/packet && \
        terraform apply -target module.etcd.null_resource.discovery_gen /build/packet && \
        terraform apply -target null_resource.ssl_ssh_gen /build/packet && \
        time terraform apply /build/packet && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "packet-destroy" ] ; then
    time terraform destroy -force /build/packet
fi
