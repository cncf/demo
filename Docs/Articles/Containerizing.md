# Containerizing & Kubernetesizing Apps


Inevitably when working with containers the question of the base image comes up. Is it better to opt for the spartan minimalism of Alpines and Busyboxes or a bog standard 700MB CentOS?

Should you split your app into multiple containers each running a single process or bake everything into one blob?

The (typical engineer) answer is "it depends".

Take a complex app like Countly for example. To package it up convinently, so a developer can quickly try it out on a laptop for instance, it is neccessary to bundle Mongo, Nginx, NodeJS, the Countly API server app, and the dashboard UI app.

## Single process per container or... not

You can't always run one process per container. What you really might crave in such a situation is a process control system or even a proper init. 

> Traditionally a Docker container runs a single process when it is launched, for example an Apache daemon or a SSH server daemon. Often though you want to run more than one process in a container. There are a number of ways you can achieve this ranging from using a simple Bash script as the value of your container’s CMD instruction to installing a process management tool. <sub>- [Docker's documentation on using supervisord](https://docs.docker.com/engine/admin/using_supervisord/)</sub>

There's [several such supervisors](http://centos-vn.blogspot.com/2014/06/daemon-showdown-upstart-vs-runit-vs.html), another popular one being [runit](http://smarden.org/runit/). Runit is written in C and uses less resources than supervisord, adheres to the unix philosophy of utilities doing one thing well, and is very reliable.

##### Beware

There's a subtle problem of [Docker and PID 1 zombie reaping](http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).
The aformentioned process supervisors are not enough. 

The Ubuntu based [phusion baseimage](http://phusion.github.io/baseimage-docker/) works around this with a small (340 line) [my_init](https://github.com/phusion/baseimage-docker/blob/rel-0.9.16/image/bin/my_init) script.

>Ideally, the PID 1 problem is solved natively by Docker. It would be great if Docker supplies some builtin init system that properly reaps adopted child processes. But as of January 2015, we are not aware of any effort by the Docker team to address this.

As of [September 20, 2016](https://github.com/docker/docker/pull/26061), this is finally fixed by Docker upstream with an optional small new daemon that gets injected with ```--init=true```.
