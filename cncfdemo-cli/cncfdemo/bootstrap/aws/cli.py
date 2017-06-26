#!/usr/bin/env python

import os
import time
import sys

import json
import collections
from functools import partial

import boto3
import botocore

import click
import requests

from utils import *
from dateutil import parser


def latest_ami(list_of_images=None):
  latest = None

  if not list_of_images:
    client = boto3.client('ec2', region_name='us-west-2')
    filters = [{ 'Name': 'name', 'Values': ['cncfgold*'] }]
    images = client.describe_images(Owners=['750548967590'], Filters=filters)
    list_of_images = images if type(images) == list else [images]

  for image in list_of_images:
      if not latest:
          latest = image
          continue

      if parser.parse(image['CreationDate']) > parser.parse(latest['CreationDate']):
          latest = image

  latest = latest if type(latest) == list else [latest]

  print "latest ami: {}".format(latest[0]['Images'][0]['ImageId'])
  return latest[0]['Images'][0]['ImageId']


def get_plan(name, dir=os.path.dirname(os.path.realpath(__file__))+'/execution_plans'):
  with open('{}/{}'.format(dir,name), 'r') as f:
    return f.read()


def create_vpc(ctx, clustername, region, cidr):

  filters = [{'Name':'tag:KubernetesCluster', 'Values':[clustername]}]
  ec2resource = ctx.obj['ec2resource']
  if any(ec2resource.vpcs.filter(Filters=filters)):
    click.echo('VPC {} already exists, there can only be one!'.format(clustername))
    return 'Done'

  Tags = ctx.obj['Tags']
  DhcpConfiguration = DhcpConfigurations(region)
  context = { 'ec2': ec2resource,
              '_get': lambda x: pluck(context, x) or (partial(context.get), x)
            }

  IpWhitelist = [{ 'IpProtocol': 'tcp', 'FromPort':8080, 'ToPort':8080, 'IpRanges': [{'CidrIp':'0.0.0.0/0'}] }]
  IpPermissions = [
                   { 'IpProtocol': 'tcp', 'FromPort':22, 'ToPort':22, 'IpRanges': [{'CidrIp':'0.0.0.0/0'}] },
                   { 'IpProtocol': '-1', 'UserIdGroupPairs': [{ 'GroupId': context['_get']('sg_masters.group_id') }] },
                   { 'IpProtocol': '-1', 'UserIdGroupPairs': [{ 'GroupId': context['_get']('sg_minions.group_id') }] }
                  ]

  vpc_plan = eval(get_plan('vpc'))
  result = execute2(context, vpc_plan)
  return result['vpc'].id


