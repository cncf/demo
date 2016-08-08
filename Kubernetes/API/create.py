#!/usr/bin/env python

import os
import sys
import time
import random

import argparse
import logging
import yaml, json

import requests 
from jinja2 import Template

def parse(**kwargs):
  require = 'filename','definitions'
  args = [arg in kwargs.keys() for arg in require]
  if all(args) or not any(args): 
    raise TypeError('must provide parse() either {} or a {}'.format(*require))

  if kwargs.get('filename'):
    try:
      with open(kwargs.get('filename'), "r") as f:
        definitions = f.read()
    except (IOError, OSError) as e:
      print e.strerror
      sys.exit(1)

  if kwargs.get('filename').endswith('.j2') or cli.j:
    t = Template(definitions)
    definitions = t.render()
    #import ipdb; ipdb.set_trace()

  try:
    data = yaml.load_all(definitions or kwargs.get('definitions'))
  except yaml.YAMLError, exc:
    data = None
    print "Error in file:", exc

  return data or sys.exit("Aborting..")


def create(definition, overrides={}):

    """Create a resource by filename or stdin.
    
    JSON and YAML formats are accepted.
    
    Usage:
    create.py -f FILENAME 
    
    Examples:
    # Create a pod using the data in pod.json.
    create.py -f ./pod.json
    
    # Create a pod based on the JSON passed into stdin.
    cat pod.json | create.py -f -
    """

    defaults = { 'scheme': 'http',
      	       'host': 'localhost',
  	       'port': '8001',
  	       'path': 'api',
  	       'apiVersion': 'v1',
  	       'namespace': 'default'
               }
  
    endpoint = defaults.copy()
    endpoint.update(overrides)
    endpoint.update(definition)
  
    endpoint['path'] += 's' if not endpoint['apiVersion'] == 'v1' else ''
    endpoint['kind'] += 's' if not endpoint.get('kind','').endswith('s') else ''
    endpoint['kind'] = endpoint['kind'].lower()
  
    url = '{scheme}://{host}:{port}/{path}/{apiVersion}/namespaces/{namespace}/{kind}'.format(**endpoint)

    if definition.get('conditional'):

      iteration = 0
      predicate = False

      while not predicate:
        if iteration > 5:
          sys.exit("Timeout, aborting..")

        iteration += 1
        time.sleep((2 ** iteration) + (random.randint(0, 500) / 1000.0))

        matchLabels = definition['spec']['selector']['matchLabels']  # TODO: support full ruleset
        selectors = ','.join(['{}={}'.format(*pair) for pair in matchLabels.items()]) 

        r = requests.get(url, params={'labelSelector': selectors})
        resp = json.loads(r.content)
        predicate = eval(definition['conditional'])

        log.debug('{}, iteration {}'.format(predicate, iteration))


    else:
      r = requests.post(url, json=definition)
      resp = json.loads(r.content)

    return r.content
   
if __name__ == "__main__":

  """TODO:

  - Add stdin support 
  - Add folder support
  - add nested folder support / recursive flag
  - add url support
  - nicer logging setup
  """

  parser = argparse.ArgumentParser()
  parser.add_argument('-f', '--filename', required=True) 
  parser.add_argument('-j', '--jinja', default=False) 
  parser.add_argument('-d', '--dryrun', action='count', default=False) 
  parser.add_argument('-v', '--verbose', action='count', default=0)
  cli = parser.parse_args()

  log = logging.getLogger(__name__)
  log_handler = logging.StreamHandler(sys.stdout)
  level = 40 - min(cli.verbose*10,30)
  log_handler.setLevel(level)
  log.addHandler(log_handler)
  log.setLevel(level)

  log.debug(cli)

  definitions = parse(filename=cli.filename)
  for definition in definitions:
    if definition:
      log.info(definition)
      if not cli.dryrun:
        result = create(definition)
        log.debug(json.loads(result))

