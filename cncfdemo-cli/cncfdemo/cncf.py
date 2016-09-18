import os
import sys
import click

from cncfdemo.bootstrap.main import bootstrap
from cncfdemo.kubectl.cmd_create import create

@click.group()
def cli():
  """Welcome to the Cloud Native Computing Foundation Demo"""
  pass


cli.add_command(bootstrap)
cli.add_command(create)


if __name__ == '__main__':
  cli()
