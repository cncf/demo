from random import choice
from string import ascii_letters, digits

import boto3
import json


#TODO: Add support for this script to be executed directly/not-in-lambda
print('Loading function')


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('testing')


def validate(ClusterId):
    try:
      assert isinstance(ClusterId, str)
      assert len(list(ClusterId.split('.'))) == 2
      assert len(list(filter(None, ClusterId.split('.')))) == 2
      assert len(ClusterId.split('.')[0]) == 6
      assert len(ClusterId.split('.')[1]) == 16
      assert all(c in (ascii_letters+digits) for c in ClusterId.split('.')[0])
      assert all(c in (ascii_letters+digits) for c in ClusterId.split('.')[1])
      return True

    except AssertionError:
      print("none valid clusterid")
      return False


def save(ClusterId, IP=None, Port=None):
    #TODO: Validate legal IP:Port
    table.put_item(Item={'ClusterId': ClusterId, 'IP': IP, 'Port': Port })


def generate(prefix='cncfci', size=1):
    pre = (prefix + ''.join(choice(ascii_letters+digits) for i in range(6)))[:6]
    post = ''.join(choice(ascii_letters+digits) for i in range(16))
    return '{0}.{1}'.format(pre, post)


def respond(err, res=None):
    return {
        'statusCode': err if err else '200',
        'body': '' if err else res,
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))


    token = event["pathParameters"]["token"]
    qParams = event['queryStringParameters'] or {}

    if (token == 'new'):
        try:
            size = int(qParams.get('size', ''))
        except ValueError:
          size = 1

        print("Generating new token of size {}".format(size))
        new_token = generate()
        save(new_token)
        return respond(None, new_token)

    valid = validate(token)
    print("{} token requested and it is {} valid.".format(token, '' if valid else 'not'))
    if not valid:
        return respond(422, 'invalid token')

    IP, Port = qParams.get('ip'), qParams.get('port', '6443')
    if IP:
        ClusterId = token
        save(ClusterId, IP=IP, Port=Port)
    else:
        resp = table.get_item(Key={ 'ClusterId': token })

        Item = resp.get('Item', {})
        ClusterId, IP, Port = Item.get('ClusterId'), Item.get('IP'), Item.get('Port', '6443')

    status = None if all([ClusterId, IP]) else (102 if ClusterId else 404)

    body = "{0}:{1}".format(IP, Port)
    return respond(status, body)

