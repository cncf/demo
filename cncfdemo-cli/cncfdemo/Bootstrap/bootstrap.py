#!/usr/bin/env python

import os
import time
import sys

import json

import boto3
import botocore

import click
import requests


def delete_record_sets(kind, clustername, **kwargs):
  r53 = boto3.client('route53')
  HostedZones = r53.list_hosted_zones_by_name(DNSName='k8s')['HostedZones']
  HostedZoneId = HostedZones.pop()['Id'].split('/')[2] if HostedZones else None
  if not HostedZoneId:
    return

  Name = '{Role}.{KubernetesCluster}.k8s.'.format(Role=kind.split('-')[1]+'s', KubernetesCluster=clustername)
  RRS = [rrs for rrs in r53.list_resource_record_sets(HostedZoneId=HostedZoneId)['ResourceRecordSets'] if rrs['Name'] == Name]
  if not RRS:
    return

  ResourceRecords = RRS[0]['ResourceRecords']

  r = r53.change_resource_record_sets(
       HostedZoneId=HostedZoneId,
       ChangeBatch={
           'Changes': [
               {   'Action': 'DELETE',
                   'ResourceRecordSet': {
                       'Name': Name,
                       'Type':'A',
                       'TTL': 5,
                       'ResourceRecords': ResourceRecords
                   }
               },
           ]
       }
    )

def get_ips(group, region):

  EC2 = boto3.client('ec2', region_name=region)

  InstanceIds = [i['InstanceId'] for i in group['Instances']] 
  Instances = EC2.describe_instances(InstanceIds=InstanceIds)
  try:
    PublicIpAddresses = [i['Instances'][0]['PublicIpAddress'] for i in Instances['Reservations']]
  except:
    PublicIpAddresses = []
  return PublicIpAddresses 

def humanize(resp):
  status = (resp or {}).get('ResponseMetadata', {}).get('HTTPStatusCode', '')
  return 'OK' if status == 200 else status

def execute(actions):

  for action in actions or []:
    client, method, args = action

    try:

      if method == 'create_launch_configuration':
        click.echo('waiting some more..')
        time.sleep(10) # AWS API bug, remove in future

      result = getattr(client, method)(**args)
      click.echo("{}... {}".format(method, humanize(result)))
  
    except botocore.exceptions.ClientError as e:

      Errors = ['InvalidKeyPair.Duplicate','InvalidGroup.Duplicate','InvalidPermission.Duplicate','EntityAlreadyExists','AlreadyExists', \
                'InvalidGroup.NotFound','NoSuchEntity','ValidationError','LimitExceeded','DependencyViolation', 'DryRunOperation']

      if e.response['Error']['Code'] in Errors:
        click.echo(e.response['Error']['Message'])
      else:
  	click.echo("Unexpected error: {}".format(e))
        sys.exit("Aborting..")

