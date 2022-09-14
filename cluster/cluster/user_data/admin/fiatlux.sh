#!/bin/bash

# clean possible previous process
#$HADOOP_HOME/sbin/stop-all.sh
#$HADOOP_HOME/sbin/stop-all.sh

echo "=== Hadoop daemons ==="
$HADOOP_HOME/sbin/start-all.sh
sleep 5s

echo "=== Spark daemons ==="
$SPARK_HOME/sbin/start-all.sh

echo "waiting 15 seconds..."
sleep 15s
jps

netstat -tulpn | grep LISTEN
echo "OK!"
