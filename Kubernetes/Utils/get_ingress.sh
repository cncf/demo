#!/bin/bash

# Necessary hack until this info is exposed programmatically
kubectl describe svc $1 | grep Ingress | cut -d':' -f2 | xargs echo
