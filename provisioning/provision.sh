#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e
RED='\033[0;31m'
NC='\033[0m' # No Color

export TF_VAR_name="$2"
export TF_VAR_internal_tld=${TF_VAR_name}.cncf.demo
export TF_VAR_data_dir=${DIR}/data/${TF_VAR_name}
# tfstate, sslcerts, and ssh keys are currently stored in TF_VAR_data_dir
mkdir -p $TF_VAR_data_dir
cd $TF_VAR_data_dir
 
# Run CMD
if [ "$1" = "aws-deploy" ] ; then
    terraform get ${DIR}/aws && \
        terraform apply -target null_resource.ssl_gen ${DIR}/aws && \
        time terraform apply ${DIR}/aws && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/ \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/kubeconfig \n\n'${NC}
elif [ "$1" = "aws-destroy" ] ; then
    time terraform destroy -force ${DIR}/aws
elif [ "$1" = "azure-deploy" ] ; then
    # There are some dependency issues around cert,sshkey,k8s_cloud_config, and dns
    # since they use files on disk that are created on the fly
    # should probably move these to data resources
    terraform get ${DIR}/azure && \
        terraform apply -target null_resource.ssl_ssh_cloud_gen ${DIR}/cross-cloud && \
        terraform apply -target null_resource.dns_gen ${DIR}/azure && \
        time terraform apply ${DIR}/azure && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "azure-destroy" ] ; then
    time terraform destroy -force ${DIR}/azure
elif [ "$1" = "packet-deploy" ] ; then
    terraform get ${DIR}/packet && \
        terraform apply -target module.etcd.null_resource.discovery_gen ${DIR}/packet && \
        terraform apply -target null_resource.ssl_ssh_gen ${DIR}/packet && \
        time terraform apply ${DIR}/packet && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "packet-destroy" ] ; then
    time terraform destroy -force ${DIR}/packet
elif [ "$1" = "gce-deploy" ] ; then
    terraform get ${DIR}/gce && \
        terraform apply -target module.etcd.null_resource.discovery_gen ${DIR}/gce && \
        terraform apply -target null_resource.ssl_gen ${DIR}/gce && \
        time terraform apply ${DIR}/gce && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "gce-destroy" ] ; then
    time terraform destroy -force ${DIR}/gce
eelif [ "$1" = "gke-deploy" ] ; then
    terraform get ${DIR}/gke && \
        time terraform apply ${DIR}/gke
elif [ "$1" = "gke-destroy" ] ; then
    time terraform destroy -force ${DIR}/gke
elif [ "$1" = "cross-cloud-deploy" ] ; then
    terraform get ${DIR}/cross-cloud && \
        terraform apply -target module.aws.null_resource.ssl_gen ${DIR}/cross-cloud && \
        terraform apply -target module.gce.null_resource.ssl_gen ${DIR}/cross-cloud && \
        terraform apply -target module.gce.module.etcd.null_resource.discovery_gen ${DIR}/cross-cloud && \
        terraform apply -target module.azure.null_resource.ssl_ssh_cloud_gen ${DIR}/cross-cloud && \
        terraform apply -target module.azure.module.dns.null_resource.dns_gen ${DIR}/cross-cloud && \
        terraform apply -target module.packet.null_resource.ssl_ssh_gen ${DIR}/cross-cloud && \
        terraform apply -target module.packet.module.etcd.null_resource.discovery_gen ${DIR}/cross-cloud && \
        time terraform apply ${DIR}/cross-cloud && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
    # terraform apply -target module.azure.azurerm_resource_group.cncf ${DIR}/cross-cloud && \
elif [ "$1" = "cross-cloud-destroy" ] ; then
    time terraform destroy -force ${DIR}/cross-cloud
fi
