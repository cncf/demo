Clone this repo

Install [Minikube](https://github.com/kubernetes/minikube)


```
# Make sure context is right
kubectl config use-context minikube

# Create a bootstrap master
kubectl create -f redis/redis-master.yaml

# Create a service to track the sentinels
kubectl create -f redis/redis-sentinel-service.yaml

# Create a replication controller for redis servers
kubectl create -f redis/redis-controller.yaml

# Create a replication controller for redis sentinels
kubectl create -f redis/redis-sentinel-controller.yaml

# Scale both replication controllers
kubectl scale rc redis --replicas=3
kubectl scale rc redis-sentinel --replicas=3

# Delete the original master pod
kubectl delete pods redis-master

# ordering is important

# create a replication controller for chat example
kubectl create -f chat-controller.yaml

```
