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
    terraform get /cncf/aws && \
        terraform apply -target null_resource.ssl_gen /cncf/aws && \
        time terraform apply /deploy/aws && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/ \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/kubeconfig \n\n'${NC}
elif [ "$1" = "aws-destroy" ] ; then
    write_aws_config
    time terraform destroy -force /cncf/aws
elif [ "$1" = "azure-deploy" ] ; then
    # There are some dependency issues around cert,sshkey,k8s_cloud_config, and dns
    # since they use files on disk that are created on the fly
    # should probably move these to data resources
    terraform get /cncf/azure && \
        terraform apply -target null_resource.ssl_ssh_cloud_gen /cncf/cross-cloud && \
        terraform apply -target null_resource.dns_gen /cncf/azure && \
        time terraform apply /cncf/azure && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "azure-destroy" ] ; then
    time terraform destroy -force /cncf/azure
elif [ "$1" = "packet-deploy" ] ; then
    terraform get /cncf/packet && \
        terraform apply -target module.etcd.null_resource.discovery_gen /cncf/packet && \
        terraform apply -target null_resource.ssl_ssh_gen /cncf/packet && \
        time terraform apply /cncf/packet && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "packet-destroy" ] ; then
    time terraform destroy -force /cncf/packet
elif [ "$1" = "gce-deploy" ] ; then
    terraform get /cncf/gce && \
        terraform apply -target module.etcd.null_resource.discovery_gen /cncf/gce && \
        terraform apply -target null_resource.ssl_gen /cncf/gce && \
        time terraform apply /cncf/gce && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "gce-destroy" ] ; then
    time terraform destroy -force /cncf/gce
elif [ "$1" = "cross-cloud-deploy" ] ; then
    terraform get /cncf/cross-cloud && \
        terraform apply -target module.aws.null_resource.ssl_gen /cncf/cross-cloud && \
        terraform apply -target module.gce.null_resource.ssl_gen /cncf/cross-cloud && \
        terraform apply -target module.gce.module.etcd.null_resource.discovery_gen /cncf/cross-cloud && \
        terraform apply -target module.azure.null_resource.ssl_ssh_cloud_gen /cncf/cross-cloud && \
        terraform apply -target module.azure.module.dns.null_resource.dns_gen /cncf/cross-cloud && \
        terraform apply -target module.packet.null_resource.ssl_ssh_gen /cncf/cross-cloud && \
        terraform apply -target module.packet.module.etcd.null_resource.discovery_gen /cncf/cross-cloud && \
        time terraform apply /cncf/cross-cloud && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
    # terraform apply -target module.azure.azurerm_resource_group.cncf /cncf/cross-cloud && \
elif [ "$1" = "cross-cloud-destroy" ] ; then
    time terraform destroy -force /cncf/cross-cloud
fi
