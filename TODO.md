# TODO

- Testing Zookeeper causes an error:

```
$ docker run -it --rm --link $CONTAINER $TESTIMAGE /app/distributedlog-service/bin/dlog zkshell localhost:2181
JMX enabled by default
DLOG_HOME => /app/distributedlog-service/bin/..
Connecting to localhost:2181
Welcome to ZooKeeper!
JLine support is enabled
[zk: localhost:2181(CONNECTING) 0] ls /
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
```
