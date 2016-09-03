#!/bin/bash

cncfdemo create configmaps
cncfdemo create -f Deployments --recursive

# kubectl get pods
# kubectl logs -f mongors1-setup-k8cxn
# kubectl logs -f mongors2-setup-wje6o
# kubectl logs -f mongocfg-setup-tewjt
# these can really only be scripted by listening for events from the api on a background thread

# Optional step: python Utils/AWS/route53.py -elb $(./Utils/get_ingress.sh countly) -domain countly.cncfdemo.io
