
---
**The rest of the text is an early draft that needs to be edited.**

---

[DistributedLog](http://distributedlog.incubator.apache.org/) is a persistent message bus created by people at Twitter and open sourced in the summer of 2016.

It is implemented in Java but uses two Twitter-original Scala libraries, and therefore releases of DistributedLog are specific to a certain Scala version.

The project is in Apache incubation phase, and getting running with it is not exactly easy. This repository tries to help with that.

We (plan to) provide:

- Docker files for the necessary components
- Documentation that is enough to get you going. You can read the actual DistributedLog as a reference.

We work on the DistributedLog `master` version, currently 0.4.0. 

Disclaimer: This repo is intended as a development aid. Don't use it in production as-is.

The repository is based on two pages in the DistributedLog documentation that actually crack the nuts: [Cluster Setup](http://distributedlog.incubator.apache.org/docs/latest/deployment/cluster.html) (for most of the stuff) and [this section](http://distributedlog.incubator.apache.org/docs/latest/tutorials/basic-1#run-the-tutorial) in the tutorials, to write and read from console to the message bus.

The documentation of the project needs a lot of work, to be consistent, bugless and reader centric. Currently (18-Dec-2016) it's not. Ideally, something new like [StackOverflow Documentation](http://stackoverflow.com/documentation) could be used to maintain a peer-reviewed, reader centric set of training material.

## DistributedLog sources

Clone DistributedLog to a suitable location (it can be right here; we've set the folder in `.gitignore`). We'll use scripts etc. from there.

```
$ git clone https://github.com/apache/incubator-distributedlog.git
$ cd distrbutedlog
$ mvn clean install -DskipTests
...
```

```
$ export DL_HOME=$(pwd)
```

## Running on local machine

We're eventually aiming to run Zookeeper, Bookkeeper and DistributedLog under Kubernetes. To get there, we need to run them under Docker. To get there, we need to understand how they run on a single, local machine.

[Cluster Setup & Deployment](http://distributedlog.incubator.apache.org/docs/latest/deployment/cluster.html#zookeeper) (DistributedLog documentation) essentially tells us how. This is a shorthand list of commands mentioned there.

What you will get: 

- working DistributedLog setup on the local machine

What you need:

- DistributedLog cloned, as mentioned above

### Zookeeper

DistributedLog carries its own Zookeeper (3.5.1-alpha at the time of writing) jar under `lib` and its shell scripts launch this one.

It can be used with other Zookeeper instances as well (>= 3.4.x), but for us it's easiest to follow the official documentation which uses the bundled approach.

Hint: [ZooKeeper Guide](http://distributedlog.incubator.apache.org/docs/latest/admin_guide/zookeeper)

We use configuration in `conf/zoo.cfg`. It's based on the `distributedlog-core/conf/zookeeper.conf.template`

Data is gathered on the local disk. DistributedLog instructions recommend setting "data log" folder on a separate disk than the main data, but this is something that matters only in production (the instructions don't do it, and we don't either).

tbd. Make so that we get also locally run data into a subdir, not the system-wide dirs.

```
$ mkdir -p /tmp/data/zookeeper/txlog
$ echo "1" > /tmp/data/zookeeper/myid
```

Run the instance

```
$ ${DL_HOME}/distributedlog-service/bin/dlog-daemon.sh start zookeeper conf/zookeeper.conf
doing start zookeeper ...
starting zookeeper, logging to /Users/asko/Sources/distributedlog.akauppi/distributedlog-service/logs/dlog-zookeeper-removed.local-0.log
JMX enabled by default
DLOG_HOME => /Users/asko/Sources/distributedlog.akauppi/distributedlog-service/bin/..
```

Test that the instance is fine

```
$ ${DL_HOME}/distributedlog-service/bin/dlog zkshell localhost:2181
...
[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 1] quit
```

If you saw that, things are fine. Let's set up BookKeeper.

<font color=red>The above did NOT work. Going to try separate 3.5.0 [Zookeeper image](https://hub.docker.com/r/mrhornsby/zookeeper/), later.</font>
 
### BookKeeper

...





<!-- disabled (progress here during HackWeek)

## Running with Docker

Let's see how we can have DistributedLog, BookKeeper and Zookeeper running using Docker containers. This should be a trivial way to get you started with DistributedLog.

Note: This is meant as a development scenario. We don't replicate anything. The configuration files and data content are mapped in the `vol` folder.

### Requirements

The steps are tested on macOS 10.12 and `bash`. Here are additional things you should set up.

#### Docker

With docker-machine:

```
$ docker-machine upgrade default
```

```
$ docker-machine start default
$ eval $(docker-machine env)
```

If you have Docker Toolbox, please suggest the proper preliminary steps here. tbd.


### Zookeeper

For Zookeeper, there are existing Docker containers we can use, and simply provide a suitable configuration to them.

```
$ docker run --name some-zookeeper --restart always -d -v $(pwd)/vol/conf/zoo.cfg:/conf/zoo.cfg -v $(pwd)/vol/tmp/data:/tmp/data -v $(pwd)/vol/tmp/datalog:/tmp/datalog 31z4/zookeeper
```

The configuration is based on DistributedLog's [zookeeper.conf.template](https://github.com/apache/incubator-distributedlog/blob/master/distributedlog-core/conf/zookeeper.conf.template).

Note: We're using the exact same folder structures as DistributedLog documentation, to reduce confusion. This means that all Zookeeper, BookKeeper and DistributedLog files end up in the same `vol` folder. However, each Docker container is mapped to see only the files that it actually needs.
-->


## References

- 31z4/[zookeeper-docker](https://github.com/31z4/zookeeper-docker) (GitHub)
