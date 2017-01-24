from __future__ import print_function

import os
import time, datetime
import json

import jsonschema
from jsonschema import validate
from hashids import Hashids

import botocore
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


def store_data(Bucket, Key, Body, Metadata = {'foo': 'bar'}, ContentType='application/json'):
  Bucket.put_object(Key=Key, Body=Body, ContentType=ContentType, Metadata=Metadata, ACL='public-read')


def upsert(event, bucket):

    body = json.loads(event.get('body'))
    uuid, upsert = body.get('id'), body.get('upsert')

    try:
      blob = bucket.Object('running/' + uuid).get()
    except botocore.exceptions.ClientError as err:
      err.message = err.response['Error']
      return respond(err=err)

    demo = json.loads(blob['Body'].read())
    demo['events'] = sorted(demo['events'], key= lambda k: k['id'])

    upsert['id'] = demo['events'][-1]['id'] + 1
    upsert['timestart'] = int(time.time())
    upsert['timeend'] = None

    demo['events'].append(upsert)
    demo['results'] = body.get('results') or demo.get('results')

    store_data(bucket, 'running/' + uuid, json.dumps(demo))
    return respond(body=demo)


def stop(event, bucket):

    body = json.loads(event.get('body'))
    uuid = body.get('id')
    event_id = body.get('event_id')

    try:
      blob = bucket.Object('running/' + uuid).get()
    except botocore.exceptions.ClientError as err:
      err.message = err.response['Error']
      return respond(err=err)

    demo = json.loads(blob['Body'].read())
    events = sorted(demo['events'], key= lambda k: k['id'])

    try:
      next(iter(filter(lambda e : e['id'] == event_id, events)))['timeend'] = int(time.time())
    except StopIteration:
      err = type('err', (object,), {})
      err = err()
      err.message = 'Event to stop timer for not found'
      return respond(err=err)

    store_data(bucket, 'running/' + uuid, json.dumps(demo))
    return respond(body=demo)


def finish(event, bucket):

    body = json.loads(event.get('body'))
    uuid = body.get('id')

    try:
      blob = bucket.Object('running/' + uuid).get()
    except botocore.exceptions.ClientError as err:
      err.message = err.response['Error']
      return respond(err=err)

    now = int(time.time())  # Collision if two demos start at exactly same second
    human = datetime.datetime.fromtimestamp(now).strftime('%a, %d %B %Y - %H:%M UTC')

    demo = json.loads(blob['Body'].read())
    demo['Metadata']['timeend'] = now

    events = sorted(demo['events'], key= lambda k: k['id'])
    events.append({ "title": "",
                    "raw": r"""<span class="event-message">Demo Finished On {}</span>""".format(human),
                    "id": 0
                     })

    demo['events'] = events

    store_data(bucket, 'finished/' + uuid, json.dumps(demo))
    bucket.Object('running/' + uuid).delete()
    return respond(body=body)

def new(event, bucket):

    body = json.loads(event.get('body'))
    schema = load_files()

    try:
      validate(body, schema)
    except (jsonschema.exceptions.SchemaError, jsonschema.exceptions.ValidationError) as err:
      return respond(err=err)

    hashids = Hashids(salt='grabfromenv')  # TODO: get the salt from env
    now = int(time.time())  # Collision if two demos start at exactly same second
    human = datetime.datetime.fromtimestamp(now).strftime('%a, %d %B %Y - %H:%M UTC')

    body['Metadata']['id'] = hashids.encode(now)
    body['Metadata']['timestart'] = now

    body['events'] = [{ "title": "",
                        "raw": r"""<span class="event-message">Demo Started On {}</span>""".format(human),
                        "id": 0
                     }]


    store_data(bucket, 'running/' + body['Metadata']['id'], json.dumps(body))
    return respond(body=body)


def handler(event, context):

    print("Received event: " + json.dumps(event, indent=2))  # logs to CloudWatch

    try:
      body = json.loads(event.get('body'))
    except (ValueError, TypeError):
      err = type('err', (object,), {})
      err = err()
      err.message = 'Body must be valid json'
      return respond(err=err)

    path = event.get('path').split('/')[1] # lame
    bucket = boto3.resource('s3').Bucket('stats.cncfdemo.io')

    return globals()[path](event, bucket)


if __name__ == '__main__':

  context = {}
  event = load_files('../_tests/new')
  event['body'] = json.dumps(event['body'])
  event['path'] = '/stop'

  print(handler(event, context))
