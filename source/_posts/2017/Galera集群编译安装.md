---
title: Galera集群编译安装
date: 2017-08-06 09:03:00
categories: 
    - MySQL
tags:
    - MySQL
photos:
    - /uploads/photos/352ac65cb7ea.jpg
---

## <font color='#5CACEE'>简介</font>
> Galera是一种新型的高一致性MySQL集群架构，集成了Galera插件的MySQL集群，是一种新型的，数据不共享的，高度冗余的高可用方案。当有客户端要写入或者读取数据时，随便连接哪个实例都是一样的，读到的数据是相同的，写入某一个节点之后，集群自己会将新数据同步到其它节点上面，这种架构不共享任何数据，是一种高冗余架构。

<!-- more -->

## 环境
### 系统环境
> 系统使用 CentOS 6.8

### 软件环境

|源码包|版本|下载地址|
|-|-|-|
|mysql-wsrep|None|[点此自行选择合适的版本下载](http://galeracluster.com/downloads/)|



## 步骤
> 建议查看官方文档：http://galeracluster.com/documentation-webpages/installmysqlsrc.html

### 安装编译环境
```
yum -y install make gcc-c++ gcc cmake bison-devel ncurses-devel perl bison git automake \
autoconf libaio libaio-devel  scons  boost  boost-devel openssl-devel openssl check check-devel
```

### 编译mysql
> 自行下载集成wsrep补丁的MySQL后解压 这里使用MySQL 5.6的版本

```
cmake  \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql    \
-DMYSQL_DATADIR=/usr/local/mysql/data    \
-DSYSCONFDIR=/etc   \
-DWITH_WSREP=ON -DWITH_INNODB_DISALLOW_WRITES=ON ./

make -j10 && make install
```

### 编译galera插件
```
git clone https://github.com/codership/galera.git
cd galera
scons
strip libgalera_smm.so      # 裁剪库文件无用的调试信息 减小文件体积
mv libgalera_smm.so /usr/local/mysql/lib/plugin/
# 编译过程耗时较长 可以继续下面的步骤
```

### 初始化mysql运行环境
```
useradd mysql -M -s /sbin/nologin
chown -R mysql:mysql /usr/local/mysql
cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
cd /usr/local/mysql
strip bin/* lib/* lib/plugin/*      # 同样进行裁剪
scripts/mysql_install_db --datadir=/usr/local/mysql/data/ --user=mysql
echo /usr/local/mysql/lib > /etc/ld.so.conf.d/mysql5.6.conf
ldconfig -v |grep /usr/local/mysql/lib   # 查看/usr/local/mysql/lib是否被加入到系统运行库中
echo 'export PATH=$PATH:/usr/local/mysql/bin' > /etc/profile.d/mysql5.6.sh
source /etc/profile
mkdir -p /etc/mysql/conf.d
mkdir /var/lib/mysql
```
### 修改配置文件

**修改** `/etc/my.cnf`

    [mysql]
    !includedir /etc/mysql/conf.d/

**编辑** `/etc/mysql/conf.d/my_galera.cnf`

    [mysql]
    #设置mysql client default character
    default-character-set=utf8
    no-auto-rehash
    prompt="\\u@\\h:\\d \\r:\\m:\\s>"

    [mysqld]
    user=mysql
    bind-address=0.0.0.0
    character-set-server=utf8
    default-storage-engine=INNODB
    default-time-zone='+8:00'
    datadir=/usr/local/mysql/data/
    socket=/usr/local/mysql/data/mysql.sock
    skip-name-resolve

    #slow query
    slow_query_log=on
    log_output=FILE
    slow_query_log_file=slow_query.txt
    long_query_time=1

    max_connections=5000
    table_open_cache=2048
    sort_buffer_size=8M
    thread_cache_size=16
    #query_cache_size=32M  #galera: Do not use query cache
    # Try number of CPU's*2 for thread_concurrency
    thread_concurrency=8

    #MyISAM
    key_buffer_size=512M
    read_buffer_size=8M
    read_rnd_buffer_size=8M

    #InnoDB
    innodb_buffer_pool_size=1G
    innodb_additional_mem_pool_size=20M

    #galera innodb参数
    binlog_format=ROW
    innodb_autoinc_lock_mode=2
    innodb_flush_log_at_trx_commit=0
    transaction-isolation=READ-COMMITTED

    #galera cluster参数
    wsrep_provider=/usr/local/mysql/lib/plugin/libgalera_smm.so
    wsrep_provider_options="gcache.size=300M; gcache.page_size=1G"
    wsrep_sst_method=rsync
    wsrep_sst_auth=wsrep_sst-user:123456

    wsrep_cluster_name=MyCluster
    wsrep_cluster_address="gcomm://"
    wsrep_node_name=galera.node1
    wsrep_node_address="172.17.0.3"

**注意**：根据实际情况更改配置文件，第一个启动的节点`wsrep_cluster_address`的值为`gcomm://`，其他节点启动的时候要将这个值改为第一个节点的IP 比如`gcomm://172.17.0.3`。
`wsrep_node_address`修改为自己的IP就好了

### 启动集群
> 先启动集群的第一个节点 也就是`wsrep_cluster_address`的值为`gcomm://`的那个节点，然后依次启动其他的就好了。

```
service mysqld start
```

## 附录

Galera集群好像并不是那么可靠。。。 机器的数据越多 性能的提升率就越低。

参考文章：http://www.sohu.com/a/147032902_505779