# The `cncf` command _shadows and complements_ Kubectl. 

> ❯ cncf create configmap example --from-file=path/to/directory

> ❯ kubectl create configmap example --from-file=path/to/directory

There are advantages besides being 57% shorter to type. Lets compare the two.


## The Kubectl Command
<sub>MacOS: `brew install kubernetes`</sub>

Kubectl is written in Go. It authenticates against an existing Kubernetes cluster.

It interacts with the [remote REST API server](http://kubernetes.io/docs/admin/accessing-the-api/).



## The CNCF Command

<sub>`pip install cncf`, and is coming to your favorite package manager soon.</sub>

cncf is written in Python. It doesn't authenticate against an existing Kubernetes cluster.

It interacts with the [remote REST API server](http://kubernetes.io/docs/admin/accessing-the-api/).

```
In order to use cncf from your machine open a second terminal tab and run:

❯ kubectl proxy
Starting to serve on 127.0.0.1:8001
```




Unlike Kubectl, it is able to create new clusters on your favorite cloud provider (or even bare metal).

> ❯ cncf bootstrap aws --masters 3 --minions 6








