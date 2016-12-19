#!/bin/sh

set -x

env

cd /opt/distributedlog

./bin/dlog com.twitter.distributedlog.service.DistributedLogServerApp \
  -p 8000 \
  --shard-id 1 \
  -sp 8001 \
  -u "distributedlog://${ZOOKEEPER_ADDR}${DLOG_URI_PATH}" \
  -mx \
  -c /opt/distributedlog/conf/write_proxy.conf
