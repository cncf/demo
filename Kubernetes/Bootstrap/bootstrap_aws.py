#!/usr/bin/env python

import sys

import argparse
import logging
import json

import boto3
import botocore

def execute(actions):

  for action in actions:
    try:
      client, method, args = action
      result = getattr(client, method)(**args)
  
    except botocore.exceptions.ClientError as e:
      if e.response['Error']['Code'] == 'EntityAlreadyExists':
          log.info(e.response['Error']['Message'])
      elif e.response['Error']['Code'] == 'AlreadyExists':
          log.info(e.response['Error']['Message'])
      elif e.response['Error']['Code'] == 'LimitExceeded':
          log.info(e.response['Error']['Message'])
      elif e.response['Error']['Code'] == 'InvalidGroup.Duplicate':
          log.info(e.response['Error']['Message'])
      elif e.response['Error']['Code'] == 'InvalidPermission.Duplicate':
          log.info(e.response['Error']['Message'])
      else:
  	log.error("Unexpected error: {}".format(e))
        sys.exit("Aborting..")

if __name__ == "__main__":

  TrustedPolicy = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }

  parser = argparse.ArgumentParser()
  parser.add_argument('-R', '--RoleName', default='k-minion')
  parser.add_argument('-A', '--AsgName', default='k-minion')
  parser.add_argument('-C', '--LaunchConfiguration', default='k-minion') 
  parser.add_argument('-P', '--InstanceProfile', default='k-minion') 
  parser.add_argument('-K', '--KeyName', default='cncf-aws')
  parser.add_argument('-T', '--InstanceType', default='t2.micro')
  parser.add_argument('-S', '--SecurityGroups', default=['k-minions'], action='append')
  parser.add_argument('-I', '--ImageId', default='ami-b89e52d8')
  parser.add_argument('-V', '--vpc', default='')
  parser.add_argument('-r', '--region', default='us-west-2')
  parser.add_argument('-c', '--create', action='store_true', default=True)
  parser.add_argument('-v', '--verbose', action='count', default=0)
  cli = parser.parse_args()
  
  log = logging.getLogger(__name__)
  log_handler = logging.StreamHandler(sys.stdout)
  level = 40 - min(cli.verbose*10,30)
  log_handler.setLevel(level)
  log.addHandler(log_handler)
  log.setLevel(level)

  log.info(cli)

  ASG = boto3.client('autoscaling',region_name=cli.region)
  IAM = boto3.client('iam',region_name=cli.region)
  EC2 = boto3.client('ec2',region_name=cli.region)

  AvailabilityZones = [z['ZoneName'] for z in EC2.describe_availability_zones()['AvailabilityZones']]

  bootstrap = []
  if cli.create:

    try:
      keyResponse = EC2.create_key_pair(KeyName=cli.KeyName, DryRun=False)
    except botocore.exceptions.ClientError as e:
      if e.response['Error']['Code'] == 'InvalidKeyPair.Duplicate':
        log.info(e.response['Error']['Message'])
	keyResponse = 'Not displaying the key.'
      elif e.response['Error']['Code'] == 'DryRunOperation':
        log.info(e.response['Error']['Message'])
      else:
        log.error(e.response)
        sys.exit("Aborting..")

      log.info(keyResponse)  # TODO: Not secure to print to stdout, need to log to file or something

    bootstrap.extend([(IAM,'create_instance_profile', {'InstanceProfileName': cli.InstanceProfile}),
                      (IAM,'create_role', {'RoleName': cli.RoleName, 'AssumeRolePolicyDocument': json.dumps(TrustedPolicy)}),
                      (IAM,'add_role_to_instance_profile', {'RoleName': cli.RoleName, 'InstanceProfileName': cli.InstanceProfile})])

  if 'k-minions' in cli.SecurityGroups:
    bootstrap.extend([(EC2, 'create_security_group', {'GroupName':'k-minions', 'Description':'k-minions', 'VpcId':cli.vpc }),
                     ((EC2, 'authorize_security_group_ingress', {'GroupName': 'k-minions', 'IpProtocol': '-1', \
                                                                 'CidrIp':'172.0.0.0/8', 'FromPort':-1, 'ToPort':-1 })),
                     ((EC2, 'authorize_security_group_ingress', {'GroupName': 'k-minions', 'IpProtocol': 'tcp', \
                                                                 'CidrIp':'0.0.0.0/0', 'FromPort':22, 'ToPort':22 }))])


  bootstrap.extend([(ASG, 'create_launch_configuration', {'LaunchConfigurationName': cli.LaunchConfiguration,
                                                          'ImageId': cli.ImageId,
                                                          'KeyName': cli.KeyName,
                                                          'SecurityGroups': cli.SecurityGroups,
                                                          'InstanceType': cli.InstanceType,
                                                          'InstanceMonitoring': {'Enabled': True},
                                                          'IamInstanceProfile': cli.InstanceProfile
                                                         }),
                    (ASG,'create_auto_scaling_group', {'AutoScalingGroupName':cli.AsgName,
						       'LaunchConfigurationName':cli.LaunchConfiguration,
						       'MinSize': 0,
						       'MaxSize': 0,
						       'DesiredCapacity': 0,
						       'DefaultCooldown': 300,
						       'AvailabilityZones': AvailabilityZones,
						       'NewInstancesProtectedFromScaleIn': True 
                                                      })])
						   


  execute(bootstrap)
