#!/usr/bin/env python

import os
import sys

import yaml, json

import glob2

import click
import jinja2

from cncfdemo.kubectl.configmap import configmap
from cncfdemo.kubectl.utils import create as kreate, json_dump


@click.group()
def cli():
  pass


@click.group(invoke_without_command=True)
#@click.group()
@click.option('-f', '--filename', type=click.Path(exists=True), help='Filename or directory to use to create the resource', required=False)
@click.option('-R', '--recursive', is_flag=True, help='Process the directory used in -f, --filename recursively. Useful when you want to manage related manifests organized within the same directory.')
@click.option('--dry-run', is_flag=True, help='Do not submit to kubernetes apiserver')
@click.option('--debug', is_flag=True, help='Print output to stdout')
@click.pass_context
def create(ctx, filename, recursive, dry_run, debug):
  """Either '-f' option or subcommand required."""

  if ctx.invoked_subcommand:
    return 'defer to subcommand'
    
  if not filename:
    #click.echo('error: Missing option "-f".')
    click.echo(create.get_help(ctx))
    sys.exit(0)

  realpath = os.path.realpath(filename)
  manifests = []

  if os.path.isfile(filename):
      manifests.extend([realpath])

  if os.path.isdir(filename):
    if recursive:
      manifests.extend([f for f in glob2.glob(realpath + '/**/*.j2')])
      manifests.extend([f for f in glob2.glob(realpath + '/**/*.yml')])
      manifests.extend([f for f in glob2.glob(realpath + '/**/*.yaml')]) 
      manifests = [f for f in manifests if os.path.isfile(f)]
    else:
      manifests.extend([realpath+'/'+f for f in os.listdir(realpath) if os.path.isfile(realpath+'/'+f) and f.endswith(('.j2','.yaml','.yml'))])


  if not manifests:
    click.echo('no manifest files found')
    sys.exit(0)

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
      import ipdb; ipdb.set_trace()
      if not dry_run:
        resp, status = kreate(definition)


cli.add_command(create)
create.add_command(configmap)


if __name__ == '__main__':
    create()
