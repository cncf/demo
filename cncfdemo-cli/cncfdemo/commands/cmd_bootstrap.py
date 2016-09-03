import os
import sys

import yaml, json

import glob2

import click
import jinja2

import subprocess


#from cncfdemo.commands.configmap import cli as configmap
#from cncfdemo.commands.create import create

@click.command('bootstrap', short_help='run a deployment', context_settings=dict(allow_extra_args=True, ignore_unknown_options=True))
@click.option('-f', type=click.Path(exists=True), required=False)   
@click.option('--dry-run', is_flag=True)
@click.option('--debug', is_flag=True)
@click.pass_context
def cli(ctx, f, dry_run, debug):
  """Description"""

  wd = os.path.dirname(os.path.realpath(__file__))
  cwd = os.path.realpath(wd+'/../'+'Deployment') or f

  commands = [('./bootstrap_aws.py', wd+'/../Bootstrap'),
              ('cncfdemo create configmaps', ''),
              ('cncfdemo create -f {} --recursive'.format(cwd), '')]

  for command in commands:

    cmd, dir = command
    process = subprocess.Popen(cmd.split(), cwd=(dir or cwd), stdout=subprocess.PIPE)

    returncode = None
    while returncode is None:
      returncode = process.poll()
      sys.exit('Something went wrong: exit code {}'.format(returncode)) if returncode else click.echo(process.stdout.readline().rstrip())

if __name__ == '__main__':
    cli()
    #import ipdb; ipdb.set_trace()
