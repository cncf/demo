from functools import partial, reduce
import collections

import sys
import botocore
import click
import time


class Action(collections.namedtuple('Action', [ "resource", "method", "arguments", "saveas" ])):
  def __new__(cls, resource, method, arguments, saveas=""):
    return super(Action, cls).__new__(cls, resource, method, arguments, saveas)


def pluck(source, selector):
  return reduce(lambda d,k: d.get(k, {}), selector.split('.'), source)


def unroll(pair):
  get, selector = pair
  selector = selector.split('.')
  item = selector.pop(0)
  return getattr(get(item), '.'.join(selector))


def walk(adict):
  for key, value in adict.iteritems():
    if isinstance(value, dict):
      walk(value)
    elif isinstance(value, tuple) and isinstance(value[0], partial):
      adict[key] = unroll(value)
    elif isinstance(value, collections.Sequence):
      for item in value:
        if isinstance(item, dict):
          walk(item)
  return adict


def execute2(context, actions):

  for a in map(lambda action: Action(*action), actions):

    try:

      if a.method == 'create_launch_configuration':
        click.echo('waiting some more..')
        time.sleep(10) # AWS API bug, remove in future

      resource = context[a.resource]
      arguments = walk(a.arguments)
      result = getattr(resource, a.method)(**arguments)
      click.echo("{}... OK".format(a.method))
      if a.saveas:
        context[a.saveas] = result


    except botocore.exceptions.ClientError as e:

      Errors = ['InvalidKeyPair.Duplicate','InvalidGroup.Duplicate','InvalidPermission.Duplicate','EntityAlreadyExists','AlreadyExists', \
                'InvalidGroup.NotFound','NoSuchEntity','ValidationError','LimitExceeded','DependencyViolation', 'DryRunOperation']

      if e.response['Error']['Code'] in Errors:
        click.echo(e.response['Error']['Message'])
      else:
        click.echo("Unexpected error: {}".format(e))
        sys.exit("Aborting..")

  return context


def DhcpConfigurations(region):
  domain_name = 'ec2.internal' if region == 'us-east-1' else '{}.compute.internal'.format(region)
  return [{'Key': 'domain-name-servers', 'Values': ['AmazonProvidedDNS']}, {'Key': 'domain-name', 'Values': ['{}'.format(domain_name)]}]

