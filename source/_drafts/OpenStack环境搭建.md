---
title: OpenStack环境搭建
date: 2018-02-03 09:05:00
categories: 
    - OpenStack
tags:
    - OpenStack
photos:
    - /uploads/photos/j8de72deu29.jpg
---

## <font color='#5CACEE'>简介</font>
>OpenStack是一个开源的云计算管理平台项目，由几个主要的组件组合起来完成具体工作。OpenStack支持几乎所有类型的云环境，项目目标是提供实施简单、可大规模扩展、丰富、标准统一的云计算管理平台。OpenStack通过各种互补的服务提供了基础设施即服务（IaaS）的解决方案，每个服务提供API以进行集成。

<!-- more -->

	
## <font color='#5CACEE'>环境</font>
> 由于OpenStack的在ubuntu上安装的文档较多 所以决定将OpenStack控制服务安装到ubuntu上


## <font color='#5CACEE'>步骤</font>

### <font color='#CDAA7D'>OpenStack基本控制服务组件简介</font>
> OpenStack的控制服务组件主要有计算、网络、存储与管理这四大类，涉及十多个组件。但是并不一定要全部安装，安装一些必须的组件后就可以构建一个可靠的环境了

#### <font color='#DDA0DD'>OpenStack基础公共服务</font>

* MySQL 负责保存OpenStack系统中的各类数据
* RabbitMQ 通信枢纽 完成OpenStack各组件间的消息传递

#### <font color='#DDA0DD'>OpenStack计算控制服务</font>

* nova-api 负责接受来自Nova client或Horizon的控制指令并完成虚拟机的创建、删除等管理工作
* nova-cert 主要用户nova证书管理服务 用来为EC2服务提供身份验证
* nova-conductor 服务为计算节点访问数据库时的一个中间件 它防止计算节点的nova-compute服务直接访问数据库带来的性能问题
* nova-consoleauth 该服务主要用于授权用户访问和使用控制台
* nova-novncproxy 该服务主要用于授权用户访问和使用控制台
* nova-spiceproxy 该服务主要用于为用户访问虚拟机提供一个spice协议代理功能
* nova-scheduler 负责决定在哪台计算节点上创建虚拟机

#### <font color='#DDA0DD'>OpenStack验证服务</font>

* keystone服务 用于租户与服务验证

#### <font color='#DDA0DD'>OpenStack镜像服务</font>

* glance服务 负责提供创建虚拟机使用的操作系统镜像 包括glance-api 与glance-registry两个主要服务
    * glance-api 负责接收云系统的镜像创建、删除服务及读取请求，并提供镜像数据服务。
    * glance-registry 负责云系统的镜像注册服务。

#### <font color='#DDA0DD'>OpenStack仪表盘服务</font>

* Horizon服务 用于实现客户通过Web界面操作OpenStack系统。


### <font color='#CDAA7D'>OpenStack各组件安装</font>

#### <font color='#DDA0DD'>安装MySQL服务</font>
> MySQL保存云系统中所有的配置数据。这里安装是最简单的实验性安装 而非生产环境安装

**安装mysql和python的mysql驱动**

```bash
apt-get install mariadb-server python-mysqldb
```

**创建控制服务keystone、glance、nova的数据库并授权连接用户**
这里为了省事就共用了一个账户，如果是生产环境 应该为不同应用创建不同的账户，并做好权限控制

    MariaDB [(none)]> create database keystone;
    Query OK, 1 row affected (0.00 sec)

    MariaDB [(none)]> create database glance;
    Query OK, 1 row affected (0.00 sec)

    MariaDB [(none)]> create database nova;
    Query OK, 1 row affected (0.00 sec)

    MariaDB [(none)]> grant all privileges on *.* to 'root'@'%' identified by '123456';
    Query OK, 0 rows affected (0.00 sec)

#### <font color='#DDA0DD'>安装RabbitMQ服务</font>
> 在OpenStack控制系统中，RabbitMQ为OpenStack整个控制系统提供消息队列服务。它和MySQL一样 都属于控制系统基础服务

**安装RabbitMQ**

```bash
apt-get install rabbitmq-server
```

**修改默认用户的guest的密码**
```bash
rabbitmqctl change_password guest openstack
```

**打开rabbitmq管理插件**
```bash
rabbitmq-plugins enable rabbitmq_management
```

**启动服务命令如下**
```bash
service rabbitmq-server restart
```

