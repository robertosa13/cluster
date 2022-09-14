# Cluster Big Data:

O objetivo deste repositório é funcionar como um mini-cluster, tendo todas as configurações básicas realizadas para as tecnologias distribuídas como Hadoop e Spark (até então). Pode-se utilizá-lo como referência para configurações, ou mesmo como uma ferramenta para análises exploratórias de datasets de interesse. A constituição deste repositório levou em conta os trabalhos <a href="https://lemaizi.com/blog/creating-your-own-micro-cluster-lab-using-docker-to-experiment-with-spark-dask-on-yarn/">Amine Lemaizi</a> e <a href="https://github.com/gbieul/spyrk-cluster">Gabriel (gbieul)</a>. 

Versões: 
- Hadoop 3.3.3
- Spark 3.0.0

Nas sessões abaixo há referências sobre a prória estrutura do diretório e das principais configurações.

Recursos:
- HDFS
- Spark
- Modo cluster ou interativo
- Bibliotecas Python




## 1.1. - A árvore do diretório

    .
    ├── README.md
    ├── docker-compose.yml
    ├── Makefile
    ├── docker
    │   ├── spark-base
    │   │   ├── Dockerfile
    │   │   └── config
    │   │       ├── config
    │   │       ├── hadoop
    │   │       │   ├── core-site.xml
    │   │       │   ├── hadoop-env.sh
    │   │       │   ├── hdfs-site.xml
    │   │       │   ├── mapred-site.xml
    │   │       │   └── yarn-site.xml
    │   │       ├── jupyter
    │   │       │   └── requirements.txt
    │   │       ├── kafka
    │   │       │   └── server.properties
    │   │       ├── scripts
    │   │       │   └── bootstrap.sh
    │   │       ├── spark
    │   │       │   ├── log4j.properties
    │   │       │   └── spark-defaults.conf
    │   │       └── zookeeper
    │   │           └── zoo.cfg
    │   ├── spark-master
    │   │   ├── Dockerfile
    │   │   └── config
    |   |       ├── hadoop
    |   |       |   ├── masters
    |   |       |   └── slaves
    │   │       └── hive
    │   │           └── hive-site.xml
    │   └── spark-worker
    │       ├── Dockerfile
    │       └── config
    │           └── hive
    │               └── hive-site.xml
    ├── images
    │   ├── arquitetura.png
    │   ├── namenode_webui.png
    │   ├── resource_manager.png
    │   └── resource_node_manager.png
    └── user_data
        └── spark-submit.py

Na raíz do diretório estão presentes os arquivos build-images.sh, que faz o build das imagens
docker deste repositório, o arquivo docker-compose.yml, que define a stack com o docker que é
usada com este mini-laboratório, bem como este arquivo README.

No sub-diretório `/docker` constam as imagens docker que funcionam como base e, oriunda desta, as
imagens do master e worker. No sub-diretório `/docker/spark-base`, também consta outro sub-diretó-
rio chamado `docker/spark-base/config`, que tem em cada diretório arquivos de configuração das 
tecnologias usadas aqui. Mais sobre isso abaixo.

Em `/env` consta o arquivo `spark-worker.sh` que cuida de algumas configurações quando lançamos a
stack do docker-compose (pode conferir no arquivo `docker-compose.yml` onde a referência a este
arquivo aparece).

Em `images` existem as imagens mostradas neste diretório e, finalmente, em `user_data` temos alguns
arquivos de exemplo. **Importantíssimo notar:** neste diretório temos um _bind mount_ com o diretório
`/user_data` dentro do container. Dessa maneira, temos o container exposto para testes com quaisquer
arquivos locais que queiramos.

## 1.2. A arquitetura simulada

![Arquitetura simplificada do cluster](images/arquitetura.png?raw=true "Arquitetura Simplificada")

Aqui, para questões de simplicidade (e economia de recursos), temos simulado um cluster composto de
um node master e dois nodes workers, cada qual com seus respectivos serviços.

Anteriormente se tinham três workers, mas por economia de recursos optou-se por se reduzir um worker.


## 1.3. Configurações do cluster

### 1.3.1. slaves
Path: `/docker/spark-base/config/hadoop/slaves`

    worker-1
    worker-2
    worker-3

Neste arquivo estão as referências aos nodes do cluster. Estes nomes conferem com os nomes do containers.

### 1.3.2. core-site.xml
Path: `/docker/spark-base/config/hadoop/core-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
            <property>
                <name>fs.default.name</name>
                <value>hdfs://master:9000</value>
            </property>
    </configuration>

Neste arquivo definimos quem é o master. O valor `spark-master` se refere ao nome do container do master.

### 1.3.3. hdfs-site.xml
Path: `/docker/spark-base/config/hadoop/hdfs-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>/usr/hadoop-3.3.3/data/nameNode</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>/usr/hadoop-3.3.3/data/dataNode</value>
        </property>
        <property>
                <name>dfs.replication</name>
                <value>2</value>
        </property>
    </configuration>

