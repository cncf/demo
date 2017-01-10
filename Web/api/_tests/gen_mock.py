#!/usr/bin/env python

from __future__ import print_function
import random


for _ in range (0,1000):

  print({'Boinc_Jobs': 0,
         'CPU': random.randint(3,12),
         'DistCC': random.randint(900,1424),
         'HTTP_Requests': random.randint(2000000, 2542424),
         'Memory': random.randint(16,32),
         'Provider': 'AWS'})