**端口启动如下 15672是RabbitMQ对外提供的web管理端口 25672与4369为RabbitMQ集群通信端口**

    root@ubuntu:~# netstat -anpt |grep LISTEN
    tcp        0      0 0.0.0.0:25672           0.0.0.0:*               LISTEN      4290/beam.smp   
    tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      2832/mysqld     
    tcp        0      0 0.0.0.0:4369            0.0.0.0:*               LISTEN      4204/epmd       
    tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1095/sshd       
    tcp        0      0 0.0.0.0:15672           0.0.0.0:*               LISTEN      4290/beam.smp   
    tcp6       0      0 :::5672                 :::*                    LISTEN      4290/beam.smp   
    tcp6       0      0 :::4369                 :::*                    LISTEN      4204/epmd       
    tcp6       0      0 :::22                   :::*                    LISTEN      1095/sshd     


#### <font color='#DDA0DD'>keystone服务器的安装与配置</font>
> keystone负责为OpenStack控制系统提供用户以及各类公共服务的验证工作

**安装keystone和python的keystone库**
```bash
apt-get install keystone python-keystoneclient
```

**当前配置文件/etc/keystone/keystone.conf内容如下**

    root@ubuntu:~# cat /etc/keystone/keystone.conf |grep -v '#'|uniq
    [DEFAULT]
    admin_token = openstack
    log_file = keystone.log
    log_dir = /var/log/keystone

    [assignment]
    [auth]
    [cache]
    [catalog]
    [cors]
    [cors.subdomain]
    [credential]

    [database]
    connection = mysql://root:123456@127.0.0.1:3306/keystone

    [domain_config]
    [endpoint_filter]
    [endpoint_policy]
    [eventlet_server]
    [eventlet_server_ssl]
    [federation]
    [fernet_tokens]
    [identity]
    [identity_mapping]
    [kvs]
    [ldap]
    [matchmaker_redis]
    [memcache]
    [oauth1]
    [os_inherit]
    [oslo_messaging_amqp]
    [oslo_messaging_notifications]
    [oslo_messaging_rabbit]
    [oslo_middleware]
    [oslo_policy]
    [paste_deploy]
    [policy]
    [resource]

    [revoke]
    driver = keystone.contrib.revoke.backends.sql.Revoke

    [role]
    [saml]
    [shadow_users]

    [signing]
    certfile = /etc/keystone/ssl/certs/signing_cert.pem
    keyfile = /etc/keystone/ssl/private/signing_key.pem
    ca_certs = /etc/keystone/ssl/certs/ca.pem
    ca_key = /etc/keystone/ssl/private/cakey.pem
    key_size = 2048
    valid_days = 36500
    cert_subject = /C=US/ST=Unset/L=Unset/O=Unset/CN=www.example.com

    [ssl]

    [token]
    provider = keystone.token.providers.uuid.Provider
    driver = keystone.token.persistence.backends.sql.Token

    [tokenless_auth]
    [trust]

    [extra_headers]
    Distribution = Ubuntu


**创建keystone数据库中相关的表**

```bash
# 备注：由于mysql未知原因没有链接成功 临时换成了sqlite数据库
su -s /bin/sh -c "keystone-manage db_sync" keystone
```

**启动服务**

```bash
service keystone restart
```

**定时清理token**
> 正常情况下 keystone将用户已经用过的token数据存储在数据库中。系统运行的时间长了，数据库也将变得越来越大。因此需要定期清理一些不需要的token数据

```bash
# 清理命令
keystone-manage token_flush
```

**端口监听**
> 35357是keystone对外提供管理权限的身份认证监听端口 5000为keystone对外提供身份认证的监听端口

**租户、用户、角色、服务端点及用户身份环境变量**
概念暂时还没有理解 继续往下看

#### <font color='#DDA0DD'>glance服务器的安装与配置</font>
> Glance服务为OpenStack控制系统提供镜像服务，它主要用来管理和查询虚拟机所使用的镜像。通过Glance服务不仅可以上传本地镜像到OpenStack服务器，还可以将OpenStack系统的镜像下载到本地

**安装glance相关软件**

```bash
apt-get install glance python-glanceclient
```


## <font color='#5CACEE'>附录</font>

工具

* ethtool 配置物理网卡
* bridge-utils 配置网桥
* vconfig  (vlan包) 划分虚拟vlan
* Open vSwitch 虚拟交换机