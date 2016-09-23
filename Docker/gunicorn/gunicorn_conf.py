import multiprocessing
import os
import sys

# Sane Defaults

workers = multiprocessing.cpu_count()
bind = '0.0.0.0:8080'
keepalive = 120
errorlog = '-' 
pidfile = 'gunicorn.pid'
worker_class = "meinheld.gmeinheld.MeinheldWorker"

def post_fork(server, worker):
  # Disalbe access log
  import meinheld.server
  meinheld.server.set_access_logger(None)

# Override from ENV
for k,v in os.environ.items():
  if k.startswith("GUNICORN_"):
    key = k.split('_', 1)[1].lower()
    locals()[key] = v

