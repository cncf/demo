#!/bin/bash
#
# RUN ENTRYPOINT.

set -e
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Run CMD
if [ "$@" = "" ] ; then
    echo $@ not handled yet
elif [ "$1" = "aws" ] ; then
    terraform get /aws && time terraform apply /aws && printf "${RED}\n#Commands to Configue Kubectl \n\n" && printf 'sudo chown -R $(whoami):$(whoami) $(pwd)/data/ \n\n' && printf 'export KUBECONFIG=$(pwd)/data/kubeconfig \n\n'${NC}
elif [ "$1" = "aws-destroy" ] ; then
    time terraform destroy -force /aws
fi
