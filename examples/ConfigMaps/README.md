# [Config Maps](http://kubernetes.io/docs/user-guide/configmap/)

Orthogonally to Kubernetes it is good practice to make configurations available via a distributed key-value store such as:

* [Etcd](https://coreos.com/etcd/docs/latest/api.html#key-space-operations)
* [Consul](https://www.consul.io/intro/getting-started/kv.html)
* ZooKeeper

Kubernetes uses Etcd internally and the ConfigMap concept is a simple wrapper around its functionality. 

Note: instead of adding such key-value pairs individually you can and should include a whole file of such definitions when appropriate.

>data:
>
>> foo: value1

>> bar: value2

>> baz.yml: |-
>>> file contents here


# Try these commands 

kubectl create -f prometheus.yaml

kubectl get configmap/prometheus

kubectl get configmap/prometheus -o yaml
