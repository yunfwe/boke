---
title: MongoDB初探
date: 2018-02-27 10:12:00
categories: 
    - MongoDB
tags:
    - mongodb
    - nosql
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
---

## 简介
>   MongoDB 是一个基于分布式文件存储的数据库。由C++语言编写。旨在为WEB应用提供可扩展的高性能数据存储解决方案。MongoDB 是一个介于关系数据库和非关系数据库之间的产品，是非关系数据库当中功能最丰富，最像关系数据库的。他支持的数据结构非常松散，是类似json的bson格式，因此可以存储比较复杂的数据类型。Mongo最大的特点是他支持的查询语言非常强大，其语法有点类似于面向对象的查询语言，几乎可以实现类似关系数据库单表查询的绝大部分功能，而且还支持对数据建立索引。

<!-- more -->

## 环境
> 在 CentOS6.8 上使用MongoDB的二进制包 只要不是太古老的Linux系统都可以直接运行。也可以选择在Windows上使用MongoDB。


**各版本MongoDB下载地址**

|系统类型|下载地址|
|-|-|
|Linux|[点击打开](http://dl.mongodb.org/dl/linux/)|
|Windows|[点击打开](http://dl.mongodb.org/dl/win32/x86_64)|

下载合适的版本 这里使用`Linux`平台当前最新版 **3.6.3** [点此下载](http://downloads.mongodb.org/linux/mongodb-linux-x86_64-3.6.3.tgz)


## 入门篇

### 安装与启动

由于使用的是二进制版的`MongoDB`，直接解压就可以使用了。

```
tar xf mongodb-linux-x86_64-3.6.3.tgz -C /usr/local/
ln -s /usr/local/mongodb-linux-x86_64-3.6.3/ /usr/local/mongodb
mkdir /usr/local/mongodb/data
/usr/local/mongodb/bin/mongod --dbpath /usr/local/mongodb/
```

当显示`waiting for connections on port 27017`时`MongoDB`就成功启动了。
使用`Ctrl`+`C`停止`MongoDB`。

### 后台运行
> 如果想让`MongoDB`在后台运行 可以使用`--fork`

```
/usr/local/mongodb/bin/mongod --dbpath /usr/local/mongodb/data/ --fork --logpath /var/log/mongod.log
```

使用`--fork`必须配合`--logpath`指定日志输出位置。

使用`--bind_ip 0.0.0.0`可以将服务监听到所有网络 `--port`配置监听端口。

**注意**：3.6以前的版本默认是监听在`0.0.0.0`的，而3.6之后默认监听在`127.0.0.1`了。



### 配置环境变量

```
echo 'export PATH=/usr/local/mongodb/bin/:$PATH' > /etc/profile.d/mongodb.sh
source /etc/profile.d/mongodb.sh
```

这样就可以不用绝对路径来使用`mongo`相关的命令了。

使用`mongo`命令 进入`MongoDB`交互环境，使用`show dbs`列出当前默认数据库。

    > show dbs
    admin   0.000GB
    config  0.000GB
    local   0.000GB
    > 

到了这一步`MongoDB`就安装启动成功了，接下来就看看`MongoDB`如何使用的吧。

## 开发篇
> MongoDB使用JavaScript做shell，自MongoDB 2.4以后的版本采用V8引擎执行所有JavaScript代码，对于熟悉JavaScript的开发者MongoDB可以说是非常亲切了。

### 基本概念

MongoDB是一种非关系型数据库`(NoSQL)`，非关系型数据库以键值对`(key-value)`存储。
键可以理解为关系型数据库的字段名，值为字段值。但是它的结构是不固定的，关系型数据库的每一条记录的字段都是相同的，而NoSQL可以有不同的键，并且NoSQL值的类型都可以是不同的。

数据库的概念 MongoDB中和关系型数据库相同，使用`show dbs`看到的就是已经存在的数据库。
而表的概念在MongoDB中叫做`集合`，表中的一行数据 在MongoDB中叫`文档`。表字段在MongoDB中叫`键(key)`，表字段值在MongoDB中叫`值(value)`

**关系型数据库和非关系型数据库对比**

|对比项|MongoDB|MySQL|
|-|-|-|
|数据库|数据库|数据库|
|表格|集合|二维表|
|表记录|文档|一条记录|
|字段名|键|字段名|
|字段值|值|字段值|

题外话：MongoDB的数据库有点像Python中命令空间的概念，集合就是个列表，而文档就是一个字典了。字典里的键和值也对应着MongoDB的键和值。

**默认的数据库**

+ **admin** 类似于MySQL的默认mysql库 用于存放用户账户信息和权限。
+ **local**  这个库用于存放主从复制相关的数据
+ **config** 当MongoDB用于分片设置时 config数据库在内部使用，用于保存分片的相关信息


### 基本操作

#### 切换数据库

使用`db`命令查看当前使用的数据库，使用`use <DB>`切换数据库

    > show dbs
    admin   0.000GB
    config  0.000GB
    local   0.000GB
    > db
    test
    > 

MongoDB默认使用的是`test`库，可是`show dbs`为什么没有看到`test`库呢？是因为MongoDB不需要什么创建数据库的语句，也不需要创建表的语句，在需要的时候 也就是你向库中写入数据的时候，如果不存在则才会自动创建。

接下来切换到`mydb`中

```
use mydb
```

#### 集合中插入文档

MongoDB中也不需要显性的创建一个集合，直接向某个集合中插入文档就可以了，如果集合不存在 则会自动创建。

##### insert方法

比如我在一个名为`person`的集合插入一条文档数据

    > db.person.insert({"name":"xiaoming","age":21})
    WriteResult({ "nInserted" : 1 })
    >

现在看看库和集合是不是自动创建了呢

    > show dbs;
    admin   0.000GB
    config  0.000GB
    local   0.000GB
    mydb    0.000GB
    > show tables;
    person
    > 

#### 查询集合中的文档

##### find方法

再向集合中插入一个文档

    > db.person.insert({"name":"xiaohong","age":20})
    WriteResult({ "nInserted" : 1 })
    > db.person.find()
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaoming", "age" : 21 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    > 

使用`find`方法可以查看`person`集合中的所有文档，面向对象的操作方法 是不是感觉非常简单呢。
mongo会给每条文档自动生成`_id`键，这个可以理解为关系型数据库的主键。


`find`方法使用查询条件来过滤输出，相当于关系型数据库的`where`

##### 普通条件查询

查询`name`为`xiaoming`的文档

    > db.person.find({"name":"xiaoming"})
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaoming", "age" : 21 }
    > 

查询`age`小于`21`的文档

    > db.person.find({"age":{$lt:21}})
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    > 

小于等于使用`$lte`，大于使用`$gt`，大于等于使用`$gte`，不等于使用`$ne`

##### AND条件查询

查询`name`为`xiaoming` 并且`age`为`21`的文档

    > db.person.find({"name":"xiaoming","age":21})
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaoming", "age" : 21 }
    >


##### OR条件查询

查询`name`为`xiaoming` 或者`age`为`20`的文档，可以看到所有匹配的记录都被查到了。

    > db.person.find({$or:[{"name":"xiaoming"},{"age":20}]})
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaoming", "age" : 21 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    > 


##### AND和OR联合使用

类似于 `WHERE name="xiaohong" AND (name="xiaoming" OR age=20)`

    > db.person.find({"name":"xiaohong",$or:[{"name":"xiaoming"},{"age":20}]})
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    >


##### limit方法

使用`limit`方法可以只输出指定的文档条数

    > db.person.find()
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    { "_id" : ObjectId("5a952a2606b5ba9661fa06f1"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad106b5ba9661fa06f2"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad206b5ba9661fa06f3"), "name" : "xiaoming", "age" : 20 }
    > db.person.find().limit(2)
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    > 

##### skip方法

`skip`方法输出跳过多少条文档

    > db.person.find()
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    { "_id" : ObjectId("5a952a2606b5ba9661fa06f1"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad106b5ba9661fa06f2"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad206b5ba9661fa06f3"), "name" : "xiaoming", "age" : 20 }
    > db.person.find().skip(2)
    { "_id" : ObjectId("5a952a2606b5ba9661fa06f1"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad106b5ba9661fa06f2"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad206b5ba9661fa06f3"), "name" : "xiaoming", "age" : 20 }
    > 


##### sort方法

`sort`方法对数据进行排序。`sort`方法可以通过参数指定排序的字段，并使用 **1** 和 **-1** 来指定排序的方式，其中 **1** 为升序排列，而 **-1** 是用于降序排列。


    > db.person.find().sort({"age":1})
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    { "_id" : ObjectId("5a952ad206b5ba9661fa06f3"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    > db.person.find().sort({"age":-1})
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    { "_id" : ObjectId("5a952ad206b5ba9661fa06f3"), "name" : "xiaoming", "age" : 20 }
    > 



题外话：可以使用`db.person.find().pretty()`来美化数据输出格式。


#### 更新文档数据
> MongoDB中可以使用update和save方法来更新文档数据，两个方法的应用还是有些区别的。

##### update方法
> update方法 第一个参数是查询条件，第二个参数是要修改的键值

    将name为xiaoming的记录 age值修改为22

    > db.person.update({"name":"xiaoming"},{$set:{"age":22}})
    WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
    > db.person.find({"name":"xiaoming"})
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaoming", "age" : 22 }
    > 

需要注意的是 `update`默认只更新匹配到的第一条文档，如果想要更改所有匹配的 使用{multi:true}

    db.person.update({"name":"xiaoming"}, {$set:{"age":20}}, {multi:true})

从**3.2**版本开始，MongoDB提供了`updateOne()`来更新单个文档，`updateMany()`来更新多个文档。

##### save方法
> save方法直接传入一个新的文档保存到集合中，如果文档的_id存在 则会替换掉旧文档。

使用`save`方法

    > db.person.save({
        "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), 
        "name" : "xiaobai", "age" : 22 
    })
    WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
    > db.person.find()
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    > 

#### 删除文档
> 删除文档前 先使用find方法验证匹配条件是否正确是一个好习惯

##### remove方法
> remove方法默认会删除所有匹配的文档，第二个参数传入`{justOne: true}`则只会删除匹配的一个。

使用`remove`方法

    > db.person.find()
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    { "_id" : ObjectId("5a952a2606b5ba9661fa06f1"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad106b5ba9661fa06f2"), "name" : "xiaoming", "age" : 20 }
    { "_id" : ObjectId("5a952ad206b5ba9661fa06f3"), "name" : "xiaoming", "age" : 20 }
    > db.person.remove({"name":"xiaoming"})
    WriteResult({ "nRemoved" : 3 })
    > db.person.find()
    { "_id" : ObjectId("5a951e3a06b5ba9661fa06ef"), "name" : "xiaobai", "age" : 22 }
    { "_id" : ObjectId("5a951eb306b5ba9661fa06f0"), "name" : "xiaohong", "age" : 20 }
    > 

想要删除集合中的所有文档 可以使用`remove({})`。MongoDB官方推荐使用`deleteOne`和`deleteMany`来删除文档。

#### 删除集合

##### drop方法

    > db.person.drop()
    true
    > db.person.find()
    >


#### 删除数据库

##### dropDatabase方法

    > db.dropDatabase()
    { "dropped" : "mydb", "ok" : 1 }
    > show dbs
    admin   0.000GB
    config  0.000GB
    local   0.000GB
    > 

## 运维篇

### 权限控制
> 默认MongoDB是没有启用权限控制的，这样无疑非常不安全。

#### 添加管理员账号

    > use admin
    switched to db admin
    > db.createUser({user:"root",pwd:"123456",roles:[{"role":"root","db":"admin"}]})
    Successfully added user: {
        "user" : "root",
        "roles" : [
            {
                "role" : "root",
                "db" : "admin"
            }
        ]
    }
    > 


#### 修改启动参数

关闭MongoDB后重新启动
```
mongod --dbpath /usr/local/mongodb/data/ --fork --logpath /var/log/mongod.log --bind_ip 0.0.0.0 --auth
```
添加`--auth`参数则可以启用MongoDB的认证功能。

接下来重新连接MongoDB，看看操作是不是需要认证了。

    > use admin
    switched to db admin
    > show tables
    2018-02-28T07:57:45.759+0000 E QUERY    [thread1] Error: listCollections failed: {
        "ok" : 0,
        "errmsg" : "not authorized on admin to execute command { listCollections: 1.0, filter: {}, $db: \"admin\" }",
        "code" : 13,
        "codeName" : "Unauthorized"
    } 

#### 用户认证

使用`db.auth(user,password)`来进行登陆数据库。

    > use admin
    switched to db admin
    > db.auth("root","123456")
    1
    > show tables;
    system.users
    system.version
    > 

可以看到可以操作admin库了

#### 为其他库配置认证
> 需要注意的是 添加认证的库必须存在。

还是需要先切换到admin库中才能为其他库创建认证。

    > use admin
    switched to db admin
    > db.auth("root","123456")
    1
    > db.createUser({user:"op",pwd:"123456",roles:[{"role":"readWrite","db":"mydb"}]})
    Successfully added user: {
        "user" : "op",
        "roles" : [
            {
                "role" : "readWrite",
                "db" : "mydb"
            }
        ]
    }
    > 

退出后重新登陆MongoDB

    > use mydb
    switched to db mydb
    > show tables;
    2018-02-28T08:05:19.021+0000 E QUERY    [thread1] Error: listCollections failed: {
        "ok" : 0,
        "errmsg" : "not authorized on mydb to execute command { listCollections: 1.0, filter: {}, $db: \"mydb\" }",
        "code" : 13,
        "codeName" : "Unauthorized"
    }
    > db.auth("op","123456")
    1
    > db.person.find()
    { "_id" : ObjectId("5a96637de474606ab43c8e33") }
    { "_id" : ObjectId("5a966385e474606ab43c8e34"), "a" : 1 }
    > 


### 数据备份恢复
> 数据备份恢复对于数据库系统来说是个非常重要的话题。

#### 数据备份(mongodump)

命令用法如下:
`mongodump -h <HOST> -d <DB> -o <PATH>`

`-h` 指定连接的主机 格式是IP或者IP:PORT
`-d` 指定备份的库名
`-o` 指定备份的输出路径 默认是当前路径下的dump目录中

如果库需要认证的话 还需要使用`-u`和`-p`参数指定用户名和密码
如果不指定库名 则备份所有库。

比如:
```
mongodump -h 127.0.0.1:27017 -d mydb -o /tmp/dump
```

备份目标目录不存在会自动创建。

#### 数据恢复(mongorestore)

命令用法如下:
`mongorestore -h <HOST> -d <DB> <PATH>`

`-h` 指定连接的主机 格式是IP或者IP:PORT
`-d` 指定备份的库名
`<PATH>` 最后直接给出从哪恢复数据的目录

比如将刚才备份的mydb恢复到newdb中
```
mongorestore -h 127.0.0.1:27017 -d newdb /tmp/dump/mydb/
```

如果想恢复备份的所有库 可以不指定库名 然后指定所有库所在的父目录即可
```
mongorestore -h 127.0.0.1:27017  /tmp/dump/
```
这样子就会按照库名进行恢复了。


#### 其他备份恢复方式

MongoDB还提供了`mongoexport`和`mongoimport`工具对数据进行备份，可以将数据备份为csv, json的格式。

或者还可以停掉MongoDB的服务 直接对MongoDB的数据目录进行备份，注意备份后的目录还存在`mongod.lock`文件的话需要删除才能在新的库上启动，不过如果存在`mongod.lock`文件 倒是需要担心备份的数据是否完整了。

### MongoDB集群

#### MongoDB主从复制
> 主从复制提供了数据的冗余备份，提高了数据的可用性，并可以保证数据的安全性。官方已经不推荐使用主从复制方式，搭建MongoDB集群还有更好的方式。

**主从复制的好处**

* 提高数据安全性，多台服务器同时硬盘损坏的概率是小于单台的
* 数据的高可用性，多台服务器同时宕机的概率是小于单台的
* 灾难恢复能力，当发生硬盘损坏，数据还有副本以便恢复
* 热备份能力，无需关闭或者降级服务就可以对数据进行备份、压缩等。
* 分布式读取数据，读取请求可以分发到多台服务器，降低单实例的读写压力。

##### 主从复制原理

MongoDB的主从复制至少需要两个节点，一个`Master`节点，其他的都是`Slave`节点。

还记得MongoDB启动后默认的`local`这个库吗，当`Master`进行写操作时，`Master`将写操作记录在`local`库的`oplog`集合里。`Slave`节点就通过读取`Master`节点的`oplog`将数据复制到自身一份，并且还会将复制信息写入到自己的`oplog`中，这样即使是`Slave`节点 也可以将自己作为同步源给其他`Slave`节点了。

需要注意的是，`oplog`是有固定大小的，到达最大大小后，新的记录会覆盖掉旧的记录。


##### 主从复制配置
> 需要先关闭已经运行的MongoDB进程

**`Master`节点执行**
```
mongod --dbpath /usr/local/mongodb/data/ --fork --logpath /var/log/mongod.log --bind_ip 0.0.0.0 --master
```

可以看到只需要在主节点是添加`--master` 表示这一个`Master`节点就可以了。



**`Slave`节点执行**
```
mongod --dbpath /usr/local/mongodb/data/ --fork --logpath /var/log/mongod.log --bind_ip 0.0.0.0 --slave --source 192.168.8.253:27017
```

`Slave`节点添加`--slave` 并指明`Master`节点的地址`--source 192.168.8.253:27017`



##### 验证数据是否同步

**`Master`节点执行**

    > use mydb
    switched to db mydb
    > db.test.insert({"a":1})
    WriteResult({ "nInserted" : 1 })
    > 


**`Slave`节点执行**

    > rs.slaveOk()
    > use mydb
    switched to db mydb
    > db.person.find()
    { "_id" : ObjectId("5a9619088cd96bc4a16514a9"), "a" : 1 }
    > 

由于`Slave`节点默认是不允许读写的，所以需要执行`rs.slaveOk()`来允许读取。

#### MongoDB副本集
> `Replica Sets`方式，也是MongoDB官方推荐的方式。副本集方式比传统的主从复制改进的地方就是可以进行故障自动转移。如果主节点挂了，会自动选举一个从节点作为主，这个过程对用户是透明的。

##### 副本集原理

一个副本集即为服务于同一数据集的多个 MongoDB 实例，其中一个为主节点，其余的都为从节点。主节点上能够完成读写操作，从节点仅能用于读操作。主节点需要记录所有改变数据库状态的操作，这些记录 保存在local数据库的oplog中，各个从节点通过此 oplog来复制数据并应用于本地。

集群中的各节点还会通过传递心跳信息来检测各自的健康状况。当主节点故障时。多个从节点会触发一次新的选举操作，并选举其中的一个成为新的主节点(通常谁的优先级更高，谁就是新的主节点)。心跳信息默认每2秒传递一次。
副本集中的副本节点在主节点挂掉后通过心跳机制检测到后，就会在集群内发起主节点的选举机制，自动选举出一位新的主服务器。

副本集可以包括三种节点：**主节点**、**从节点**、**仲裁节点**。

1. 主节点负责处理客户端请求，读、写数据, 记录在其上所有操作的oplog;

2. 从节点定期轮询主节点的oplog进行同步数据。默认情况下从节点不支持客户端读取数据，但可以设置(`rs.slaveOk()`)；副本集的机制在于主节点出现故障的时候，余下的节点会选举出一个新的主节点，从而保证系统可以正常运行。

3. 仲裁节点不复制数据，仅参与投票。由于它没有访问的压力，比较空闲，因此不容易出故障。由于副本集出现故障的时候，存活的节点必须大于副本集节点总数的一半，否则无法选举主节点，或者主节点会自动降级为从节点，整个副本集变为只读。因此，增加一个不容易出故障的仲裁节点，可以增加有效选票，降低整个副本集不可用的风险。仲裁节点可多于一个。也就是说只参与投票，不接收复制的数据，也不能成为活跃节点。仲裁节点并非必须存在。

MongoDB 3.0之后官方推荐MongoDB副本集节点最少为3台，最多50台，仲裁节点最大为7个。为了避免脑裂发生 副本集成员最好为奇数。太多的副本集成员会增加复制成本，反而拖累整个集群。


##### 副本集配置
> 注意：`--dbpath`的路径如果已经存在数据 最好先清除。

**所有节点执行**
```
mongod --dbpath /usr/local/mongodb/data/ --fork --logpath /var/log/mongod.log --bind_ip 0.0.0.0 --replSet rstest
```

只需要在启动参数上增加`--replSet rstest`，`rstest`是副本集的名称。 

**登陆某个节点执行**

    > var cfg = {_id:"rstest",members:[ 
        {_id:0,host:'10.0.0.3:27017',priority:2}, 
        {_id:1,host:'10.0.0.4:27017',priority:1},   
        {_id:2,host:'10.0.0.5:27017',arbiterOnly:true}] 
    };
    > rs.initiate(cfg)
    {
        "ok" : 1,
        "operationTime" : Timestamp(1519793379, 1),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519793379, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }
    rstest:SECONDARY> 

将`10.0.0.3`的优先级配置为`2`，`10.0.0.5`配置为仲裁节点。
稍等一下，然后执行`rs.status()`方法看看`10.0.0.3`是否被选举为了`PRIMARY`


    "members" : [
            {
                "_id" : 0,
                "name" : "10.0.0.3:27017",
                "health" : 1,
                "state" : 1,
                "stateStr" : "PRIMARY",
                "uptime" : 228,
                "optime" : {
                    "ts" : Timestamp(1519794123, 1),
                    "t" : NumberLong(2)
                },
                "optimeDate" : ISODate("2018-02-28T05:02:03Z"),
                "electionTime" : Timestamp(1519793982, 1),
                "electionDate" : ISODate("2018-02-28T04:59:42Z"),
                "configVersion" : 1,
                "self" : true
            },


`rs.status()`方法可以详细的看到集群中每个节点的状态。


##### 验证副本集数据同步

**主节点插入数据**

    rstest:PRIMARY> use mydb
    switched to db mydb
    rstest:PRIMARY> db.person.insert({"a":1})
    WriteResult({ "nInserted" : 1 })
    rstest:PRIMARY>

**从节点验证数据**

    rstest:SECONDARY> rs.slaveOk()
    rstest:SECONDARY> show dbs;
    admin   0.000GB
    config  0.000GB
    local   0.000GB
    mydb    0.000GB
    rstest:SECONDARY> use mydb
    switched to db mydb
    rstest:SECONDARY> db.person.find()
    { "_id" : ObjectId("5a96386fe6101b17e4e221f0"), "a" : 1 }
    rstest:SECONDARY>


##### 验证副本集故障转移

**关闭主节点服务**

    rstest:PRIMARY> use admin
    switched to db admin
    rstest:PRIMARY> db.shutdownServer()


**登陆其他节点查看主节点是否更变**

    > rs.status()
        {
                "_id" : 1,
                "name" : "10.0.0.4:27017",
                "health" : 1,
                "state" : 1,
                "stateStr" : "PRIMARY",
                "uptime" : 812,
                "optime" : {
                    "ts" : Timestamp(1519794720, 1),
                    "t" : NumberLong(3)
                },
                "optimeDate" : ISODate("2018-02-28T05:12:00Z"),
                "electionTime" : Timestamp(1519794589, 1),
                "electionDate" : ISODate("2018-02-28T05:09:49Z"),
                "configVersion" : 1,
                "self" : true
            },

当原本的主节点上线后，会根据优先级重新选举，所以主节点就恢复到`10.0.0.3`上了。

##### 副本集的常用操作


###### 查看集群配置信息

`local`库的`system.replset`集合存放着集群所有节点的信息，也可以使用`rs.conf()`来查看

    > use local
    > db.system.replset.find().pretty()
    > rs.conf()

###### 重新配置副本集
> 注意：重新配置副本集必须在主节点上进行


更改主从节点的优先级，使用`rs.reconf()`方法重新加载配置

    rstest:PRIMARY> var cfg = {_id:"rstest",members:[ 
        {_id:0,host:'10.0.0.3:27017',priority:1}, 
        {_id:1,host:'10.0.0.4:27017',priority:2},
        {_id:2,host:'10.0.0.5:27017',arbiterOnly:true}] 
    };
    rstest:PRIMARY> rs.reconfig(cfg)
    {
        "ok" : 1,
        "operationTime" : Timestamp(1519795465, 1),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519795465, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }
    rstest:PRIMARY>

###### 动态添加和删除节点

添加从节点

    rstest:PRIMARY> rs.add("10.0.0.6:27017")
    {
        "ok" : 1,
        "operationTime" : Timestamp(1519796327, 1),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519796327, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }
    rstest:PRIMARY>

添加仲裁节点

    rstest:PRIMARY> rs.addArb("10.0.0.7:27017")
    {
        "ok" : 1,
        "operationTime" : Timestamp(1519796416, 1),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519796416, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }


删除节点

    rstest:PRIMARY> rs.remove("10.0.0.7:27017")
    {
        "ok" : 1,
        "operationTime" : Timestamp(1519796468, 1),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1519796468, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }

#### Mongodb分片集群
> `Sharding cluster`是一种可以水平扩展的模式，在数据量很大时特给力。

##### 分片集群原理

在数据量非常大的情况下，单台MongoDB数据库的性能会严重下降，而将数据分片可以很好的解决单台服务器磁盘空间、内存、CPU等硬件资源的限制问题。

把数据水平拆分出去，降低单节点的访问压力。每个分片都是一个独立的数据库，所有的分片组合起来构成一个逻辑上的完整的数据库。因此，分片机制降低了每个分片的数据操作量及需要存储的数据量，达到多台服务器来应对不断增加的负载和数据的效果。

一个分片集群需要三种角色

1. 分片服务器(Shard Server) mongod实例，用于存储实际的数据块。分片服务器可以是一个副本集集群共同来提供服务 防止单点故障。
2. 配置服务器(Config Server) mongod实例，存储整个集群和分片的元数据，就像是一本书的目录，保存的只是数据的分布表。
3. 路由服务器(Route Server) mongos实例，客户端由此接入，本身不存放数据，仅供程序连接，起到一个路由的作用。


分片集群在数据量非常大的情况下才能展现能力，这里只做简单讲解。


## 附录

### MongoDB配置文件

实验中启动MongoDB都是通过命令行参数的方式启动的，这样显然并不是很友好。
可以将参数写入到配置文件中，然后启动的时候通过`--config`或者`-f`启动。

比如 可以将参数写入以下配置文件

    dbpath = /usr/local/mongodb/data/
    fork = true
    logpath = /var/log/mongod.log
    bind_ip = 0.0.0.0
    auth = true

像`--fork`和`--auth` 启用就填`true`，禁用就填`false`

重新启动MongoDB

```
killall mongod
mongod -f mongod.conf
```

也可以登陆到MongoDB中，使用admin库的`shutdownServer`方法关闭服务。

    > use admin
    switched to db admin
    > db.shutdownServer()
    server should be down...
    2018-02-28T08:24:49.077+0000 I NETWORK  [thread1] trying reconnect to 127.0.0.1:27017 (127.0.0.1) failed