def create(ctx, clustername, keyname, imageid, instancetype, securitygroups, vpc, \
           rolename, policyarn, asgname, launchconfiguration, instanceprofile, scale, kind, userdata, **kwargs):
           
  TrustedPolicy = ctx.obj['TrustedPolicy'] 

  ASG = ctx.obj['ASG']
  exists = ASG.describe_auto_scaling_groups(AutoScalingGroupNames=[asgname]).get('AutoScalingGroups')

  if exists:
    print scale
    click.echo('{} exists'.format(asgname))
    return []
  else:
    IAM = ctx.obj['IAM']
    EC2 = ctx.obj['EC2']
  
    IPE = IAM.get_waiter('instance_profile_exists')
    IPE.config.delay = 2 # AWS API consistency bug, unreliable
  
    bootstrap = [(EC2, 'create_key_pair', {'KeyName': keyname, 'DryRun': False}),
                 (IAM, 'create_instance_profile', {'InstanceProfileName': instanceprofile}),
                 (IPE, 'wait', {'InstanceProfileName': instanceprofile}),
                 (IAM, 'create_role', {'RoleName': rolename, 'AssumeRolePolicyDocument': json.dumps(TrustedPolicy)}),
                 (IAM, 'add_role_to_instance_profile', {'RoleName': rolename, 'InstanceProfileName': instanceprofile}),
                 (IAM, 'attach_role_policy', {'RoleName': rolename, 'PolicyArn': policyarn})]
  
    #if 'cncfdemo' in securitygroups:
    #  bootstrap.extend([(EC2, 'create_security_group', {'GroupName':'cncfdemo', 'Description':'k8s minions', 'VpcId':vpc }),
    #                    #(EC2, 'authorize_security_group_ingress', {'GroupName': 'cncfdemo', 'IpProtocol': '-1',  \
    #                                                               #'CidrIp':'172.0.0.0/8', 'FromPort':-1, 'ToPort':-1 }),
    #                    (EC2, 'authorize_security_group_ingress', {'GroupName': 'cncfdemo', 'IpProtocol': 'tcp', \
    #                                                               'CidrIp':'0.0.0.0/0', 'FromPort':22, 'ToPort':22 })])

    #  if ctx.obj.get('whitelist_ip'):
    #    whitelist_ip = ctx.obj['whitelist_ip']
    #    click.echo('whitelisting IP {}...'.format(whitelist_ip))
    #    bootstrap.extend([(EC2, 'authorize_security_group_ingress', {'GroupName': 'cncfdemo', 'IpProtocol': 'tcp', \
    #                                                                 'CidrIp': whitelist_ip, 'FromPort':8080, 'ToPort':8080 })])
  
    AvailabilityZones = [z['ZoneName'] for z in EC2.describe_availability_zones()['AvailabilityZones']]
    bootstrap.extend([(ASG, 'create_launch_configuration', {'LaunchConfigurationName': launchconfiguration,
                                                            'ImageId': imageid,
                                                            'KeyName': keyname,
                                                            'SecurityGroups': ['sg-46382220'],
                                                            'AssociatePublicIpAddress': True,
                                                            'UserData': userdata,
                                                            'InstanceType': instancetype,
                                                            'InstanceMonitoring': {'Enabled': True},
                                                            'IamInstanceProfile': instanceprofile
                                                           }),
                      (ASG, 'create_auto_scaling_group',   {'AutoScalingGroupName':asgname,
        						    'LaunchConfigurationName':launchconfiguration,
   						            'MinSize': scale,
      						            'MaxSize': scale,
  						            'DesiredCapacity': scale,
  						            'DefaultCooldown': 300,
  						            'VPCZoneIdentifier': 'subnet-fae55aa2',
  						            #'AvailabilityZones': AvailabilityZones,
  						            'NewInstancesProtectedFromScaleIn': False, 
        						    'Tags':[
        							{
        							    'ResourceId': asgname,
        							    'ResourceType': 'auto-scaling-group',
        							    'Key': 'KubernetesCluster',
        							    'Value': clustername,
        							    'PropagateAtLaunch': True
        							},
                                                                {
        							    'ResourceId': asgname,
        							    'ResourceType': 'auto-scaling-group',
        							    'Key': 'Name',
        							    'Value': kind,
        							    'PropagateAtLaunch': True
        							},
                                                                {
        							    'ResourceId': asgname,
        							    'ResourceType': 'auto-scaling-group',
        							    'Key': 'Role',
        							    'Value': kind,
        							    'PropagateAtLaunch': True
        							}
        						           ]
                                                           })])
  
  
    return bootstrap


def remove(ctx, policyarn, asgname, launchconfiguration, instanceprofile, securitygroups, rolename, **kwargs):

  ASG = ctx.obj['ASG']
  IAM = ctx.obj['IAM']
  EC2 = ctx.obj['EC2']

  destroy = [(ASG, 'delete_auto_scaling_group', {'AutoScalingGroupName': asgname, 'ForceDelete': True}),
             (ASG, 'delete_launch_configuration', {'LaunchConfigurationName': launchconfiguration}),
             (IAM, 'remove_role_from_instance_profile', {'RoleName': rolename, 'InstanceProfileName': instanceprofile}),
             (IAM, 'detach_role_policy', {'RoleName': rolename, 'PolicyArn': policyarn}),
             (IAM, 'delete_role', {'RoleName': rolename}),
             (IAM, 'delete_instance_profile', {'InstanceProfileName': instanceprofile})]

  #if 'cncfdemo' in securitygroups:
  #  destroy.extend([(EC2, 'delete_security_group', {'GroupName': 'cncfdemo', 'DryRun': False})])

  return destroy

