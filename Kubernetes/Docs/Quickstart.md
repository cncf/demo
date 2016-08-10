# Quickstart Guide

### Grab dependencies

- `brew install kubernetes`

- `pip install cncf`

### Create Cluster

- `cncf bootstrap aws`

  <sub>Grab a beverage, this step takes several minutes</sub>
  
- Keep a second terminal tab open and run:
```
❯ kubectl proxy
Starting to serve on 127.0.0.1:8001
```

### Run Demo

- `cncf demo`

- Browse to: [countly.cncfdemo.io](countly.cncfdemo.io)

- `cncf benchmark --time 5m --save-html`
 
