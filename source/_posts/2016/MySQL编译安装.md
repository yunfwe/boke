---
title: MySQL编译安装
date: 2016-04-01 10:12:00
categories: MySQL
tags:
    - 关系型数据库
    - LNMP
    - mysql
---
## <font color='#5CACEE'>简介</font>
> MySQL是一个关系型数据库管理系统，由瑞典MySQL AB 公司开发，目前属于 Oracle 旗下公司。MySQL 最流行的关系型数据库管理系统，在 WEB 应用方面MySQL是最好的 RDBMS (Relational Database Management System，关系数据库管理系统) 应用软件之一。
MySQL是一种关联数据库管理系统，关联数据库将数据保存在不同的表中，而不是将所有数据放在一个大仓库内，这样就增加了速度并提高了灵活性。
MySQL所使用的 SQL 语言是用于访问数据库的最常用标准化语言。
<!-- more -->MySQL 软件采用了双授权政策，它分为社区版和商业版，由于其体积小、速度快、总体拥有成本低，尤其是开放源码这一特点，一般中小型网站的开发都选择 MySQL 作为网站数据库。
由于其社区版的性能卓越，搭配 PHP 和 Apache 可组成良好的开发环境  
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=AZBRVGRxT-bTnepDp1kUWBEq3AdAeDNtWu6X2ud8bF1X7qwNWnEPLYUcqca3idKMTM-Mj5N4ldZnRyNO7ijn-U3i73p5AbDQ_yPiWidwPGy)



## <font color='#5CACEE'>环境</font>
> 初始化系统编译环境 选择合适的MySQL版本进行下载 实验用CentOS 6.7 编译安装 MySQL-5.6.28
MySQL5.7对cmake最低版本要求是2.8.2 如果cmake版本不够 需升级cmake 

    yum -y install make gcc-c++ gcc cmake bison-devel ncurses-devel perl

|软件名称|版本号|下载地址|
|-|:-:|-:|
|mysql|5.5.47|[<font color='#AAAAAA'>点击下载</font>](http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.5.47.tar.gz)|
|mysql|5.6.28|[<font color='#AAAAAA'>点击下载</font>](http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz)|
|mysql|5.7.11|[<font color='#AAAAAA'>点击下载</font>](http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.11.tar.gz)|


## <font color='#5CACEE'>步骤</font>

### <font color='#CDAA7D'>开始编译</font>
> MySQL 5.5和5.6版本编译过程差不多 5.7版本开始依赖boost库 
链接中5.7的下载地址是已经包含了boost头文件的源码包

```bash
tar xf mysql-5.6.28.tar.gz
cd mysql-5.6.28
cmake  \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql    \
-DMYSQL_DATADIR=/usr/local/mysql/data    \
-DSYSCONFDIR=/etc   \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
# -DWITH_BOOST=boost       # 注意 MySQL5.7需要开启此选项
make -j4                   # MySQL编译是个比较慢的过程 这里启动四个进程去并行编译
make install               # MySQL被安装到/usr/local/mysql中
```

### <font color='#CDAA7D'>配置运行环境</font>
```bash
useradd mysql -M -s /sbin/nologin       # 创建mysql运行用户 默认同时创建组
chown -R mysql:mysql /usr/local/mysql   # 更改mysql基础目录的所有者
cd /usr/local/mysql
scripts/mysql_install_db --datadir=/usr/local/mysql/data/ --user=mysql

# MySQL5.7版本通过 mysqld --initialize 进行初始化数据库
# bin/mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data/
# 初始化后会生成一个随机的密码 记住这个随机密码
# [Note] A temporary password is generated for root@localhost: h<iJP>aU2C,9

echo /usr/local/mysql/lib > /etc/ld.so.conf.d/mysql5.6.conf
ldconfig -v |grep /usr/local/mysql/lib   # 查看/usr/local/mysql/lib是否被加入到系统运行库中
echo 'export PATH=$PATH:/usr/local/mysql/bin' > /etc/profile.d/mysql5.6.sh
source /etc/profile                      # 将mysql等命令加入到环境变量 并立即生效
cp support-files/my-default.cnf /etc/my.cnf         # 提供配置文件 
cp support-files/mysql.server /etc/init.d/mysqld    # 提供mysqld服务控制脚本
```

    vim /etc/my.cnf                     # 修改如下内容

    basedir = /usr/local/mysql          # mysql基础目录
    datadir = /usr/local/mysql/data     # mysql数据库目录
    port = 3306                         # 服务监听端口
    
### <font color='#CDAA7D'>启动服务</font>
```bash
/etc/init.d/mysqld start
service mysqld start
mysqld_safe &               # 三种方式均可启动服务
```

    如果服务启动失败 查看MySQL错误日志
    默认路径为：/usr/local/mysql/data/`hostname`.err
    输入mysql 查看是否正常连接
    
    [root@8be3d6481fd9 data]# mysql
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 2
    Server version: 5.6.28 Source distribution

    Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> 
    
    
    MySQL5.7 需要通过这个随机密码登录 而且登录后必须修改密码才能正常使用
    
    [root@8be3d6481fd9 data] # mysql -uroot -p
    Enter password: 
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 2
    Server version: 5.7.11

    Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql>set password=password('yourpassword');

    下次就可以通过新密码登录了 "set password=password('');" 可以配置空密码


## <font color='#5CACEE'>附录</font>
    MySQL授权远程登录用户 这样就可以在其他主机远程登录MySQL了
    grant all privileges on *.* to "user"@"%" identified by "password";
    
    MySQL忘记登录密码处理
    先停掉原来的服务 通过跳过授权表 不使用网络连接启动mysql
    mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
    
    直接通过mysql命令登录 然后修改mysql.user表的信息
    update mysql.user set password=password('yourpasswd') where user='root';
    
    MySQL5.7 的密码字段为authentication_string
    update mysql.user set authentication_string=password('yourpasswd') where user='root';
    
    通过修改/etc/my.cnf可以修改mysql的数据库目录等位置 修改完数据库位置后可能需要重新初始化数据库
    