def _default_plan(destroy, **kwargs):

  if destroy:
    plan = remove(**kwargs) 
    delete_record_sets(**kwargs)

  else:
    plan = create(**kwargs) 

    ASG, asgname, scale = kwargs['ctx'].obj['ASG'], kwargs['asgname'], kwargs['scale']
    plan.extend([(ASG, 'update_auto_scaling_group', {'AutoScalingGroupName': asgname, 'MaxSize': scale, 'DesiredCapacity': scale, 'MinSize': scale})]) 

  return plan

_default_names = ('k-masters', 'k-minions')
_common_options = [
  click.option('--ClusterName', default='cncfdemo'),
  click.option('-v', '--verbose', count=True),
  click.option('--dry-run', is_flag=True),
  click.option('--destroy', is_flag=True, default=False),
]

def common_options(func):
    for option in sorted(_common_options):
        func = option(func)
    return func

@click.group()
def cli():
  pass

@click.group()
@common_options

@click.option('--region', default='us-west-2')
@click.option('--scale', default=1)

@click.option('--KeyName', default='cncf-aws')
@click.option('--ImageId', default='ami-9116c7f1')
@click.option('--SecurityGroups', default=['cncfdemo'], multiple=True)
@click.option('--vpc', default='vpc-fbd3e39f')

