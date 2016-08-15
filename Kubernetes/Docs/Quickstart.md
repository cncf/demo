# Quickstart Guide
Getting started with the `cncfdemo` is a three-step process:

1. [Install dependencies] (#dependencies)
2. [Create a Kubernetes cluster, running Prometheus] (#cluster)
3. [Run demo apps] (#demo)

## 1. Install Dependencies <a id="dependencies"></a>

- `brew install kubernetes-cli` 

  <sub>If your package manager does not have `kubectl`, simply [download a binary release](https://github.com/kubernetes/kubernetes/releases) and add `kubectl` to your path. See [Installing and Setting up kubectl] (http://kubernetes.io/docs/user-guide/prereqs/) for platform-specific installation instructions. </sub>

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
  
## 2. Create Cluster <a id="cluster"></a>

- `cncf bootstrap aws`

  <sub>AWS is used as an example. Substitute with your provider of choice. Grab a beverage, this step takes several minutes.</sub>
  
- Keep a second terminal tab open and run:
```
❯ kubectl proxy
Starting to serve on 127.0.0.1:8001
```

## 3. Run Demo <a id="demo"></a>

- `cncf demo`

- Browse to: [countly.cncfdemo.io](countly.cncfdemo.io)

- `cncf benchmark --time 5m --save-html`
 
