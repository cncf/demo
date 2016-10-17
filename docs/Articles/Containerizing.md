# Notes on Containerizing Apps

## Picking a base image

Inevitably when working with containers the question of the base image comes up. Is it better to opt for the spartan minimalism of Alpines and Busyboxes or a bog standard 700MB CentOS?

Should you split your app into multiple containers each running a single process or bake everything into one blob?

The (typical engineer) answer is "it depends".

Take a complex app like Countly for example. To package it up convinently, so a developer can quickly try it out on her laptop for instance, it is neccessary to bundle Mongo, Nginx, NodeJS, the Countly API server app, and the dashboard UI app.

## Single process per container or... not

You can't always run one process per container. What you really might crave in such a situation is a process control system or even a proper init. 

> Traditionally a Docker container runs a single process when it is launched, for example an Apache daemon or a SSH server daemon. Often though you want to run more than one process in a container. There are a number of ways you can achieve this ranging from using a simple Bash script as the value of your container’s CMD instruction to installing a process management tool. <sub>- [Docker's documentation on using supervisord](https://docs.docker.com/engine/admin/using_supervisord/)</sub>

There's [several such supervisors](http://centos-vn.blogspot.com/2014/06/daemon-showdown-upstart-vs-runit-vs.html), a popular one being [runit](http://smarden.org/runit/). Runit is written in C and uses less resources than supervisord, adheres to the unix philosophy of utilities doing one thing well, and is very reliable.

##### Beware

There's a subtle problem of [Docker and PID 1 zombie reaping](http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/) the aformentioned process supervisors alone don't solve. 

The Ubuntu based [phusion baseimage](http://phusion.github.io/baseimage-docker/) works around this with a small (340 line) [my_init](https://github.com/phusion/baseimage-docker/blob/rel-0.9.16/image/bin/my_init) script.

>Ideally, the PID 1 problem is solved natively by Docker. It would be great if Docker supplies some builtin init system that properly reaps adopted child processes. But as of January 2015, we are not aware of any effort by the Docker team to address this.

As of [September 20, 2016](https://github.com/docker/docker/pull/26061), this is finally fixed by Docker upstream with an optional small new daemon that gets injected with ```--init=true```.

### Customizing Countly for Kubernetes

Countly provides an official [docker image](https://hub.docker.com/r/countly/countly-server/) based on [Phusion](http://phusion.github.io/baseimage-docker/) the advantages and considerations of which are outlined above.

We extend it and simply keep the services we want to use:

```
FROM countly/countly-server:16.06

# Add custom Countly configs - these in turn come from k8s volume
ADD ./runit/countly-api.sh /etc/service/countly-api/run
ADD ./runit/countly-dashboard.sh /etc/service/countly-dashboard/run
```

##### Example service

```
#!/usr/bin/env bash

cp /etc/config/api.js /opt/countly/api/config.js
chown countly:countly /opt/countly/api/config.js

exec /sbin/setuser countly /usr/bin/nodejs /opt/countly/api/api.js
```
<sub>countly-api.sh is almost exactly like the file we replaced.</sub>

This service file is executed by runit and clobbers the default config each time. The file `/etc/config/api.js` is not actually permenantly baked into the image but rather arrives via a Kubernetes configmap.

And here we've had to resort to a bit of a hack. [ConfigMap backed volumes mounted as root](https://github.com/cncf/demo/issues/28) is a known and open issue. At the moment there's no way to specify permissions. Hence, the chown line.

#### Decomposing apps into microservices for Kubernetes

We've completely gotten rid of the Nginx service countly bundles as edge routing can be done any number of ways elsewhere with Kubernetes.

Whether or not we split apart the dashboard app and the API server is not a question of convenience or style. The API server clearly maps to a [replication controller](http://kubernetes.io/docs/user-guide/replication-controller/) and can be horizontally auto scaled with custom metrics (more on this later).

The dashboard app for our purposes has no high availability requirment and is rarely used. However, even when idle, it is taking up resources on the pod and this waste is multipled across however many API servers we end up -- whereas we only need one dashboard app running at a time.

The clean way is to split it out further to one seperate pod on the side.

As for mongo, both of these service contain a connection string we pass as a configmap like so:

```
mongodb: {
        host: "mongos.default",
        db: "countly",
        port: 27017,
        max_pool_size: 500,
    }
```


#### Seperation of concerns 

As a result, it is up to us to deploy and scale mongo seperatly from countly. Even if this particular mongo cluster is dedicated entirely to countly, and it should be, this seperation of concerns is good for maintainability and resilience. 

This decoupling is healthy. For example, a bug in one of the horizontally scaled countly API servers that causes a crash would not take a mongo pod along with it and thus the impact on overall performance is contained. Instead it will crash and burn on the side, the liveliness tests will fail, and Kubernetes in turn will transparantly route away further requests to siblings while simultanousely launching a replacement. 

- graph showing how chaos-monkey style killing one of the countlies impacts overall writes, and for how long (fast recovery is cool)

#### InitContainers

Ask yourself, does it make sense for Countly pods to be running when there is no Mongo backend available to them? The answer is no. In fact, if Countly happens to start first the deployment becomes unpredictable.

Luckily [init containers](https://github.com/kubernetes/kubernetes/blob/release-1.4/docs/proposals/container-init.md) have reached beta status in the latest version of Kubernetes (1.4). In short, with this feature enabled the pod you normally specify alone now starts last in a blocking list.

```
pod:
  spec:
    containers: ...
    initContainers:
    - name: init-container1
      image: ...
      ...
    - name: init-container2
    Containers:
    - name: regularcontainer
    
```

init-container1 can have a simple command along the lines of `nslookup monogos.default | -ge 3`. This will fail as long as the mongo service is not up and running and passing its readyness and liveliness probes. Countly will be blocked from starting until the init container succeeds, exactly the desired behaviour. 

### Deploying a Mongo cluster with Kubernetes

Separate article?
