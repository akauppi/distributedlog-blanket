# distributedlog-blanket

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

- `mvn`
- `git`
- Docker Toolbox or `docker-machine`

The instructions are made on macOS 10.12, with HomeBrew and `docker-machine`. The intention is to also support Linux, but that isn't actively tested.

Clone distributedlog to a subfolder, and build it. You can use a release of your choice.

```
$ git clone https://github.com/apache/incubator-distributedlog.git
```

```
$ cd incubator-distrbutedlog
$ mvn clean package -DskipTests
$ cd ..
```

Have Docker running:

```
$ docker-machine start default
$ eval $(docker-machine env)
```

## Creating Docker files

### Base

The `distributedlog-base` docker image carries all the files in the `incubator-distributedlog` host folder, and serves as the basis for all the images below.

Because the image is referenced by the other images, its Docker tag needs to be fixed.

**Building**

```
$ docker build -t distributedlog-base:latest -f Dockerfile.base .
```

**Testing**

```
$ docker run -it --rm distributedlog-base /bin/bash
bash-4.3# exit
exit
```

Later, we can use this with `--link $CONTAINERNAME` to test other containers are working correctly.


### Zookeeper 3.4.9 (WITHOUT our config)

DistributedLog requires ZooKeeper 3.4.x but it carries 3.5.1-alpha with it.

