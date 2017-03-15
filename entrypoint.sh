#!/bin/bash
#
# RUN ENTRYPOINT.

set -e
# AWS_CONFIG_FILE
# AWS_DEFAULT_OUTPUT
# AWS_SHARED_CREDENTIALS_FILE
# Write aws Creds if they don't exist
if [ -f /cncf/data/awsconfig  ] ; then
    echo "Creds Already Exist Don't Gen"
else
    cat <<EOF >data/awsconfig
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
elif [ "$1" = "deploy-aws" ] ; then
    cd /aws && terraform get && terrafrom apply
elif [ "$1" = "destroy-aws" ] ; then
    cd /aws && terraform destroy -force
fi
