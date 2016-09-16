from functools import partial, reduce
import collections 

import sys
import botocore
import click


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
      resource = context[a.resource]
      #arguments = {k: (unroll(v) if isinstance(v, tuple) else v) for k,v in a.arguments.items()}
      arguments = walk(a.arguments)
      #click.echo("{}...".format(a.method))
      result = getattr(resource, a.method)(**arguments)
      click.echo("{}... OK".format(a.method))
      if a.saveas:
        context[a.saveas] = result
    except botocore.exceptions.ClientError as e:
      click.echo("Unexpected error: {}".format(e))
      sys.exit("Aborting..")


def DhcpConfigurations(region):
  domain_name = 'ec2.internal' if region == 'us-east-1' else '{}.compute.internal'.format(region)
  return [{'Key': 'domain-name-servers', 'Values': ['AmazonProvidedDNS']}, {'Key': 'domain-name', 'Values': ['{} k8s'.format(domain_name)]}]

