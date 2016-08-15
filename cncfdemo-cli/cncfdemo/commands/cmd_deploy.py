import os
import sys

import yaml, json

import glob2

import click
import jinja2

from cncfdemo.commands.configmap import cli as configmap
from cncfdemo.commands.create import cli as createcli
from cncfdemo.commands.create import create

def json_dump(foo):
  return json.dumps(foo)[1:-1]

def convert(args):
  result = {'extra_args': []}
  for item in args:
    if item.startswith('--'):
      key = item[2:].replace('-','_')
      if '=' in key:
        key, val = key.split('=')
      else:
        val = key
      result[key] = val
    else:
      result['extra_args'].append(item)  
  return result

@click.command('deploy', short_help='run a deployment', context_settings=dict(allow_extra_args=True, ignore_unknown_options=True))
@click.option('--dry-run', is_flag=True)
@click.option('--debug', is_flag=True)
@click.option('-f', type=click.Path(exists=True), required=False)
@click.pass_context
def cli(ctx, f, dry_run, debug):
    """Description"""

    import ipdb; ipdb.set_trace()
    if not f:
      click.echo('''error: Missing option "-f"''')
      click.echo('''See 'cncf create --help' for help and examples.''')
      sys.exit(0)

    #args = convert(ctx.args)
    #args = {'dry_run': dry_run, 'debug': debug, 'recursive': True}

    #args = {'dry_run': dry_run, 'recursive': True}
    args = {'dry_run': dry_run, 'f': f}
    #args = {}

    import ipdb; ipdb.set_trace()
    ctx.invoke(createcli,  **args)
    import ipdb; ipdb.set_trace()
    sys.exit(0)
    import ipdb; ipdb.set_trace()
    ctx.invoke(configmap, **args)
    import ipdb; ipdb.set_trace()
    sys.exit(0)

if __name__ == '__main__':
    cli()
