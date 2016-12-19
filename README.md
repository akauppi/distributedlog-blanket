# sleeves-distributedlog

[DistributedLog](http://distributedlog.incubator.apache.org/) is an interesting project but its documentation and Docker deployability are so-and-so (Dec-16).

This repository builds on top of the DistributedLog repo, and tries to

- make a faster initial experience, trying out DistributedLog
- take a more user focused approach to documentation
- provide separately deployable Docker images for Zookeeper, Bookkeeper and DistributedLog components (service, write proxy) 

## Background

DistributedLog carries its own versions of Zookeeper (though it works with any Zookeeper 3.4.*) and BookKeeper (where the custom version is required, until Twitter's patches are - if they are - merged with the main project). 

For these reasons, it seems like a good alternative to build all Docker images from the components provided by distributedlog, itself.

## Approaches

It's up to you, which distributedlog release - or master - you wish to set up under `distributedlog` subfolder. This allows us to follow the evolving project at a close range.

Instead of making the Docker side pull distributedlog files in, or pouring all of them for each package, or making just one has-all package, we selectively copy the files actually needed to run the particular subprojects. This is more modular, and closer to how independent Docker modules would behave.

## Requirements

Clone distributedlog to a subfolder, and build it. You can use a release of your choice.

```
$ git clone https://github.com/apache/incubator-distributedlog.git
```

```
$ (cd incubator-distrbutedlog && mvn clean package -DskipTests)
```

Have Docker running:

```
$ docker-machine start default
$ eval $(docker-machine env)
```

## Creating Docker files

### Zookeeper

<!-- disabled
We can use the Docker Hub's [zookeeper image](https://hub.docker.com/_/zookeeper/). DistributedLog requires 3.4.x and this one is 3.4.9.
-->

Running the Docker Hub's [zookeeper image](https://hub.docker.com/_/zookeeper/) should have worked (DistributedLog requires 3.4.x and this one is 3.4.9), but it didn't. These instructions build, run and test Zookeeper from within the DistributedLog sources.

**Building**

You can name the image and the container the way you like.

```
$ export IMAGE=dlzk:latest
$ export CONTAINER=dlzk-container
$ docker build -t $IMAGE -f Dockerfile.zookeeper .
```

**Running**

```
$ docker run --name $CONTAINER --restart always -d $IMAGE
```

The Docker file exposes ports 2181 2888 3888 (client port, follower port, election port), e.g. if this image is linked with others. To reach Zookeeper from the host, add `-P` to the command.

To override configuration, use `-v your.conf:/conf/zookeeper.conf` (e.g. if you run multiple Zookeeper instances).

**Testing**

For testing, let's create another container that contains all the files in the `incubator-distributedlog` folder. By doing this, we can access all the support files (such as `scripts/*`) and can test the `--link` of ports between different containers.

```
$ export TESTIMAGE=dltest:latest
$ export TESTCONTAINER=dltest-container
$ docker build -t $TESTIMAGE -f Dockerfile.test .
```

Test by running a command within the Docker container:

```
$ docker run -it --rm --link $CONTAINER $TESTIMAGE /app/distributedlog-service/bin/dlog zkshell localhost:2181
...
[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 1] quit
```

<!-- Did not work, even with '-P'. Gives
<<
[zk: 192.168.99.100:2181(CONNECTING) 0] ls /
Exception in thread "main" org.apache.zookeeper.KeeperException$ConnectionLossException: KeeperErrorCode = ConnectionLoss for /
	at org.apache.zookeeper.KeeperException.create(KeeperException.java:99)
	at org.apache.zookeeper.KeeperException.create(KeeperException.java:51)
	at org.apache.zookeeper.ZooKeeper.getChildren(ZooKeeper.java:2255)
	at org.apache.zookeeper.ZooKeeper.getChildren(ZooKeeper.java:2283)
	at org.apache.zookeeper.cli.LsCommand.exec(LsCommand.java:93)
	at org.apache.zookeeper.ZooKeeperMain.processZKCmd(ZooKeeperMain.java:674)
	at org.apache.zookeeper.ZooKeeperMain.processCmd(ZooKeeperMain.java:577)
	at org.apache.zookeeper.ZooKeeperMain.executeLine(ZooKeeperMain.java:360)
	at org.apache.zookeeper.ZooKeeperMain.run(ZooKeeperMain.java:320)
	at org.apache.zookeeper.ZooKeeperMain.main(ZooKeeperMain.java:280)
<<
	
Alternatively, you can test that you can reach Zookeeper from the host (if you used `-P` in `docker run`):

```
$ docker-machine ip
192.168.99.100
$ incubator-distributedlog/distributedlog-service/bin/dlog zkshell 192.168.99.100:2181
...
[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 1] quit
```
-->



<!-- remove?
```
$ docker build -t your.org/yourid/distributedlog-zk:latest -f Dockerfile.zk .
```

Testing

```
$ docker run your.org/yourid/distributedlog-zk:latest

$ $DL_HOME/distributedlog-service/bin/dlog zkshell $(docker-machine ip):2181
...
[zk: 192.168.1.101:2181(CONNECTED) 0] ls /
[zookeeper]
[zk: 192.168.1.101:2181(CONNECTED) 1] quit
```

#### References

- jplock/[docker-zookeeper](https://github.com/jplock/docker-zookeeper/blob/master/Dockerfile)
-->

### BookKeeper

### DistributedLog Core

### DistributedLog Write Proxy

### DistrbutedLog all (zk+bk+wp)

```
$ docker build -t your.org/yourid/distributedlog-all:latest -f Dockerfile.all .
```

The Docker files are based on:

- distributedlog itself
- franckcuny/[docker-distributedlog](https://github.com/franckcuny/docker-distributedlog)


## References

- DL > Admin Guide > [Zookeeper](http://distributedlog.incubator.apache.org/docs/latest/admin_guide/zookeeper.html)
- DL > Admin Guide > [BookKeeper](http://distributedlog.incubator.apache.org/docs/latest/admin_guide/bookkeeper.html)



---
**The rest of the text is an early draft that needs to be edited.**

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

We use configuration in `conf/zookeeper.conf`. It's based on the `distributedlog-core/conf/zookeeper.conf.template`

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
  - really good page, describing how to run ZooKeeper within Docker