The one we got working is the [31z4/zookeeper](https://github.com/31z4/zookeeper-docker) image.

**Building**

```
$ docker pull 31z4/zookeeper
```

**Running**

The name we give to the container is simply for easing the instructions. It can be anything.

```
$ export ZKCONTAINER=zkc
$ docker run --name $ZKCONTAINER --restart always -d 31z4/zookeeper
```

**Testing**

```
$ docker run -it --rm --link $ZKCONTAINER:zookeeper 31z4/zookeeper zkCli.sh -server zookeeper
...
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: zookeeper(CONNECTED) 0] ls /
[zookeeper]
[zk: zookeeper(CONNECTED) 1] quit
```

If you see the **CONNECTED**, ZooKeeper is up and available.


<!--
### Zookeeper 3.4.9 (with our config) - BROKEN

DistributedLog requires ZooKeeper 3.4.x but it carries 3.5.1-alpha with it. However, we did not get 3.5 to work under Docker (details commented out, below).

The one we got working is based on the [31z4/zookeeper](https://github.com/31z4/zookeeper-docker) image. We simply add our own config files on top.

**Building**

```
$ docker build -t zookeeper-3.4.9:latest -f Dockerfile.zookeeper.3.4.9 .
```

**Running**

The name we give to the container is simply for easing the instructions. It can be anything.

```
$ export ZKCONTAINER=zk-container
$ docker run --name $ZKCONTAINER --restart always -d zookeeper-3.4.9:latest
```

**Testing**

```
$ docker run -it --rm --link $ZKCONTAINER:zookeeper zookeeper-3.4.9 zkCli.sh -server zookeeper
...
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: zookeeper(CONNECTED) 0] ls /
[zookeeper]
[zk: zookeeper(CONNECTED) 1] quit
```

If you see the **CONNECTED**, ZooKeeper is up and available.

**Troubleshooting**

If there's a repeating 'connection refused', the Zookeeper config file has some issue. See TODO.
-->

<!-- broken, please fix :)
### Zookeeper 3.5

DistributedLog requires ZooKeeper 3.4.x but it carries 3.5.1-alpha with it. The configurations have change a bit - we can aim at 3.5.x right away.

Our `Dockerfile.zookeeper.3.5` is derived from [mrhornsby/zookeeper](https://hub.docker.com/r/mrhornsby/zookeeper/). We simply add our own config files on top.

**Building**

```
$ docker build -t zookeeper-3.5:latest -f Dockerfile.zookeeper.3.5 .
```

**Running**

```
$ export ZKCONTAINER=zk-container
$ docker run --name $ZKCONTAINER -v /var/opt/zookeeper --restart always -d zookeeper-3.5:latest
```

**Testing**

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /app/distributedlog-service/bin/dlog zkshell 127.0.0.1:2181
```

<font color=red>This DID NOT pass the test: keeps state as CONNECTING instead of CONNECTED. Why is that?
</font>
-->


<!-- disabled
...

We can use the Docker Hub's [zookeeper image](https://hub.docker.com/_/zookeeper/). DistributedLog requires 3.4.x and this one is 3.4.9.

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

To override configuration, use `-v your.cfg:/conf/zoo.cfg` (e.g. if you run multiple Zookeeper instances).

Note: DistributedLog seems to prefer `zookeeper.conf` but latest (3.5.x) Zookeeper has `zoo.cfg`. We go with the latest trend.

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

DistributedLog uses a twitter branch of BookKeeper:

> The version of BookKeeper that DistributedLog depends on is ... twitter's production version 4.3.4-TWTTR, which is available in https://github.com/twitter/bookkeeper.
 
[source](http://distributedlog.incubator.apache.org/docs/latest/admin_guide/bookkeeper.html)

Because of this, we're building BookKeeper from the DistributedLog sources.

**Building**

```
$ export BKIMAGE=dlbk:latest
$ docker build -t $BKIMAGE -f Dockerfile.bk .
```

**Configuring ZooKeeper**

Let's use the same mechanism as in testing ZooKeeper, to provide it an initial configuration.

Note: This follows the instructions in [Cluster Setup & Deployment](http://distributedlog.incubator.apache.org/docs/latest/deployment/cluster.html). Maybe it can be automated, maybe not.

We change the configuration by directly touching ZooKeeper contents.

```
$ docker run -it --rm --link $ZKCONTAINER:zookeeper 31z4/zookeeper zkCli.sh -server zookeeper
...
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: zookeeper(CONNECTED) 0] create /messaging ''
Created /messaging
[zk: localhost:2181(CONNECTED) 1] create /messaging/bookkeeper ''
Created /messaging/bookkeeper
[zk: localhost:2181(CONNECTED) 2] create /messaging/bookkeeper/ledgers ''
Created /messaging/bookkeeper/ledgers
[zk: localhost:2181(CONNECTED) 3]
```

Type `quit` to exit the ZooKeeper prompt.

**Running**

```
$ export BKCONTAINER=bkc
$ ID=1 docker run --name $BKCONTAINER -d $BKIMAGE
```

**Testing**

Running of BookKeeper is tested by looking into the ZooKeeper contents:

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /app/distributedlog-service/bin/dlog zkshell 127.0.0.1:2181
...
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: 127.0.0.1:2181(CONNECTED) 0] ls /messaging/bookkeeper/ledgers/available
[127.0.0.1:3181, 127.0.0.1:3182, 127.0.0.1:3183, readonly]
[zk: localhost:2181(CONNECTED) 1]
```

Alternatively, you can (needs that you use `-P` when running the container):

```
$ curl localhost:9001/ping
pong
curl localhost:9001/metrics?pretty=true
...JSON...
```

Now we have both dependencies running. 

**Namespaces**

You can just use the default namespace, `distributedlog://127.0.0.1:2181/messaging/distributedlog`, but if you wish to configure them, now is the time.

Q: Why would one want to configure namespaces?

Also this is done by manipulating ZooKeeper contents, via `dlog admin bind` command.

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /bin/bash

/app/distributedlog-service/bin/dlog admin bind \
    -dlzr 127.0.0.1:2181 \
    -dlzw 127.0.0.1:2181 \
    -s 127.0.0.1:2181 \
    -bkzr 127.0.0.1:2181 \
    -l /messaging/bookkeeper/ledgers \
    -i false \
    -r true \
    -c \
    distributedlog://127.0.0.1:2181/messaging/distributedlog/mynamespace
```

### DistributedLog Write Proxy

DistributedLog can be written to directly, using a "Core library" (direct access to BookKeeper nodes), or via a Write Proxy that handles multiple writers.

Note: Hopefully, also access control would eventually be provided by Write Proxy.

**Building**

```
$ export WPIMAGE=dlwp:latest
$ docker build -t $WPIMAGE -f Dockerfile.wp .
```

**Running**

```
$ export WPCONTAINER=wpc
$ ID=1 docker run --name $WPCONTAINER -d $WPIMAGE
```

**Testing**

Like with BookKeeper, we can verify that the write proxy is running by either checking the zookeeper path or checking its stats port.

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /app/distributedlog-service/bin/dlog zkshell 127.0.0.1:2181
...
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: 127.0.0.1:2181(CONNECTED) 0] ls /messaging/distributedlog/mynamespace/.write_proxy
[member_0000000000, member_0000000001, member_0000000002]
[zk: localhost:2181(CONNECTED) 1]
```

Or (needs that you use `-P` when running the container):

```
$ curl localhost:20001/ping
pong
```

## Overall testing

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /app/distributedlog-service/bin/dlog tool create -u distributedlog://127.0.0.1:2181/messaging/distributedlog/mynamespace -r stream- -e 0-10
You are going to create streams : [stream-0, stream-1, stream-2, stream-3, stream-4, stream-5, stream-6, stream-7, stream-8, stream-9, stream-10] (Y or N) Y
```

Tail read from such 10 streams:

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /app/distributedlog-tutorials/distributedlog-basic/bin/runner run com.twitter.distributedlog.basic.MultiReader distributedlog://127.0.0.1:2181/messaging/distributedlog/mynamespace stream-0,stream-1,stream-2,stream-3,stream-4,stream-5,stream-6,stream-7,stream-8,stream-9,stream-10
```

All of these of course get slightly simpler if you expose the ZooKeeper port `2181` when launching the container, so you can reach it directly from the host.


### Whole shebang with `docker-compose`

To compose a combination of:

- ZooKeeper (one node)
- BookKeeper (one node)
- Write Proxy (one node)

This is useful e.g. for development.

```
$ docker-compose up
```

To shut down the services:

```
$ docker-compose down
```

<!-- disabled (unnecessary?)
## Record generators

To create artificial load on a DistributedLog cluster, one can:

```
$ docker run -it --rm --link $ZKCONTAINER distributedlog-base /app/distributedlog-tutorials/distributedlog-basic/bin/runner run com.twitter.distributedlog.basic.RecordGenerator 'zk!127.0.0.1:2181!/messaging/distributedlog/mynamespace/.write_proxy' stream-0 100
```

This fetches the write proxy address from the ZooKeeper, and then feeds values through it.
-->


## Troubleshooting

If, in building the Docker image you get this error (would happen under macOS, running `docker-machine`, it has to do with VirtualBox redirects getting too many or something like that...):

```
#Step 8 : RUN apk add --no-cache   bash
# ---> Running in 8c72465e03d5
#fetch http://dl-cdn.alpinelinux.org/alpine/v3.4/main/x86_64/APKINDEX.tar.gz
#WARNING: Ignoring http://dl-cdn.alpinelinux.org/alpine/v3.4/main/x86_64/APKINDEX.tar.gz: temporary error (try again later)
#fetch http://dl-cdn.alpinelinux.org/alpine/v3.4/community/x86_64/APKINDEX.tar.gz
#WARNING: Ignoring http://dl-cdn.alpinelinux.org/alpine/v3.4/community/x86_64/APKINDEX.tar.gz: temporary error (try again later)
#ERROR: unsatisfiable constraints:
#  bash (missing):
#    required by: world[bash]
```

Solution: 

```
$ docker-machine stop default
$ docker-machine start default
$ eval $(docker-machine env)
```

Then try again.


## References

- DL > Admin Guide > [Zookeeper](http://distributedlog.incubator.apache.org/docs/latest/admin_guide/zookeeper.html)
- DL > Admin Guide > [BookKeeper](http://distributedlog.incubator.apache.org/docs/latest/admin_guide/bookkeeper.html)
- DistributedLog > [Cluster Setup & Deployment](http://distributedlog.incubator.apache.org/docs/latest/deployment/cluster.html)

### Other DistributedLog / BookKeeper / ZooKeeper Docker projects

The Docker files are based on:

- distributedlog itself
- franckcuny/[docker-distributedlog](https://github.com/franckcuny/docker-distributedlog)
- 31z4/[zookeeper-docker](https://github.com/31z4/zookeeper-docker) (GitHub)

The approaches taken in these did not match our needs. Ideally, the DistributedLog project itself will allow cluster-friendly dockerization, e.g. for Kubernetes.

