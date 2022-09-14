#!/bin/bash

$SPARK_HOME/sbin/stop-all.sh
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh
echo "sleeping 15s..."
sleep 15s
netstat -tulpn | grep LISTEN
jps
