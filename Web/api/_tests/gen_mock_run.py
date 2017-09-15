#!/usr/bin/env python2

from __future__ import print_function

import sys
import calendar

import time, datetime
import json
import random

from hashids import Hashids

N = int(sys.argv[1]) if 1 < len(sys.argv) else 2
# print('N is {}'.format(N))

hashids = Hashids(salt='grabfromenv')

from datetime import datetime, timedelta


n = (datetime.now() - timedelta(days=3, hours=random.randint(1,5), minutes=random.randint(1,30), seconds=random.randint(1,42)))
now=calendar.timegm(n.utctimetuple())
# now = int(n.timestamp())
# now = int(time.time())
human = datetime.fromtimestamp(now).strftime('%a, %d %B %Y - %H:%M UTC')

data = []

aws = {
  'Masters': {'size': 3, 'type': 'm3.large'},
  'Minions': {'size': 0, 'type': ''},
  'Provider': 'AWS',
  'RAM': '21.23GiB',
  'Storage': '96GB',
  'id': hashids.encode(int(time.time())),
  'timestart': now,
  'timeend': now + 60*12 + random.randint(60,120),
  'vcpu': 6
  }

gce = {
  'Masters': {'size': 3, 'type': 'n1-standard-2'},
  'Minions': {'size': 0, 'type': ''},
  'Provider': 'GCE',
  'RAM': '21.53GiB',
  'Storage': '0GB',
  'id': hashids.encode(int(time.time())),
  'timestart': now,
  'timeend': now + 60*9 + random.randint(50,80),
  'vcpu': 6
  }

packer = {
  'Masters': {'size': 3, 'type': 'type-0'},
  'Minions': {'size': 0, 'type': ''},
  'Provider': 'Packet',
  'RAM': '23.68GiB',
  'Storage': '0GB',
  'id': hashids.encode(int(time.time())),
  'timestart': now,
  'timeend': now + 60*9 + random.randint(2,40),
  'vcpu': 12
  }


for cloud in range (0,1):
  now += random.randint(1,100)

  Metadata = aws
  FACTOR = 1.3
  TARGET_LOW = int(540 * FACTOR)
  TARGET_HIGH = int(660 * FACTOR)
  TARGET = random.randint(TARGET_LOW, TARGET_HIGH)


  Results = {
    'id': Metadata['id'],
    'timestart': Metadata['timestart'],
    'timeend': Metadata['timeend'],

    'Boinc_Jobs': 0,
    'CPU': Metadata['vcpu'], #random.randint(3,12),
    'DistCC': TARGET,
    'HTTP_Requests': random.randint(1000000, 1542424),
    'Memory': Metadata['RAM'],
    'Provider': Metadata['Provider']
  }

  events = [

    {
      "raw": r"""<span class="event-message">Demo Started On {}</span>""".format(human),
      "title": ""
    },

    {
      "timestart" : now + 3,
      "timeend" :   now + random.randint(305, 370),
      "title": "Provisioning Cloud Resources",
      "stdout_url": "https://s3-us-west-2.amazonaws.com/data.cncfdemo.io/{}/01-Provisioning-Cloud-Resources.stdout".format(Results['id'])
    }]

  events.append({
      "timestart" : events[-1]['timeend'] + 3,
      "timeend" :   events[-1]['timeend'] + random.randint(185, 250),
      "title": "Instances Booting",
      "stdout_url": "https://s3-us-west-2.amazonaws.com/data.cncfdemo.io/{}/02-Instances-Booting.stdout".format(Results['id'])

    })


  events.append({
      "timestart" : events[-1]['timeend'] + 14,
      "timeend" :   events[-1]['timeend'] + random.randint(25, 42),
      "title": "Helm Chart",
      "content": "<div class='content-extra' hidden><pre class='tty'><ul><li>+ helm repo add cncfdemo http://helm-repo6.cncfdemo.io/stable</li><li>+ helm install --name cncfdemo cncfdemo/simplest --set report=beta.cncfdemo.io</li><li>+ Deployed cncfdemo helm chart - v0.0.6</li></ul></pre></div>"
    })

  events.append({
      "raw": "<hr id=\"ClusterReady\">",
      "title": ""
    })

  events.append({
      "timestart" : events[-2]['timeend'] + 4,
      "timeend" :   events[-2]['timeend'] + random.randint(65, 87),
      "title": "Mongo Cluster Ready",
      "stdout_url": "https://s3-us-west-2.amazonaws.com/data.cncfdemo.io/{}/04-Mongo-Cluster-Ready.stdout".format(Results['id'])
    })

  events.append({
      "timestart" : events[-1]['timeend'] + 9,
      "timeend" :   events[-1]['timeend'] + random.randint(21, 35),
      "title": "Countly Ready"
    })

  events.append({
      "raw": "<hr>",
      "title": ""
    })

  events.append({
      "timestart" : events[-2]['timestart'],
      "timeend" :   events[-2]['timeend'] + TARGET,
      "title": "DistCC Finished"
    })

  events.append({
      "timestart" : events[-1]['timestart'] - random.randint(21, 52),
      "timeend" :   events[-1]['timeend'] + random.randint(4, 18),
      "title": "HTTP Load Stopped ({} requests completed)".format(Results['HTTP_Requests'])
    })

  events.append({
      "timestart" : events[-1]['timestart'] + random.randint(2,10),
      "timeend" :   events[-1]['timeend'] + random.randint(52,94),
      "title": "Boinc Stopped (0 completed)",
      "content": "<div class='content-extra' hidden><pre class='tty'><ul><li>+ /sbin/setuser boinc /var/lib/boinc-client/attach.sh</li><li>+ exec /sbin/setuser boinc /usr/bin/boinc --exit_after_finish --fetch_minimal_work --exit_when_idle --abort_jobs_on_exit --no_gpus</li></ul></pre></div>"

    })

  human = datetime.fromtimestamp(events[-1]['timeend']).strftime('%a, %d %B %Y - %H:%M UTC')

  events.append({
      "raw": r"""<span class="event-message">Demo Finished On {}</span>""".format(human),
      "title": ""
    })


  data = { 'Metadata': Metadata,
                'results': Results,
               'events': events }

  print(json.dumps(data))



