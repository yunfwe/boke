---
title: Redis数据库编译安装
date: 2016-05-17 15:48:23
categories: 
    - Redis
tags:
    - nosql
    - redis
---
## <font color='#5CACEE'>简介</font>
> Redis是一个开源的使用ANSI C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。从2010年3月15日起，Redis的开发工作由VMware主持。从2013年5月开始，Redis的开发由Pivotal赞助。
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/view/4595959.htm)
<!-- more -->

## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|redis|3.2.0|[<font color='#AAAAAA'>点击下载</font>](http://download.redis.io/releases/redis-3.2.0.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>编译安装</font>
> redis的编译安装非常简单 只需要安装 make 和 gcc 开发工具即可

```bash
yum install make gcc
tar xf redis-3.2.0.tar.gz
cd redis-3.2.0
make -j4
make PREFIX=/usr/local/redis install
```
    通过PREFIX=/usr/local/redis可以指定redis安装路径 默认安装到/usr/local/bin/中

### <font color='#CDAA7D'>提供配置文件并启动redis</font>
> redis的启动非常方便 有很多默认配置 不使用配置文件也可以启动 但是想要灵活配置就比较不方便了

```bash
cp redis.conf /etc/redis.conf
/usr/local/redis/bin/redis-server /etc/redis.conf
```
    如果如图下所示 那么就启动成功了 redis默认在前台运行 Ctrl+c 停止
                    _._                                                  
               _.-``__ ''-._                                             
          _.-``    `.  `_.  ''-._           Redis 3.2.0 (00000000/0) 64 bit
      .-`` .-```.  ```\/    _.,_ ''-._                                   
     (    '      ,       .-`  | `,    )     Running in standalone mode
     |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
     |    `-._   `._    /     _.-'    |     PID: 3173
      `-._    `-._  `-./  _.-'    _.-'                                   
     |`-._`-._    `-.__.-'    _.-'_.-'|                                  
     |    `-._`-._        _.-'_.-'    |           http://redis.io        
      `-._    `-._`-.__.-'_.-'    _.-'                                   
     |`-._`-._    `-.__.-'    _.-'_.-'|                                  
     |    `-._`-._        _.-'_.-'    |                                  
      `-._    `-._`-.__.-'_.-'    _.-'                                   
          `-._    `-.__.-'    _.-'                                       
              `-._        _.-'                                           
                  `-.__.-'  
如果不使用配置文件 可以通过命令行参数方式运行redis-server

    /usr/local/redis/bin/redis-server /etc/redis.conf --daemonize yes --port 1212
    
    这个的意思就是在后台运行 监听端口1212 默认是监听6379 
    可以更改redis.conf中的 daemonize 值为yes 这样 redis-server通过配置文件启动就默认在后台运行了
    如果在指定了配置文件又使用了命令行参数的情况 命令行参数会覆盖配置文件中的相同项

### <font color='#CDAA7D'>redis客户端连接</font>
> redis-cli便是redis-server的客户端连接工具 同时 redis还有很多其他语言的API接口

    /usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 6379
    
    redis-cli 默认会连接本机的6379端口 所以如果服务监听在127.0.0.1:6379 redis-cli可以直接连接
    redis是基于key-value的数据库 下面就测试一下redis工作的是否正常
    
    127.0.0.1:6379> set a 100
    OK
    127.0.0.1:6379> get a
    "100"
    127.0.0.1:6379> 
    
    redis的使用非常简单 所有的命令也一共就一百多条 常用的更少 通过set命令给 a 赋值 100
    然后通过 get 命令获取 a 的值 可以看到 a 的值被正确获取 redis服务正常工作

## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>redis各程序功能</font>
    redis-benchmark         # redis性能测试工具
    redis-check-aof         # aof日志检查工具
    redis-check-rdb         # rdb日志检查工具
    redis-cli               # redis服务客户端
    redis-server            # redis服务程序
    redis-sentinel          # redis哨兵 用于集群检查主从状态 实际上这个是redis-server的软链接
    
### <font color='#CDAA7D'>redis支持的键值数据类型</font>
+ [<font color='#7EC0EE'>字符串类型</font>](/2016/05/20/redis/redis字符串类型)
+ [<font color='#7EC0EE'>散列类型</font>](#)
+ [<font color='#7EC0EE'>列表类型</font>](#)
+ [<font color='#7EC0EE'>集合类型</font>](#)
+ [<font color='#7EC0EE'>有序集合类型</font>](#)
