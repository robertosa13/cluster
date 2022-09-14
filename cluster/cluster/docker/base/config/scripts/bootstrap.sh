#!/bin/bash

# Trecho que executará no master e nos workers. 
# Necesário para funcionamento do HDFS e para 
# comunicação dos containers/nodes.
/etc/init.d/ssh start

# Trecho que executará apenas no master.
if [[ $HOSTNAME = master ]]; then

    chmod a+x /user_data/admin/fiatlux.sh
    chmod a+x /user_data/admin/avertlux.sh
    chmod a+x /user_data/tfidf.sh 
    chmod a+x /user_data/stopwords.sh 
    chmod a+x /user_data/topk.sh 


    # Formata o namenode
    hdfs namenode -format

    .$HADOOP_HOME/sbin/start-dfs.sh
    .$HADOOP_HOME/sbin/start-yarn.sh
    .$SPARK_HOME/sbin/start-all.sh

    hdfs dfsadmin -report

    # Caso mantenha notebooks personalizados na pasta que tem bind mount com o 
    # container /user_data, o trecho abaixo automaticamente fará o processo de 
    # confiar em todos os notebooks, também liberando o server do jupyter de
    # solicitar um token
    # cd /user_data
    # jupyter trust *.ipynb
    # jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &

fi

while :; do sleep 2073600; done