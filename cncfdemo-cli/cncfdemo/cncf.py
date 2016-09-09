import os
import sys
import click

#from cncfdemo.commands.configmap import cli as configmap
#from cncfdemo.commands.create import cli as create

CONTEXT_SETTINGS = dict(auto_envvar_prefix='CNCF', ignore_unknown_options=True)
cmd_folder = os.path.abspath(os.path.join(os.path.dirname(__file__), 'commands'))
cmd_folder2 = os.path.abspath(os.path.join(os.path.dirname(__file__), 'Bootstrap'))

class ComplexCLI(click.MultiCommand):

    def list_commands(self, ctx):
        rv = []
        for filename in (os.listdir(cmd_folder) + os.listdir(cmd_folder2)):
            if filename.endswith('.py') and \
               filename.startswith('cmd_'):
                rv.append(filename[4:-3])
        rv.sort()
        return rv

    def get_command(self, ctx, name):
        try:
            if sys.version_info[0] == 2:
                name = name.encode('ascii', 'replace')
            mod = __import__('cncfdemo.commands.cmd_' + name,
                             None, None, ['cli'])
        except ImportError:
            return
        return mod.cli


@click.group(cls=ComplexCLI, context_settings=CONTEXT_SETTINGS)
@click.option('--script', required=False)
@click.option('--debug')
@click.option('-f', type=click.Path(exists=True), default='.', required=False)
@click.option('-v', '--verbose', is_flag=True, help='Enables verbose mode.')
@click.option('--dry-run', is_flag=True)
@click.pass_context
def cli(ctx, f, script, debug, verbose, dry_run):
  """Welcome to the Cloud Native Computing Foundation Demo"""

  #if ctx.obj is None:
  #  ctx.obj = {}
  #  ctx.obj['verbose'] = verbose
  
  # click.echo('starting..')
  #import ipdb; ipdb.set_trace()

  #args = {'f':f, 'dry_run': dry_run, 'debug': debug, 'recursive': True}
  #ctx.invoke(create, dry_run=True)
