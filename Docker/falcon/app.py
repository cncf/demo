#!/usr/bin/env python

import json
import falcon


class Hello(object):
    def on_get(self, request, response):
        response.set_header('Content-Type', 'text/plain')
        response.body = b'Hello, world!'


app = falcon.API()
app.add_route("/", Hello())


if __name__ == "__main__":
    from wsgiref import simple_server

    httpd = simple_server.make_server('localhost', 8080, app)
    httpd.serve_forever()
