---
title: MongoDB分片集群
date: 2018-03-02 10:12:00
categories: 
    - MongoDB
tags:
    - MongoDB
    - NoSQL
photos:
    - /uploads/photos/2015112714373538.jpg
---

## 简介
> 当面对海量数据的时候，单台MongoDB的承受能力显然达不到数据要求。分片(Sharding)是MongoDB将大型的集合分割到不同服务器上的方法。分片起源于关系型数据库的分区，但是和关系型数据库的分区相比，MongoDB已经帮用户做了所有能自动完成的事情。MongoDB会自动将需要分片的集合均衡的分布到不同的服务器上，配合副本集保障了数据的可用性和安全性，而这一切对用户都是透明的。

<!-- more -->

	
## 概念

### 分片的目的

高数据量和吞吐量的数据库应用会对单机的性能造成较大压力。随着数据的增大，单台MongoDB的QPS会严重下降。较大的查询甚至会将单机的CPU和内存资源耗尽。
为了解决MongoDB的性能问题，一般有两种解决方法：**垂直扩展**和**水平扩展**。

**垂直扩展** 就是升级服务器的硬件，增加更多的CPU，增加更大的内存。但是这种方法很容易就达到硬件提升的瓶颈，而且可能需要付出更高的代价。
**水平扩展** 就是一台服务器不行就多台，将数据分布到多个服务器上，需要查询数据的时候根据相应的算法知道数据存放在哪台服务器上就可以了。

### 分片的设计

一个MongoDB分片集群有三种角色

1. **分片服务器**(Shard Server) mongod实例，用于存储实际的数据块。分片服务器可以是一个副本集集群共同来提供服务 防止单点故障。
2. **配置服务器**(Config Server) mongod实例，存储整个集群和分片的元数据，就像是一本书的目录，保存的只是数据的分布表。
3. **路由服务器**(Route Server) mongos实例，客户端由此接入，本身不存放数据，仅供程序连接，起到一个路由的作用。

路由服务器对整个MongoDB分片集群进行了抽象，用户访问mongos提供的监听就像访问一个mongod一样。而分片服务器使用副本集来保障了数据的可用性和安全性。分片集群还提供了良好的扩展能力，随着数据量增大可以方便的增加分片服务器来扩展整个集群的容量。

用户对分片集群一次完整的读取数据过程如下：
![](/uploads/2018/mongodb/h34achz523xvc160.png)

### 数据分发

在MongoDB分片集群中，将集合的数据拆分成**块(chunk)**，然后将块分不到不同的分片服务器上。
MongoDB的块大小默认是`64M`，大于`64M`的块将自动分裂为两个较小的块。MongoDB内置均衡器(balancer)就是用于拆分块和分发块的。

块的分发主要有两种方式：**基于块的数量的分发** 和 **基于片键范围的定向分发**

#### 基于块的数量的分发

MongoDB内置均衡器按照集合的索引字段来进行数据分发，该字段叫做**片键(sharded key)**
片键一般有三种类型：**升序片键**，**随机片键**和**基于分组的片键**。

##### 升序片键

升序片键类似自增长的ID。假如集合foo有10个文档，1-4的文档所在块在分片服务器A上，5-8的文档所在块在分片服务器B上，9-10的文档所在块在分片服务器C上。当有新的文档需要写入时会插入到C服务器上所在的块，当块的大小超过限制后会分裂为两个块，分裂后的旧数据所在块可能会移动到其他服务器，继续新增的数据还会插入到拥有最大ID的块，导致所有的写请求都被路由到了C分片服务器上，数据写入不均匀。

但是如果按照片键进行范围读取时，数据可能都在同一个块上，读取的性能就比较高了。

##### 随机片键

随机片键是指片键的值不是固定增长，而是一些没有规律的键值。由于写入数据是随机分发的，各分片增长的速度大致相同，减少了chunk 迁移的次数。使用随机分片的弊端是：写入的位置是随机的，如果使用Hash Index来产生随机值，那么范围查询的速度会很慢。

##### 基于分组的片键

基于分组的片键是两字段的复合片键，第一个字段用于分组，第二个字段用于自增，所以第二个字段最好是自增字段。这种片键策略是最好的，能够实现多热点数据的读写。

选择合适的片键需要对项目是写为主还是读为主的权衡。

#### 基于片键范围的定向分发

如果希望特定范围的块被分发到特定的分片服务器中，可以为分片添加标签，然后为标签指定相应的片键范围，这样，如果一个文档属于某个标签的片键范围，就会被定向到特定的分片服务器中了。

## 环境

使用三台测试机来搭建环境 使用不同的端口号来启动不同的MongoDB实例。

### 系统环境

| 主机名  | 系统       | IP       |
| ------- | :--------: | -------: |
| mongo-A | CentOS 6.8 | 10.0.0.3 |
| mongo-B | CentOS 6.8 | 10.0.0.4 |
| mongo-C | CentOS 6.8 | 10.0.0.5 |

### 拓扑结构

