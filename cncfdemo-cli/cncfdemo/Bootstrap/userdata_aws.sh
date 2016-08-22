#!/bin/bash -x

yum update -y
yum install -y -q unzip

curl -s https://s3.amazonaws.com/aws-cli/awscli-bundle.zip --output /tmp/awscli-bundle.zip && unzip -qq /tmp/awscli-bundle.zip -d /tmp && \
rm /tmp/awscli-bundle.zip && yum remove -y -q unzip

/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

ln -s /usr/local/bin/aws /usr/bin/aws
rm -rf /tmp/awscli-bundle

INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

ROLE=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCEID" --query 'Tags[?Key==`Role`].Value[]' --output text)

touch /etc/sysconfig/$ROLE
