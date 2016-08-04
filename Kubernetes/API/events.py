#!/usr/bin/env python

import socket
import StringIO
import json

try:
    from http_parser.parser import HttpParser
except ImportError:
    from http_parser.pyparser import HttpParser


def process(events, desired):
  for event in events:

    generateName = event['object']['metadata']['generateName'] # 'cfg-'
    phase = event['object']['status']['phase'] 

    if phase == 'Running':
      desired.add(event['object']['metadata']['name'])
      print '*'*80
      print event
      print '='*80

    print '='*80
    print desired, len(desired)
    print '='*80

def connect(desired, url=''):
  
  url = '/api/v1/pods?labelSelector=app%3Dmongoc&watch=true' # TODO: properly/dynamically build this
  request = ("GET {} HTTP/1.1\r\n"
             "Host: localhost\r\n"
             "\r\n").format(url) 
  
  try:
    sock = socket.create_connection(('localhost', 8001))
    sock.send(request.encode('ASCII'))

    p = HttpParser()
    stream = b''

    while True:
        data = sock.recv(1024)
        if not data:
            break

        recved = len(data)
        nparsed = p.execute(data, recved)
        assert nparsed == recved

        if p.is_partial_body():
            stream += p.recv_body()
            temp = StringIO.StringIO(stream)
            lines = temp.readlines()
            temp.close()

            if lines[-1].endswith('\n'):
              stream = b''
            else:
              stream = lines.pop()

            events = [json.loads(l.decode('utf-8')) for l in lines]

            if events:
              process(events, desired)

	    if len(desired) > 2: # TODO: paramtize termination conditional, don't hard code
	      #import ipdb; ipdb.set_trace()
	      print desired
	      sock.close()
              return True

        if p.is_message_complete():
            break

  finally:
    sock.close()


def main():

  desired = set()
  resp = connect(desired, url='')

  if resp:
    print 'done'

if __name__ == "__main__":
    main()
