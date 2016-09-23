#!/usr/bin/env python

import click
from aws.cli import aws

@click.group()
def cli():
  pass


cli.add_command(aws)


if __name__ == '__main__':
  cli()
