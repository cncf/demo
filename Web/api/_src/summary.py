from __future__ import print_function

import json

import botocore
import boto3


def respond(body=None, err=None):
    return {
        'statusCode': '400' if err else '200',
        'body': json.dumps(err.message) if err else json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def handler(event, context):

    #print("Received event: " + json.dumps(event, indent=2))  # logs to CloudWatch
    bucket = boto3.resource('s3').Bucket('stats.cncfdemo.io')
    key = event['Records'][0]['s3']['object']['key']

    blob = bucket.Object(key).get()
    finished = json.loads(blob['Body'].read())

    try:
      blob2 = bucket.Object('summary/summary.json').get()
      summary = json.loads(blob2['Body'].read())
      sorted_summary = sorted(summary['Results'], key = lambda k: k['timestart'])
    except:
      sorted_summary = []

    another = finished['results']

    another['id'] = finished['Metadata']['id']
    another['timestart'] = finished['Metadata']['timestart']
    another['timeend'] = finished['Metadata']['timeend']

    sorted_summary.append(another)
    bucket.put_object(Key='summary/summary.json', Body=json.dumps({"Results" : sorted_summary}), ContentType='application/json', ACL='public-read')

    print("summaries: ", len(sorted_summary))
