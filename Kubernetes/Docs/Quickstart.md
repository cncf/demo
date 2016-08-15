# Quickstart Guide
Getting started with the `cncfdemo` is a three-step process:

1. [Install dependencies] (#dependencies)
2. [Create a Kubernetes cluster, running Prometheus] (#cluster)
3. [Run demo apps] (#demo)

## 1. Install Dependencies <a id="dependencies"></a>

1. Run `brew install kubernetes-cli` 

  If your package manager does not have `kubectl`, simply [download a binary release](https://github.com/kubernetes/kubernetes/releases) and add `kubectl` to your path. See [Installing and Setting up kubectl] (http://kubernetes.io/docs/user-guide/prereqs/) for platform-specific installation instructions.
  
  **Linux**
  ```
  <path/to/kubernetes-directory>/platforms/linux/amd64
  ```
  **Windows**
  ```
  <path/to/kubernetes-directory>/platforms/windows/amd64/kubectl.exe
  ```

2. Run `pip install cncf`

   pip is the python package manager. It is strongly recommended to also use a dedicated python virtualenv. For detailed install instructions for your platform read: [The Hitchhiker's Guide to Python](http://docs.python-guide.org/en/latest/starting/install/osx/#setuptools-pip). 
  
  <sub>**Note**: `cncfdemo` is coming to your native package manager soon.</sub>
  
## 2. Create Cluster <a id="cluster"></a>

1. `cncf bootstrap aws`

  AWS is used as an example. Substitute with your provider of choice. 
  <sub>**Note**: Grab a beverage, this step takes several minutes.</sub>
  
2. Open a second terminal, run `kubectl proxy`
  ```
  ❯ kubectl proxy
  Starting to serve on 127.0.0.1:8001
  ```
  Keep this terminal open.

## 3. Run Demo <a id="demo"></a>

1. Run `cncf demo`
2. Browse to [countly.cncfdemo.io](countly.cncfdemo.io)
3. Run `cncf benchmark --time 5m --save-html`
 
