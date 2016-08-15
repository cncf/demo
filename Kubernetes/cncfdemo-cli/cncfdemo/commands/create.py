#!/usr/bin/env python

import json

import click
import jinja2
import requests 


def create(definition, overrides={}):

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

    #import ipdb; ipdb.set_trace()
    r = requests.post(url, json=definition)
    response = json.loads(r.content)

    if r.ok:
      click.echo('{} "{}" created'.format(response['kind'], response['metadata']['name']))
    else:
      click.echo('Error from server: error when creating "{}": {}'.format(response['details']['name'], response['message']))

    return r.content, r.ok


@click.command('creat', short_help='create a resource')
@click.option('--dry-run', is_flag=True)
@click.option('--debug', is_flag=True)
@click.pass_context
def cli(debug, dry_run):
  click.echo('yo')

if __name__ == "__main__":
    cli()
