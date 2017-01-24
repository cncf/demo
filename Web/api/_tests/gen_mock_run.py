#!/usr/bin/env python

from __future__ import print_function

import sys

import time, datetime
import json
import random

from hashids import Hashids

N = int(sys.argv[1]) if 1 < len(sys.argv) else 2

hashids = Hashids(salt='grabfromenv')

now = int(time.time())
human = datetime.datetime.fromtimestamp(now).strftime('%a, %d %B %Y - %H:%M UTC')

data = []
for _ in range (0,N):
  now += random.randint(1,100)

  Metadata = {
    'Masters': {'size': 1, 'type': 'm3.medium'},
    'Minions': {'size': 3, 'type': 'm4.large'},
    'Provider': 'AWS',
    'RAM': '24GiB',
    'Storage': '250GB',
    'id': hashids.encode(int(time.time())),
    'timestart': now,
    'timeend': now + 60*14 + random.randint(2,120),
    'vcpu': 6
    }


  Results = {
    'id': Metadata['id'],
    'timestart': Metadata['timestart'],
    'timeend': Metadata['timeend'],

    'Boinc_Jobs': 0,
    'CPU': Metadata['vcpu'], #random.randint(3,12),
    'DistCC': random.randint(900,1424),
    'HTTP_Requests': random.randint(2000000, 2542424),
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
      "timeend" :   now + random.randint(45, 70),
      "title": "Creating AWS Resources"
    }]

  events.append({
      "timestart" : events[-1]['timeend'] + 3,
      "timeend" :   events[-1]['timeend'] + random.randint(45, 70),
      "content": """<ul><li>Master Ready</li><li>Node 1 Ready</li><li>Node 2 Ready</li><li>Node 3 Ready</li></ul>""",

      "title": "Instances Booting",
    })


  events.append({
      "timestart" : events[-1]['timeend'] + 14,
      "timeend" :   events[-1]['timeend'] + random.randint(25, 42),
      "title": "Installing Kubernetes AddOns"
    })

  events.append({
      "raw": "<hr id=\"ClusterReady\">",
      "title": ""
    })

  events.append({
      "timestart" : events[-2]['timeend'] + 4,
      "timeend" :   events[-2]['timeend'] + random.randint(65, 77),
      "title": "Mongo Cluster Ready"
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
      "timestart" : events[-2]['timeend'] + 4,
      "timeend" :  Metadata['timeend'],
      "title": "Boinc Started"
    })

  events.append({
      "timestart" : events[-1]['timeend'] + 1,
      "timeend" :   events[-1]['timeend'] + Results['DistCC'],
      "title": "DistCC Started"
    })

  events.append({
      "timestart" : events[-1]['timeend'] + random.randint(0,3),
      "timeend" :   events[-1]['timeend'] + random.randint(-10,33),
      "title": "HTTP Load Started"
    })

  events.append({
      "raw": "<hr>",
      "title": ""
    })

  events.append({
      "timestart" : events[-3]['timestart'],
      "timeend" :   events[-3]['timeend'],
      "title": "DistCC Finished"
    })

  events.append({
      "timestart" : events[-3]['timestart'],
      "timeend" :   events[-3]['timeend'],
      "title": "WRK Stopped ({} requests completed)".format(Results['HTTP_Requests'])
    })

  events.append({
      "timestart" : events[-6]['timestart'],
      "timeend" :   events[-6]['timeend'],
      "title": "Boinc Stopped (0 completed)"
    })

  human = datetime.datetime.fromtimestamp(events[-1]['timeend']).strftime('%a, %d %B %Y - %H:%M UTC')

  events.append({
      "raw": r"""<span class="event-message">Demo Finished On {}</span>""".format(human),
      "title": ""
    })


  data = { 'Metadata': Metadata,
                'results': Results,
               'events': events }

  print(json.dumps(data))