_default_names = ('k-masters', 'k-minions')
_common_options = [
  click.option('--ClusterName', default='cncfdemo'),
  click.option('--ClusterToken', default='cncfci.geneisbatman4242'),
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
@click.option('--ImageId', default=latest_ami()) # ami-ff0d0586
@click.option('--SecurityGroups', default=['cncfdemo'], multiple=True)
@click.pass_context
def aws(ctx, region, scale, \
        clustername, clustertoken, keyname, imageid, securitygroups, \
        destroy, dry_run, verbose):

  ctx.obj = ctx.obj or {}
  ctx.obj['whitelist_ip'] = requests.get("http://checkip.amazonaws.com/").text + '/32'

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

  region = 'us-west-2'
  ctx.obj['Tags'] = [{ 'Key': 'Name', 'Value': clustername }, { 'Key': 'KubernetesCluster', 'Value': clustername }]

  filters = [{'Name':'tag:KubernetesCluster', 'Values':[clustername]}]
  ec2resource = boto3.resource('ec2', region_name=region)

  exists = list(ec2resource.vpcs.filter(Filters=filters))
  vpc = exists[0].id if exists else ''

  default = { 'ctx': ctx,
              'clustername': clustername,
              'clustertoken': 'cncfci.geneisbatman4242',
              'keyname': keyname,
              'imageid': imageid,
              #'securitygroups': securitygroups,
              'vpc': vpc,
              'keyname': keyname,
              'TrustedPolicy': json.dumps(TrustedPolicy) }

  ctx.obj['default'] = default
  ctx.obj['AWS'] = boto3.Session(region_name=region)
  ctx.obj['ASG'] = boto3.client('autoscaling', region_name=region)
  ctx.obj['IAM'] = boto3.client('iam', region_name=region)
  ctx.obj['EC2'] = boto3.client('ec2', region_name=region)
  ctx.obj['r53'] = boto3.client('route53', region_name=region)
  ctx.obj['ec2resource'] = boto3.resource('ec2', region_name=region)

  ctx.obj['userdata'] = '\n'.join(('#!/bin/bash',
                                   'set -ex',
                                   '\n'
                                   'cat << EOF > /etc/{}',
                                   'CLUSTER_NAME={}',
                                   'TOKEN={}',
                                   'EOF'
                                   ''))

@click.command()
@common_options
@click.option('--scale', default=3)
@click.option('--InstanceType', default='m4.large')
@click.option('--region', default='us-west-2')
@click.option('--cidr', default='172.20.0.0/16')
@click.pass_context
def cluster(ctx, clustername, clustertoken, scale, instancetype, region, cidr, destroy, dry_run, verbose):

  if not ctx.obj['default']['vpc']:
    click.echo('no vpc found, creating..')
    ctx.obj['default']['vpc'] = create_vpc(ctx, clustername, region, cidr)
    click.echo('created vpc {}'.format(ctx.obj['default']['vpc']))

  if not destroy:

    r53 = ctx.obj['r53']
    HostedZones = r53.list_hosted_zones_by_name(DNSName='k8s')['HostedZones']
    HostedZoneId = HostedZones.pop()['Id'].split('/')[2] if HostedZones else None
    try:
      r53.associate_vpc_with_hosted_zone(HostedZoneId=HostedZoneId, VPC={'VPCRegion': region, 'VPCId': ctx.obj['default']['vpc'] })
    except botocore.exceptions.ClientError as e:
      click.echo(e)

  aws = ctx.obj['AWS']
  ec2resource = ctx.obj['ec2resource']
  filters = [{'Name':'tag:KubernetesCluster', 'Values':[clustername]}]

  for name in _default_names:

    click.echo('\n'.join(('', name, '='*70)))
    config = ctx.obj['default'].copy()
    config.update({'scale': scale, 'kind': 'kubernetes-minion', 'destroy': destroy})
    config.update({'userdata': ctx.obj['userdata'].format('kubernetes-minions', clustername, clustertoken)})
    config.update({'instancetype': instancetype,
                   'asgname': name,
                   'rolename': name,
                   'launchconfiguration': name,
                   'instanceprofile': name,
                   'VPCZoneIdentifier': ','.join([subnet.id for subnet in ec2resource.subnets.filter(Filters=filters)]),
                   'policyarn': 'arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess'})

    if name == _default_names[0]:
      config.update({'scale': 1, 'kind': 'kubernetes-master', 'instancetype': 'm3.medium', 'policyarn': 'arn:aws:iam::aws:policy/AmazonEC2FullAccess' })
      config.update({'userdata': ctx.obj['userdata'].format('kubernetes-masters', clustername, clustertoken)})

    config.update({'securitygroups': [sg.id for sg in ec2resource.security_groups.filter(Filters=[{'Name':'tag:Role', 'Values':[config['kind']]}])]})
    create_asg(config, aws)

  ASG = ctx.obj['ASG']
  EC2 = ctx.obj['EC2']

  click.echo('\n'.join(('', '='*70, '')))
  click.echo('Waiting for master to be provisioned by cloud provider..', nl=False)
  PublicIpAddresses = ok = []
  while not PublicIpAddresses:
    time.sleep(1)
    click.echo('.', nl=False)
    master = ASG.describe_auto_scaling_groups(AutoScalingGroupNames=['k-masters']).get('AutoScalingGroups')
    if master:
      InstanceIds = [i['InstanceId'] for i in master[0]['Instances']]
      if InstanceIds:
        Instances = EC2.describe_instances(InstanceIds=InstanceIds)
        PublicIpAddresses = [i.get('PublicIpAddress') for i in Instances['Reservations'][0]['Instances']]

  click.echo('\n'.join(('', 'Master IP: {}'.format(PublicIpAddresses[0]), '')))
  url = 'http://{host}:8080/apis/batch/v1/jobs/'.format(host=PublicIpAddresses[0])
  click.echo('Waiting for ClusterReady..', nl=False)
  while not ok:
    try:
      click.echo('.', nl=False)
      time.sleep(5)
      r = requests.get(url)
      resp = json.loads(r.content)
      start = [job['status'] for job in resp['items'] if job['metadata']['name'] == 'clusterstart']
      ok = (start[0]['succeeded'] == 1)
    except Exception:
      click.echo('.', nl=False)
      time.sleep(5)
      pass


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


def create_asg(config, aws):

  context = { 'ec2': aws.client('ec2'),
              'iam': aws.client('iam'),
              'asg': aws.client('autoscaling'),
              '_get': lambda x: pluck(context, x) or (partial(context.get), x)
            }

  context.update({ 'ipe': context['iam'].get_waiter('instance_profile_exists') })
  context.update(**config)

  asg_plan = eval(get_plan('asg'), context)
  result = execute2(context, asg_plan)
  return result


cli.add_command(aws)
# aws.add_command(masters)
# aws.add_command(minions)
aws.add_command(status)
aws.add_command(cluster)
aws.add_command(cluster_info)
# aws.add_command(vpc)
# aws.add_command(asg)


if __name__ == '__main__':

  cli()

