# Hosted discovery service for Kubeadm cluster bootstrap

This is fashioned after the ideas described in [running your own etc discovery service](https://coreos.com/os/docs/latest/cluster-discovery.html#running-your-own-discovery-service).
You may be familiar with the `discovery.etcd.io` endpoint for bootstraping generic etcd clusters, this is the same idea but specifically for Kubernetes clusters with Kubeadm.


### Before starting the cluster - get a new token

```
$ token=$(curl -s https://discovery.cncfdemo.io/new)
$ echo $token
cncfci.J7eoGQxsQsAWaE4V
```

### On the master - register master ip to to the token

```
$ token=cncfci.J7eoGQxsQsAWaE4V
$ master_ip=$(hostname -I | cut -d" " -f 1)
$ echo $master_ip
172.42.42.42
$ curl -s https://discovery.cncfdemo.io/$token?ip=$master_ip
172.42.42.42:6443
$ kubeadm init --token $token
```

### On the nodes - discover master ip from the token

```
$ token=cncfci.J7eoGQxsQsAWaE4V
$ master_ip=$(curl -s https://discovery.cncfdemo.io/$token)
$ echo $master_ip
172.42.42.42:6443
$ kubeadm join --token $token $master_ip
```

The `discovery.cncfdemo.io` endpoint is hosted with AWS API Gateway + Lambda and stores the token and ip pairs in dynamodb for a short amount of time. Instructions on how to roll your own (with or without lambda) coming soon.
