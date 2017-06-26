from random import choice
from string import ascii_letters, digits

import ipaddress
import json
import boto3


#TODO: Add support for this script to be executed directly/not-in-lambda
print('Loading function')


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('testing')


def validate(ClusterId):
    try:
      assert type(ClusterId) is str
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


def save(ClusterId, IP=None, Port='6443'):
    try:
        assert validate(ClusterId), "Invalid Token"
        assert ipaddress.ip_address(IP or '0.0.0.0'), "Malformed IP"
        assert type(Port) is int, "Port is not an integer: {}".format(Port)
        assert 1 < int(Port) < 65535, "Port is not in valid range"
        return table.put_item(Item={'ClusterId': ClusterId, 'IP': IP, 'Port': Port })
    except:
        return False


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

    if (token is 'new'):
        try:
            size = int(qParams.get('size', '1'))
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
        valid = save(ClusterId, IP=IP, Port=Port)
        if not valid:
            return respond(422, 'invalid IP:Port')
    else:
        resp = table.get_item(Key={ 'ClusterId': token })
        Item = resp.get('Item', {})
        ClusterId, IP, Port = Item.get('ClusterId'), Item.get('IP'), Item.get('Port', '6443')

    status = None if all([ClusterId, IP]) else (102 if ClusterId else 404)
    body = "{0}:{1}".format(IP, Port)

    return respond(status, body)

