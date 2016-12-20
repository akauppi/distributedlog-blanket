# TODO

- `docker-compose.yml` so that `docker-compose up` works, for getting all nicely started (local development).

- `Dockerfile.bk` hasn't been tried
- `Dockerfile.wp` hasn't been tried

Contributions are welcome.

# BUGS

- Using our own configuration file with Zookeeper did not work, for some reason. Check `Dockerfile.zookeeper.3.4.9` and/or `Dockerfile.zookeeper.3.5` (and corresponding notes commented out in `README.md`).

The error is seen at the testing phase, when ZooKeeper remains in `CONNECTING` state, instead of reaching `CONNECTED`:

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