| mongo-A           | mongo-B           | mongo-C             |
| :---------------: | :---------------: | :-----------------: |
| Mongos            | Mongos            | Mongos              |
| Config Server     | Config Server     | Config Server       |
| Shard Server 1 主 | Shard Server 1 备 | Shard Server 1 仲裁 |
| Shard Server 2 主 | Shard Server 2 备 | Shard Server 2 仲裁 |
| Shard Server 3 主 | Shard Server 3 备 | Shard Server 3 仲裁 |

### 服务信息

| 角色           | 数据目录  | 端口  | 副本集名称 |
| -------------- | --------- | ----- | ---------- |
| Mongos         | None      | 27017 | None       |
| Config Server  | /data/cs  | 20000 | cs         |
| Shard Server 1 | /data/ss1 | 21001 | ss1        |
| Shard Server 2 | /data/ss2 | 21002 | ss2        |
| Shard Server 3 | /data/ss3 | 21003 | ss3        |


## 步骤

### 安装MongoDB

这里使用`Linux`平台当前最新版 **3.6.3** [点此下载](http://downloads.mongodb.org/linux/mongodb-linux-x86_64-3.6.3.tgz)

所有节点全部执行
```
tar xf mongodb-linux-x86_64-3.6.3.tgz -C /usr/local/
ln -s /usr/local/mongodb-linux-x86_64-3.6.3/ /usr/local/mongodb
mkdir -p /data/{cs,ss1,ss2,ss3}
echo 'export PATH=/usr/local/mongodb/bin/:$PATH' > /etc/profile.d/mongodb.sh
source /etc/profile.d/mongodb.sh
```

### 配置分片集群

#### 启动服务

所有节点执行
```
mongod --configsvr --dbpath /data/cs --fork --logpath /var/log/mongodcs.log --bind_ip 0.0.0.0 --port 20000 --replSet cs 
mongod --shardsvr --dbpath /data/ss1 --fork --logpath /var/log/mongodss1.log --bind_ip 0.0.0.0 --port 21001 --replSet ss1
mongod --shardsvr --dbpath /data/ss2 --fork --logpath /var/log/mongodss2.log --bind_ip 0.0.0.0 --port 21002 --replSet ss2
mongod --shardsvr --dbpath /data/ss3 --fork --logpath /var/log/mongodss3.log --bind_ip 0.0.0.0 --port 21003 --replSet ss3
```

#### 配置Config Server

随便连接到一个服务器的20000端口
```
mongo 127.0.0.1:20000
```

初始化Config Server，在mongo中执行以下代码

```javascript
var cfg = {_id:"cs", configsvr:true, members:[ 
        {_id:0,host:'10.0.0.3:20000'}, 
        {_id:1,host:'10.0.0.4:20000'},   
        {_id:2,host:'10.0.0.5:20000'}
    ]};
rs.initiate(cfg)
```

结果输出：

    > rs.initiate(cfg)
    {
        "ok" : 1,
        "operationTime" : Timestamp(1519896701, 1),
        "$gleStats" : {
            "lastOpTime" : Timestamp(1519896701, 1),
            "electionId" : ObjectId("000000000000000000000000")
        },
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519896701, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }

#### 配置Shard Server 1

连接mongo-A的21001端口
```
mongo 10.0.0.3:21001
```

初始化Shard Server 1
```javascript
var cfg = {_id:"ss1",members:[ 
        {_id:0,host:'10.0.0.3:21001',priority:2}, 
        {_id:1,host:'10.0.0.4:21001',priority:1},   
        {_id:2,host:'10.0.0.5:21001',arbiterOnly:true}] 
    };
rs.initiate(cfg)
```

#### 配置Shard Server 2

接着连接mongo-A的21002端口
```
mongo 10.0.0.3:21002
```

初始化Shard Server 2
```javascript
var cfg = {_id:"ss2",members:[ 
        {_id:0,host:'10.0.0.3:21002',priority:2}, 
        {_id:1,host:'10.0.0.4:21002',priority:1},   
        {_id:2,host:'10.0.0.5:21002',arbiterOnly:true}] 
    };
rs.initiate(cfg)
```

#### 配置Shard Server 3

连接mongo-A的21003端口
```
mongo 10.0.0.3:21003
```

初始化Shard Server 3
```javascript
var cfg = {_id:"ss3",members:[ 
        {_id:0,host:'10.0.0.3:21003',priority:2}, 
        {_id:1,host:'10.0.0.4:21003',priority:1},   
        {_id:2,host:'10.0.0.5:21003',arbiterOnly:true}] 
    };
rs.initiate(cfg)
```

#### 配置mongos路由服务

选择一台服务器当作mongos路由服务，这里使用mongo-A

在mongo-A上执行
```
mongos --configdb cs/10.0.0.3:20000,10.0.0.4:20000,10.0.0.5:20000 --fork --logpath /var/log/mongos.log --bind_ip 0.0.0.0
```

mongos默认监听27017端口 也是mongod默认监听的端口

#### 添加分片服务器到集群

登陆路由服务
```
mongo 10.0.0.3:27017
```

添加分片服务器到集群
```javascript
sh.addShard("ss1/10.0.0.3:21001,10.0.0.4:21001,10.0.0.5:21001")
sh.addShard("ss2/10.0.0.3:21002,10.0.0.4:21002,10.0.0.5:21002")
sh.addShard("ss3/10.0.0.3:21003,10.0.0.4:21003,10.0.0.5:21003")
```

使用`sh.status()`查看集群状态

    mongos> sh.status()
    --- Sharding Status --- 
    sharding version: {
        "_id" : 1,
        "minCompatibleVersion" : 5,
        "currentVersion" : 6,
        "clusterId" : ObjectId("5a97c88a1b0ab73e5d64fc6c")
    }
    shards:
            {  "_id" : "ss1",  "host" : "ss1/10.0.0.3:21001,10.0.0.4:21001",  "state" : 1 }
            {  "_id" : "ss2",  "host" : "ss2/10.0.0.3:21002,10.0.0.4:21002",  "state" : 1 }
            {  "_id" : "ss3",  "host" : "ss3/10.0.0.3:21003,10.0.0.4:21003",  "state" : 1 }
    active mongoses:
            "3.6.3" : 1
    autosplit:
            Currently enabled: yes
    balancer:
            Currently enabled:  yes
            Currently running:  no
            Failed balancer rounds in last 5 attempts:  0
            Migration Results for the last 24 hours: 
                    No recent migrations
    databases:
            {  "_id" : "config",  "primary" : "config",  "partitioned" : true }

    mongos>


至此MongoDB分片集群就搭建完了。

### 数据库的分片配置

#### 激活数据库的分片功能

激活`mydb`的分片功能

```
sh.enableSharding("mydb")
```

    mongos> sh.enableSharding("mydb")
    {
        "ok" : 1,
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519954632, 6),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        },
        "operationTime" : Timestamp(1519954632, 6)
    }
    mongos>

