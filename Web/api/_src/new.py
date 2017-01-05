from __future__ import print_function

import os
import time, datetime
import json

import jsonschema
from jsonschema import validate
from hashids import Hashids

import boto3


def load_files(path='./Schemas'):
    files = [j for j in os.listdir(path) if j.endswith('.json')]
    for f in files:
      with open(os.path.join(path, f)) as json_file:
        foo = json.load(json_file)  # TODO: turn into dict
    return foo


def respond(body=None, err=None):
    return {
        'statusCode': '400' if err else '200',
        'body': json.dumps(err.message) if err else json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def store_data(Key, Body, Metadata = {'foo': 'bar'}, ContentType='application/json'):
  s3 = boto3.resource('s3')
  bucket = s3.Bucket('stats.cncfdemo.io')
  bucket.put_object(ACL='public-read', Key=Key, Body=Body, ContentType=ContentType, Metadata=Metadata)


def handler(event, context):

    print("Received event: " + json.dumps(event, indent=2))  # logs to CloudWatch

    try:
      body = json.loads(event.get('body'))
    except (ValueError, TypeError):
      err = type('err', (object,), {})
      err = err()
      err.message = 'Body must be valid json'
      return respond(err=err)

    hashids = Hashids(salt='grabfromenv')
    schema = load_files()

    try:
      validate(body, schema)
    except (jsonschema.exceptions.SchemaError, jsonschema.exceptions.ValidationError) as err:
      return respond(err=err)

    now = int(time.time())  # Collision if two demos start at exactly same second
    human = datetime.datetime.fromtimestamp(now).strftime('%a, %d %B %Y - %H:%M UTC')

    body['Metadata']['id'] = hashids.encode(now)
    body['Metadata']['timestart'] = now

    body['events'] = [{ "title": "",
                        "raw": r"""<span class="event-message">Demo Started On {}</span>""".format(human),
                     }]

    store_data(body['Metadata']['id'], json.dumps(body))
    return respond(body=body)


if __name__ == '__main__':

  context = {}
  event = load_files('../_tests/new')
  event['body'] = json.dumps(event['body'])

  print(handler(event, context))