Aqui definimos algumas propriedades do HDFS, como onde estarão informações relativas ao Namenode ou ao Datanode. Importante notar que o path `/usr/hadoop-3.3.3/` é o mesmo path definido como `HADOOP_HOME` no topo do arquivo `/docker/spark-base/Dockerfile`. Também se define `dfs.replication` como o nível de replicação de cada bloco no HDFS.

### 1.3.4. yarn-site.xml
Path: `/docker/spark-base/config/hadoop/yarn-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
            <property>
                    <name>yarn.acl.enable</name>
                    <value>0</value>
            </property>
            <property>
                    <name>yarn.resourcemanager.hostname</name>
                    <value>master</value>
            </property>
            <property>
                    <name>yarn.nodemanager.aux-services</name>
                    <value>mapreduce_shuffle</value>
            </property>
            <property>
                    <name>yarn.nodemanager.resource.cpu-vcores</name>
                    <value>1</value>
            </property>
            <property>
                    <name>yarn.nodemanager.resource.memory-mb</name>
                    <value>1500</value>
            </property>
            <property>
                    <name>yarn.scheduler.minimum-allocation-mb</name>
                    <value>750</value>
            </property>
            <property>
                    <name>yarn.scheduler.maximum-allocation-mb</name>
                    <value>1500</value>
            </property>
            <property>
                    <name>yarn.nodemanager.vmem-check-enabled</name>
                    <value>false</value>
            </property>
            <property>
                    <name>yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage</name>
                    <value>99.0</value>
            </property>
    </configuration>

Aqui temos algumas definições de uso de recursos do yarn, bem como a definição de quem é o master em `yarn.resourcemanager.hostname`. Note que o valor `spark-master` aqui também é o nome do container do master.

O parâmetro `yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage` aqui é adicionado para se evitar erros de uso de disco ao se trabalhar com o host, mas se recomenda verificação do melhor valor ao se usar com um cluster realmente distribuído.

### 1.3.5. mapred-site.xml
Path: `/docker/spark-base/config/hadoop/mapred-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
        <property>
            <name>mapreduce.framework.name</name>
            <value>yarn</value>
        </property>
        <property>
            <name>yarn.app.mapreduce.am.env</name>
            <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
        </property>
        <property>
            <name>mapreduce.map.env</name>
            <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
        </property>
        <property>
            <name>mapreduce.reduce.env</name>
            <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
        </property>
        <property>
            <name>mapreduce.map.memory.mb</name>
            <value>750</value>
        </property>
        <property>
            <name>mapreduce.reduce.memory.mb</name>
            <value>1500</value>
        </property>
        <property>
            <name>mapreduce.map.java.opts</name>
            <value>-Xmx600m</value>
        </property>
        <property>
            <name>mapreduce.reduce.java.opts</name>
            <value>-Xmx1200m</value>
        </property>
        <property>
            <name>yarn.app.mapreduce.am.resource.mb</name>
            <value>1500</value>
        </property>
        <property>
            <name>yarn.app.mapreduce.am.command-opts</name>
            <value>-Xmx1200m</value>
        </property>
    </configuration>


### 1.3.6. spark-defaults.conf
Path: `/docker/spark-base/config/spark/spark-defaults.conf`

    spark.master                     yarn

    spark.driver.memory              600m
    spark.executor.memory            550m

    # Isso deve ser menor que o parametro yarn.nodemanager.resource.memory-mb (no arquivo yarn-site.xml)
    spark.yarn.am.memory             300m

    # Opções: cluster ou client
    spark.submit.deployMode          client

Este arquivo contém algumas configurações padrão do Spark. Importante notar que `spark.master` está configurado como `yarn`, desabilitando, assim, o standalone mode; e que `spark.submit.deployMode` aqui está configurado como `client`, podendo assumir também o valor `cluster` se a intenção for testar jobs via `spark-submit`. Aqui, por padrão, temos o modo interativo habilitado.

Além disso, notar a observação sobre a necessidade de que `spark.yarn.am.memory` tenha um valor menor do que `yarn.nodemanager.resource.memory-mb` do `yarn-site.xml`.


## 1.4. Acessando serviços no navegador

`http://localhost:8088/cluster` - Resource Manager

`http://localhost:8088/cluster` - Resource Manager - Visão de recursos

`http://localhost:50070` - NameNode WebUI