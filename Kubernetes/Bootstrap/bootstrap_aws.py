#!/usr/bin/env python

import ipdb
import time
import sys

import argparse
import logging
import json

import boto3
import botocore


def humanize(resp):
  if resp:
    status = resp['ResponseMetadata']['HTTPStatusCode'] 
    return 'OK' if status == 200 else 'status'
  return ''

def execute(actions):

  for action in actions:
    try:
      client, method, args = action
      if method == 'create_launch_configuration':
        print 'wait some more..'
        time.sleep(4) # AWS API bug, remove in future
      result = getattr(client, method)(**args)
      print "{}... {}".format(method, humanize(result))
  
    except botocore.exceptions.ClientError as e:

      Errors = ['InvalidKeyPair.Duplicate','InvalidGroup.Duplicate','InvalidPermission.Duplicate','EntityAlreadyExists','AlreadyExists', \
                'InvalidGroup.NotFound','NoSuchEntity','ValidationError','LimitExceeded','DryRunOperation']

      if e.response['Error']['Code'] in Errors:
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
  parser.add_argument('-I', '--ImageId', default='ami-1cb67a7c')
  parser.add_argument('-V', '--vpc', default='')
  parser.add_argument('-r', '--region', default='us-west-2')
  parser.add_argument('-c', '--create', action='store_true', dest='creation')
  parser.add_argument('-d', '--delete', action='store_false', dest='creation')
  parser.add_argument('-v', '--verbose', action='count', default=0)
  parser.set_defaults(creation=True)
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
  bootstrap = destroy = []

  if cli.creation:

    IPE = IAM.get_waiter('instance_profile_exists')
    IPE.config.delay = 1 # AWS API consistency bug, unreliable
 
    bootstrap = [
                 (EC2,'create_key_pair', {'KeyName': cli.KeyName, 'DryRun': False}),
                 (IAM,'create_instance_profile', {'InstanceProfileName': cli.InstanceProfile}),
                 (IPE,'wait', {'InstanceProfileName': cli.InstanceProfile}),
                 (IAM,'create_role', {'RoleName': cli.RoleName, 'AssumeRolePolicyDocument': json.dumps(TrustedPolicy)}),
                 (IAM,'add_role_to_instance_profile', {'RoleName': cli.RoleName, 'InstanceProfileName': cli.InstanceProfile})
                ]

    if 'k-minions' in cli.SecurityGroups:
      bootstrap.extend([(EC2, 'create_security_group', {'GroupName':'k-minions', 'Description':'k-minions', 'VpcId':cli.vpc }),
                        (EC2, 'authorize_security_group_ingress', {'GroupName': 'k-minions', 'IpProtocol': '-1',  \
                                                                   'CidrIp':'172.0.0.0/8', 'FromPort':-1, 'ToPort':-1 }),
                        (EC2, 'authorize_security_group_ingress', {'GroupName': 'k-minions', 'IpProtocol': 'tcp', \
                                                                   'CidrIp':'0.0.0.0/0', 'FromPort':22, 'ToPort':22 })])
  
    bootstrap.extend([(ASG, 'create_launch_configuration', {'LaunchConfigurationName': cli.LaunchConfiguration,
                                                            'ImageId': cli.ImageId,
                                                            'KeyName': cli.KeyName,
                                                            'SecurityGroups': cli.SecurityGroups,
                                                            'InstanceType': cli.InstanceType,
                                                            'InstanceMonitoring': {'Enabled': True},
                                                            'IamInstanceProfile': cli.InstanceProfile
                                                           }),
                      (ASG, 'create_auto_scaling_group',   {'AutoScalingGroupName':cli.AsgName,
        						    'LaunchConfigurationName':cli.LaunchConfiguration,
   						            'MinSize': 0,
      						            'MaxSize': 0,
  						            'DesiredCapacity': 0,
  						            'DefaultCooldown': 300,
  						            'AvailabilityZones': AvailabilityZones,
  						            'NewInstancesProtectedFromScaleIn': True 
                                                           })])

  if not cli.creation:

    destroy = [(ASG,'delete_auto_scaling_group', {'AutoScalingGroupName': cli.AsgName, 'ForceDelete': True}),
               (ASG,'delete_launch_configuration', {'LaunchConfigurationName': cli.LaunchConfiguration }),
               (IAM, 'remove_role_from_instance_profile', {'RoleName': 'k-minion', 'InstanceProfileName': 'k-minion'}),
               (IAM, 'delete_role', {'RoleName': 'k-minion'}),
               (IAM, 'delete_instance_profile', {'InstanceProfileName': 'k-minion'})]

    if 'k-minions' in cli.SecurityGroups:
      destroy.extend([(EC2, 'delete_security_group', {'GroupName': 'k-minions', 'DryRun': False})])

execute(bootstrap or destroy)
print 'Done.'
