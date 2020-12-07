#!/bin/bash

hdfs namenode -format
service ssh start
test -e /etc/ganglia/gmond.conf  || cp /gmond.conf.default  /etc/ganglia/gmond.conf
test -e /etc/ganglia/gmetad.conf || cp /gmetad.conf.default /etc/ganglia/gmetad.conf

mkdir -p /var/lib/ganglia/rrds
chown nobody /var/lib/ganglia/rrds


if [ "$HOSTNAME" = node-master ]; then

    gmond

    gmetad

    /bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2"

    start-dfs.sh
    start-yarn.sh
    start-master.sh
    cd /root/lab
    jupyter trust Bash-Interface.ipynb
    jupyter trust Dask-Yarn.ipynb
    jupyter trust Python-Spark.ipynb
    jupyter trust Scala-Spark.ipynb
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &
fi

if [ "$HOSTNAME" != node-master ]; then
  gmond
fi


while :; do :; done & kill -STOP $! && wait $!
