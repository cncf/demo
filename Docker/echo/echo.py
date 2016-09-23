#!/usr/bin/env python

import random
import json

import falcon


class JSONResource(object):
  def on_get(self, request, response):
    json_data = {'message': "Hello, world!"}
    response.body = json.dumps(json_data)


class PlaintextResource(object):
  def on_get(self, request, response):
    response.set_header('Content-Type', 'text/plain')
    response.body = b'OK'


def append_headers(request, response, resource, params):
  for pair in request.get_param_as_list('append_header') or []:
    try:
      name, value = pair.split(',', 1)
    except:
      name, value = pair.split(',', 1), None
    response.append_header(name, value)


def timeout(request, response, resource, params):
  if random.randrange(100) < sorted((0, request.get_param_as_int('timeout_probability') or 0, 100))[1]:
    secs = request.get_param_as_int('timeout_seconds') or 1
    raise falcon.HTTPServiceUnavailable('Temporarily Unavailable', 'Timed out, wait {} second'.format(secs), secs)


def error(request, response, resource, params):
  if random.randrange(100) < sorted((0, request.get_param_as_int('error_probability') or 0, 100))[1]:
    raise falcon.HTTPInternalServerError('INTERNAL SERVER ERROR', 'The server encountered an unexpected condition that prevented it from fulfilling the request.')


@falcon.before(timeout)
@falcon.before(error)
@falcon.before(append_headers)
class EchoResource(object):
  def on_get(self, request, response):
    response.set_header('Content-Type', request.get_param('Content-Type') or 'text/plain')
    response.status = request.get_param('status') or '200 OK'
    response.data = request.get_param('body') or 'OK'


app = falcon.API()
app.add_route("/json", JSONResource())
app.add_route("/plaintext", PlaintextResource())
app.add_route("/echo", EchoResource())


if __name__ == "__main__":
    from wsgiref import simple_server

    httpd = simple_server.make_server('localhost', 8080, app)
    httpd.serve_forever()
