import os
import sys

import yaml, json

import glob2

import click
import jinja2

from cncfdemo.commands.configmap import cli as configmap
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

@click.command('create', short_help='create resources', context_settings=dict(allow_extra_args=True, ignore_unknown_options=True))
@click.argument('subcommand', type=click.Choice(['configmap', 'configmaps']), required=False)
@click.option('--dry-run', is_flag=True)
@click.option('--debug', is_flag=True)
@click.option('-f', type=click.Path(exists=True), help='definition file', required=False)
@click.option('--recursive', is_flag=True)
@click.pass_context
def cli(ctx, subcommand, f, recursive, dry_run, debug):
    """Description here"""

    #import ipdb; ipdb.set_trace()
    args = convert(ctx.args)
    args['dry_run'] = dry_run
    args['debug'] = debug

    if subcommand == 'configmap':
      ctx.invoke(configmap, **args)

    elif subcommand == 'configmaps':
      args['recursive'] = True
      ctx.invoke(configmap, **args)

    else:

      if not f:
        click.echo('''error: Missing option "-f".''')
        click.echo('''See 'cncf create --help' for help and examples.''')
        sys.exit(0)

      realpath = os.path.realpath(f)

      manifests = []

      if os.path.isfile(f):
          manifests.extend([realpath+'/'+f])

      if os.path.isdir(f):
        if recursive:
          manifests.extend([f for f in glob2.glob(realpath + '/**/*.j2')])
          manifests.extend([f for f in glob2.glob(realpath + '/**/*.yml')])
          manifests.extend([f for f in glob2.glob(realpath + '/**/*.yaml')]) 
          manifests = [f for f in manifests if os.path.isfile(f)]
        else:
          manifests.extend([f for f in os.listdir(realpath) if os.path.isfile(realpath+'/'+f) and f.endswith(('.j2','.yaml','.yml'))])

      if not manifests:
        click.echo('no manifest files found')
        sys.exit(0)

      #import ipdb; ipdb.set_trace()
      if debug:
          click.echo(manifests)

      for manifest in manifests:
        definitions = None

        t = jinja2.Environment(loader=jinja2.FileSystemLoader(os.path.dirname(os.path.realpath(manifest))))
        t.filters['json_dump'] = json_dump
        definitions = t.get_template(os.path.basename(manifest)).render()

        if debug:
          print definitions if definitions else ''

        for definition in yaml.load_all(definitions):

          if debug:
            click.echo(definition)

          if not dry_run:
            resp, status = create(definition)

if __name__ == '__main__':
    cli()
