#!/bin/bash
#
# RUN ENTRYPOINT.

set -e
RED='\033[0;31m'
NC='\033[0m' # No Color

function write_aws_config {
    # Only if AWS_*_vars exist
    # AWS_CONFIG_FILE
    # AWS_DEFAULT_OUTPUT
    # AWS_SHARED_CREDENTIALS_FILE
    # Write aws Creds if they don't exist
    if [ -f /cncf/data/awsconfig  ] ; then
        echo "Creds Already Exist Don't Gen"
    else
    cat <<EOF >/cncf/data/awsconfig
[default]
output = ${AWS_DEFAULT_OUTPUT:-json}
region = ${AWS_DEFAULT_REGION:-ap-southeast-2}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
    fi
}

export TF_VAR_name="$2"

# Run CMD
if [ "$1" = "aws-deploy" ] ; then
    write_aws_config
    terraform get /deploy/aws && \
        terraform apply -target null_resource.ssl_gen /deploy/aws && \
        time terraform apply /deploy/aws && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/ \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/kubeconfig \n\n'${NC}
elif [ "$1" = "aws-destroy" ] ; then
    write_aws_config
    time terraform destroy -force /deploy/aws
elif [ "$1" = "azure-deploy" ] ; then
    terraform get /azure && \
        terraform apply -target null_resource.sshkey_gen /deploy/azure && \
        terraform apply -target null_resource.ssl_gen /deploy/azure && \
        terraform apply -target null_resource.cloud_gen /deploy/azure && \
        terraform apply -target module.dns.null_resource.dns_gen /delpoy/azure && \
        terraform apply -target module.etcd.azurerm_network_interface.cncf /delpoy/azure && \
        time terraform apply /deploy/azure && \
        printf "${RED}\n#Commands to Configue Kubectl \n\n" && \
        printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/${name} \n\n' && \
        printf 'export KUBECONFIG=$(pwd)/data/${name}/kubeconfig \n\n'${NC}
elif [ "$1" = "destroy" ] ; then
    time terraform destroy -force /delpoy/azure
fi
