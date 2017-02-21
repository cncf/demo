#!/usr/bin/env python

from __future__ import print_function

import sys

import time, datetime
import json
import random

from hashids import Hashids

hashids = Hashids(salt='grabfromenv')
now = int(time.time())

N = int(sys.argv[1]) if 1 < len(sys.argv) else 2


data = []
for _ in range (0,N):
  now += 1
  data.append({
    'id': hashids.encode(now),
    'timestart': now,
    'timeend': now + random.randint(850,1100),
    'Boinc_Jobs': 0,
               'CPU': random.randint(3,12),
               'DistCC': random.randint(900,1424),
               'HTTP_Requests': random.randint(2000000, 2542424),
               'Memory': random.randint(16,32),
               'Provider': 'AWS'})

print(json.dumps({"Results" : data}))