#### 测试升序片键

对`mydb`库的`test`集合进行分片，然后插入100000条数据

```javascript
use mydb
sh.shardCollection("mydb.test",{id:1})
for (var i = 1; i <= 100000; i++){
    db.test.insert({"id":i,"name":"xiaoming","age":22,"data":new Date()})
}
```

可以看到`test`集合的数据都集中在`ss3`副本集上。

    mongos> db.test.stats()
    {
        "sharded" : true,
        "capped" : false,
        "ns" : "mydb.test",
        "count" : 100000,
        "size" : 8000000,
        "storageSize" : 2519040,
        "totalIndexSize" : 2592768,
        "indexSizes" : {
            "_id_" : 942080,
            "id_1" : 1650688
        },
        "avgObjSize" : 80,
        "nindexes" : 2,
        "nchunks" : 1,
        "shards" : {
            "ss3" : {
                "ns" : "mydb.test",
                "size" : 8000000,
                "count" : 100000,
                "avgObjSize" : 80,
                "storageSize" : 2519040,
                "capped" : false,
                "wiredTiger" : {
                    "metadata" : {
                        "formatVersion" : 1
                    },



#### 测试哈希片键

使用哈希片键的方式重新插入100000条数据

```javascript
use mydb
db.test.drop()
sh.shardCollection("mydb.test",{id:"hashed"})
for (var i = 1; i <= 100000; i++){
    db.test.insert({"id":i,"name":"xiaoming","age":22,"data":new Date()})
}
```

再次使用`db.test.stats()`可以看到文档已经分散到三个副本集了。

    mongos> db.test.stats()
    {
        "sharded" : true,
        "capped" : false,
        "ns" : "mydb.test",
        "count" : 100000,
        "size" : 8000000,
        "storageSize" : 2572288,
        "totalIndexSize" : 4280320,
        "indexSizes" : {
            "_id_" : 1040384,
            "id_hashed" : 3239936
        },
        "avgObjSize" : 80,
        "nindexes" : 2,
        "nchunks" : 6,
        "shards" : {
            "ss1" : {
                "ns" : "mydb.test",
                "size" : 2700400,
                "count" : 33755,
                "avgObjSize" : 80,
                "storageSize" : 868352,
                "capped" : false,
                "wiredTiger" : {
                    "metadata" : {
                        "formatVersion" : 1
                    },
            ...
            "ss2" : {
                "ns" : "mydb.test",
                "size" : 2651440,
                "count" : 33143,
                "avgObjSize" : 80,
                "storageSize" : 851968,
                "capped" : false,
                "wiredTiger" : {
                    "metadata" : {
                        "formatVersion" : 1
                    },
            ...
            "ss3" : {
                "ns" : "mydb.test",
                "size" : 2648160,
                "count" : 33102,
                "avgObjSize" : 80,
                "storageSize" : 851968,
                "capped" : false,
                "wiredTiger" : {
                    "metadata" : {
                        "formatVersion" : 1
                    },


### 分片集群的管理

#### 集群添加分片服务器

```javascript
sh.addShard("ss1/10.0.0.3:21001,10.0.0.4:21001,10.0.0.5:21001")
```

#### 从集群中移除分片服务器

```javascript
use admin
db.runCommand({removeshard:"ss1"})
```

需要注意的是，如果要移除的分片服务器是某个集合的主键，需要先将数据移到其他节点。

#### 查看集群状态

```javascript
sh.status()
```


## 附录