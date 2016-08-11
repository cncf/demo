# Quickstart Guide

### Grab dependencies

- `brew install kubernetes-cli` 

  <sub>If the package manager native to your platform doesn't have it, simply [download a binary release](https://github.com/kubernetes/kubernetes/releases) and add kubectl to your path.</sub>

  ```
  # Linux
  <path/to/kubernetes-directory>/platforms/linux/amd64
  # Windows
  <path/to/kubernetes-directory>/platforms/windows/amd64/kubectl.exe
  ```



- `pip install cncf`

  <sub>pip is the python package manager. It is strongly recommended to also use a dedicated python virtualenv.
  For detailed install instructions for your platform read: [The Hitchhiker's Guide to Python](http://docs.python-guide.org/en/latest/starting/install/osx/#setuptools-pip). 
  
  **Note**: cncf is coming to your native package manager soon.</sub>
  
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
 
