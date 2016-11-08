#!/bin/bash

region='us-west-2'
productCode='aw0evgkw8e5c1q413zgy5pjce'

AMI=$(aws --region $region ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=$productCode --query 'Images | [-1] | ImageId' --out text)

echo $AMI

# This is a convenience script to grab the latest CentOS7 AMI id.
# A soon to be released evrsion of Packer has a 'dynamic source AMI' feature
# so once can specifiy the latest image right in the packer template.

# Otherwise the output of this script would have to be injected into the packer template.