@click.pass_context
def aws(ctx, region, scale, \
        clustername, keyname, imageid, securitygroups, vpc, \
        destroy, dry_run, verbose):
       
  ctx.obj = ctx.obj or {}
  ctx.obj['whitelist_ip'] = requests.get("http://api.ipify.org").text + '/32'

  ctx.obj['TrustedPolicy'] = {
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

  default = { 'ctx': ctx, 
              'clustername': clustername, 
              'keyname': keyname, 
              'imageid': imageid, 
              'securitygroups': securitygroups, 
              'vpc': vpc }

  ctx.obj['default'] = default
  ctx.obj['ASG'] = boto3.client('autoscaling', region_name=region)
  ctx.obj['IAM'] = boto3.client('iam', region_name=region)
  ctx.obj['EC2'] = boto3.client('ec2', region_name=region)

  ctx.obj['userdata'] = '\n'.join(('#!/bin/bash', 
                                   'set -ex',
                                   '\n'
                                   'HOSTNAME_OVERRIDE=$(curl -s http://169.254.169.254/2007-01-19/meta-data/local-hostname | cut -d" " -f1)', 
                                   '\n'
                                   'cat << EOF > /etc/sysconfig/{}', 
                                   'CLOUD_PROVIDER=--cloud-provider=aws', 
                                   'CLUSTER_NAME={}',
                                   'KUBELET_HOSTNAME=--hostname-override=$HOSTNAME_OVERRIDE',
                                   'EOF'
                                   ''))

@click.command()
@common_options
@click.option('--scale', default=1)
@click.option('--InstanceType', default='m3.medium')
@click.option('--AsgName', default=_default_names[0])
@click.option('--RoleName', default=_default_names[0])
@click.option('--LaunchConfiguration', default=_default_names[0])
@click.option('--InstanceProfile', default=_default_names[0])
@click.option('--PolicyArn', default='arn:aws:iam::aws:policy/AmazonEC2FullAccess')
@click.pass_context
def masters(ctx, clustername, destroy, scale, policyarn, instancetype, \
            asgname, rolename, launchconfiguration, instanceprofile, \
            dry_run, verbose):

  config = ctx.obj['default'].copy()
  config.update(ctx.params)
  config.update({'scale': 1, 'kind': 'kubernetes-master' })
  config.update({'userdata': ctx.obj['userdata'].format('kubernetes-masters', clustername)})

  plan = _default_plan(**config)

  if verbose:
    click.echo(plan)

  if not dry_run:
    execute(plan)


@click.command()
@common_options
@click.option('--scale', default=1)
@click.option('--InstanceType', default='t2.micro')
@click.option('--AsgName', default=_default_names[1])
@click.option('--RoleName', default=_default_names[1])
@click.option('--LaunchConfiguration', default=_default_names[1])
@click.option('--InstanceProfile', default=_default_names[1])
@click.option('--PolicyArn', default='arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess')
@click.pass_context
def minions(ctx, clustername, destroy, scale, policyarn, instancetype, \
            asgname, rolename, launchconfiguration, instanceprofile, \
            dry_run, verbose):

  config = ctx.obj['default'].copy()
  config.update(ctx.params)
  config.update({'kind': 'kubernetes-minion'})
  config.update({'userdata': ctx.obj['userdata'].format('kubernetes-minions', clustername)})

  plan = _default_plan(**config)

  if verbose:
    click.echo(plan)

  if not dry_run:
    execute(plan)


@click.command()
@common_options
@click.option('--scale', default=1)
@click.option('--InstanceType', default='t2.micro')
@click.pass_context
def cluster(ctx, clustername, scale, instancetype, destroy, dry_run, verbose):

  for name in _default_names:

    click.echo('\n'.join(('', name, '='*70)))
    config = ctx.obj['default'].copy()
    config.update({'scale': scale, 'kind': 'kubernetes-minion', 'destroy': destroy})
    config.update({'userdata': ctx.obj['userdata'].format('kubernetes-minions', clustername)})
    config.update({'instancetype': instancetype,
                   'asgname': name,
                   'rolename': name,
                   'launchconfiguration': name,
                   'instanceprofile': name,
                   'policyarn': 'arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess'})

    if name == _default_names[0]:
      config.update({'scale': 1, 'kind': 'kubernetes-master', 'instancetype': 'm3.medium', 'policyarn': 'arn:aws:iam::aws:policy/AmazonEC2FullAccess' })
      config.update({'userdata': ctx.obj['userdata'].format('kubernetes-masters', clustername)})
 
    plan = _default_plan(**config)

    if verbose:
      click.echo(plan)

    if not dry_run:
      execute(plan)


@click.command()
@click.pass_context
@click.option('--AsgName', default=_default_names)
@click.option('--public', is_flag=True)
@click.option('--private', is_flag=True)
def status(ctx, asgname, public, private):

  ASG = ctx.obj['ASG']
  EC2 = ctx.obj['EC2']

  groups = ASG.describe_auto_scaling_groups(AutoScalingGroupNames=(list(asgname))).get('AutoScalingGroups')
  for group in groups:
    click.echo('{}: {}/{}'.format(group['AutoScalingGroupName'], len(group['Instances']), group['DesiredCapacity']))

    if (public or private):
      InstanceIds = [i['InstanceId'] for i in group['Instances']] 
      Instances = EC2.describe_instances(InstanceIds=InstanceIds)

    if private:
      PrivateIpAddresses = [i['PrivateIpAddress'] for i in Instances['Reservations'][0]['Instances']]
      click.echo('PrivateIps: {}'.format(PrivateIpAddresses))

    if public:
      PublicIpAddresses = [i['PublicIpAddress'] for i in Instances['Reservations'][0]['Instances']]
      click.echo('PublicIps: {}'.format(PublicIpAddresses))

  if not groups:
    click.echo('No minions or masters exist')


@click.command()
@click.pass_context
@click.option('--AsgName', default=_default_names[0])
def cluster_info(ctx, asgname):

  ASG = ctx.obj['ASG']
  EC2 = ctx.obj['EC2']

  groups = ASG.describe_auto_scaling_groups(AutoScalingGroupNames=([asgname])).get('AutoScalingGroups')
  for group in groups:
    InstanceIds = [i['InstanceId'] for i in group['Instances']] 
    Instances = EC2.describe_instances(InstanceIds=InstanceIds)
    PublicIpAddresses = [i['Instances'][0]['PublicIpAddress'] for i in Instances['Reservations']]
    click.echo('Kubernetes master is running at http://{}:8080'.format(PublicIpAddresses[0]))


cli.add_command(aws)
aws.add_command(masters)
aws.add_command(minions)
aws.add_command(status)
aws.add_command(cluster)
aws.add_command(cluster_info)


if __name__ == '__main__':
  cli()
  # TODO: add progress bar
  #import ipdb; ipdb.set_trace()
