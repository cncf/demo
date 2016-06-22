#!/bin/bash

kubectl describe svc countly | grep Ingress | cut -d':' -f2
