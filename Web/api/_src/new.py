from __future__ import print_function

import os
import time
import json

from hashids import Hashids

import jsonschema
from jsonschema import validate

def loadSchemas():
    schemas = [j for j in os.listdir('./Schemas') if j.endswith('.json')]
    for schema in schemas:
      with open(os.path.join('./Schemas', schema)) as json_file:
        foo = json.load(json_file)
    return foo


def respond(res=None, err=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else json.dumps(res),
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def handler(event, context):

    print("The context:")
    print("*"*80)
    print(context)
    print("*"*80)
    print("Received event: " + json.dumps(event, indent=2))

    #http_method = event.get('http_method')

    schema = loadSchemas()

    try:

      validate(event, schema)
      err = None

      hashids = Hashids()
      uuid = hashids.encode(int(time.time()))

    except jsonschema.exceptions.SchemaError as ve:

      uuid = None
      err = ve
      print(ve.message)


    return respond(uuid, err)



if __name__ == '__main__':

  context = {}
  event = {}

  print(handler(event, context))
