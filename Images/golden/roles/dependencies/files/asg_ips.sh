#!/bin/bash

[[ $(dmidecode -s bios-version) =~ "amazon" ]] || (echo "Must run in AWS, Aborting" && exit 1)

REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

ASG=$(aws ec2 describe-instances --region $REGION --instance-ids $INSTANCEID  --query 'Reservations[].Instances[].Tags[?Key==`aws:autoscaling:groupName`].Value[]' --output text)

aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=$ASG" --region $REGION --query 'Reservations[*].Instances[*].[NetworkInterfaces[].PrivateIpAddress]' --output text | tr '\n' ' '
