#!/usr/bin/env python

import sys
import os

import glob2
import yaml
import json

import click
import jinja2

from cncfdemo.kubectl.utils import create, json_dump


configmapTemplate = ('{% macro inc(file) %}{% include [file] %}{% endmacro %}' '\n'
                     'apiVersion: v1'                                          '\n'
                     'kind: ConfigMap'                                         '\n'
                     'metadata:'                                               '\n'
                     '  name: {{ name }}'                                      '\n'
                     'data:'                                                   '\n'
                     '  {% for file in files -%}'                              '\n'
                     '  {{ file }}: |'                                         '\n'
                     '{{ inc(file)|indent(6, true) }}'                         '\n'
                     '  {% endfor -%}')


@click.group()
def cli():
  pass


#@click.group()
@click.command('configmap', short_help='create a configmap')
@click.argument('name')
@click.option('--from-file', type=click.Path(exists=True), help='point at a file or folder', required=True)
@click.option('--dry-run', is_flag=True) 
@click.option('--debug', is_flag=True) 
@click.option('--recursive', is_flag=True) 
@click.option('--extra-args')
#@click.pass_context
def configmap(name, from_file, dry_run, debug, recursive, extra_args):

  #import ipdb; ipdb.set_trace()
  if (not name) and extra_args:
    name = extra_args[0] if len(extra_args) > 0 else ''
    
  if (not from_file) and recursive:
    from_file = '.' 

  if not (name or recursive):
    click.echo('''error: NAME is required''')
    click.echo('''See 'cncf create configmap -help' for help and examples.''')
    sys.exit(0)

  if not from_file:
    click.echo('''error: Missing loloption "--from-file".''')
    click.echo('''See 'cncf create configmap -help' for help and examples.''')
    sys.exit(0)

  if not (os.path.isfile(from_file) or os.path.isdir(from_file)):
    click.echo('"{}" not found'.format(click.format_filename(from_file)))
    sys.exit(0)

  realpath = os.path.realpath(from_file) 

  if recursive:
    configMapDirs = [dir for dir in glob2.glob(realpath + '/**/configMaps/') if os.listdir(dir)] if recursive else from_file
    if not configMapDirs:
      click.echo('''error: no configMaps directories found''')
      sys.exit(0)
    for dir in configMapDirs:
      contents = [os.path.realpath(dir)+'/'+d for d in os.listdir(dir)]
  else: 
    contents = [realpath]

  for item in contents:
    definitions = None
    dirname = os.path.dirname(os.path.realpath(item))
    basename = os.path.basename(os.path.realpath(item))

    if os.path.isfile(item) and os.path.getsize(item) > 0:
      t = jinja2.Environment(loader=jinja2.FileSystemLoader(item))
      t.filters['json_dump'] = json_dump
      definitions = t.from_string(configmapTemplate).render(files=[basename], name=basename)

    if os.path.isdir(item) and os.listdir(item):
      t = jinja2.Environment(loader=jinja2.FileSystemLoader(item))
      t.filters['json_dump'] = json_dump
      definitions = t.from_string(configmapTemplate).render(files=[f for f in os.listdir(item) if os.path.isfile(item+'/'+f)], name=basename)
      
    
    if debug: 
      click.echo(definitions if definitions else 'Empty')

    if dry_run:
      sys.exit(0)

    #import ipdb; ipdb.set_trace()
    for definition in yaml.load_all(definitions):
      if debug:
        click.echo(definition)
      resp, status = create(definition)

cli.add_command(configmap)

if __name__ == '__main__':
    configmap()
