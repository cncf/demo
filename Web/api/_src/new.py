from __future__ import print_function

import os
import time
import json

from hashids import Hashids

import jsonschema
from jsonschema import validate

def loadFiles(path='./Schemas'):
    files = [j for j in os.listdir(path) if j.endswith('.json')]
    for f in files:
      with open(os.path.join(path, f)) as json_file:
        foo = json.load(json_file)  # TODO: turn into dict
    return foo


def respond(body=None, err=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def handler(event, context):

    print("Received event: " + json.dumps(event, indent=2))
    hashids = Hashids()
    schema = loadFiles()

    try:
      validate(event, schema)
    except (jsonschema.exceptions.SchemaError, jsonschema.exceptions.ValidationError) as err:
      return respond(err=err)

    uuid = hashids.encode(int(time.time()))
    return respond(body=uuid)

if __name__ == '__main__':

  context = {}
  event = loadFiles('../_tests/new')

  print(handler(event, context))
