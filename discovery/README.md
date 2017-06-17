# Instructions

```
❯ token=$(curl -s https://discovery.cncfdemo.io/new)
❯ echo $token
cncfci.J7eoGQxsQsAWaE4V
❯ curl -s https://discovery.cncfdemo.io/$token
❯ curl -s https://discovery.cncfdemo.io/$token?ip=172.42.42.42
172.42.42.42:6443
❯ curl -s https://discovery.cncfdemo.io/$token
172.42.42.42:6443
```
