---
title: HAProxy常用配置详解
date: 2016-07-18 15:51:49
categories: 
    - HAProxy
tags:
    - 代理服务器
    - 负载均衡
---
## <font color='#5CACEE'>简介</font>
> HAProxy的安装非常简单 但是配置文件方面就比较复杂了 在安装路径下的doc目录下 有官方详细的使用文档。其实常用的配置也并不多 只要掌握了这些 HAProxy就可以很好的使用了
<!-- more -->

	
## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|haproxy|1.6.7|[<font color='#AAAAAA'>点击下载</font>](http://www.haproxy.org/download/1.6/src/haproxy-1.6.7.tar.gz)|

## <font color='#5CACEE'>步骤</font>
> 根据功能和用途 HAProxy配置文件主要由五个部分组成 有些部分并不是必须的 可以根据实际情况使用

    1. global部分             设置全局配置参数
    2. defaults部分           默认参数配置部分
    3. frontend部分           设置接受用户请求的前端虚拟节点
    4. backend部分            设置后端服务器集群的配置
    5. listen部分             frontend和backend部分的结合体 


### <font color='#CDAA7D'>global部分</font>

    global
            maxconn         10000
            log             127.0.0.1 local0 info
            uid             200
            gid             200
            chroot          /var/empty
            daemon
            nbproc          1
            pidfile         /var/run/haproxy.pid
        
    maxconn: 设定每个HAProxy进程可接受的最大并发连接数 (相当于ulimit -n的设置)
    log: 全局的日志配置 127.0.0.1 local0表示使用本机的rsys-log服务中的local0日志设备
        还支持四种日志级别 err, warning, info, debug
    log-send-hostname: 在syslog信息的首部添加当前主机名 可以自定义字符串 默认当前主机名
    uid/gid: 运行HAProxy进程的uid和gid 也可以用user/group代替
    chroot: 限定运行用户的访问目录
    daemon: 设置HAProxy进程后台运行
    nbproc: 服务启动时创建的进程数 创建多个进程 可以减少每个进程的任务队列 但是可能使服务不稳定
    pidfile: pid文件位置 启动用户必须有可写权限
    stats: 用户访问统计数据的接口
    node: 定义当前节点的名称 用于HA场景中多haproxy进程共享同一个IP地址时

### <font color='#CDAA7D'>defaults部分</font>

    defaults
            mode            http
            retries         3
            timeout connect 10s
            timeout client  20s
            timeout server  30s
            timeout check   5s
            
    mode: 设置HAProxy实例默认运行模式 有tcp http health三个可选值
        tcp: 在此模式下 只做数据转发 不对七层报文做检查
        http: 会对七层报文做检查分析
        health: 此模式基本已被废弃
    retries: 设置后端服务器连接失败重试次数 超过次数 HAProxy标记此服务器不可用
    timeout connect: 成功连接到一台服务器最长等待时间
    timeout client: 设置连接客户端发送数据最长等待时间 默认单位毫秒 可以使用其他单位后缀
    timeout server: 设置服务器回应客户最长等待时间 默认单位毫秒 可以使用其他单位后缀
    timeout check: 设置对后端服务器检查超时时间 默认单位毫秒 可以使用其他单位后缀

### <font color='#CDAA7D'>frontend部分</font>
    
    frontend www
            bind            *:80
            mode            http
            option          httplog
            option          forwardfor
            option          httpclose
            log             global
            default_backend htmpool
            
    通过frontend关键字定义了一个名为www的前端虚拟节点
    bind: 只能用在frontend和listen部分 用户定义一个或多个监听的套接字 端口还可以是个段 比如80-100
    option httplog: 开启日志记录HTTP请求
    option forwardfor: 请求头中添加X-Forwardfor-For记录 可以让后端服务器获取用户真实IP
    option httpclose: 完成一次连接请求后 HAProxy将主动关闭此TCP连接
    log global: 使用global中定义的日志选项配置格式
    defaults_backend: 制定默认的后端服务器池 htmpool将在backend中定义

### <font color='#CDAA7D'>backend部分</font>

    backend htmpool
            mode            http
            option redispatch
            option abortonclose
            balance         roundrobin
            cookie          SERVERID
            option httpchk GET /
            server web1 192.168.4.233:80 cookie server1 weight 6 check inter 2000 rise 2 fall 3
            server web2 192.168.4.234:80 cookie server2 weight 6 check inter 2000 rise 2 fall 3
    
    option redispatch: 用于cookie保持环境下 如果后端服务器异常 将客户请求强制定向到另一台正常服务器
    option abortonclose: 服务器负载很高的情况下 自动结束当前队列中处理时间比较长的连接
    balance: 定义负载均衡算法 HAProxy支持多种负载均衡算法 常用的如下几种
        roundrobin: 基于权重进行轮询的调度算法
        static-rr: 也是基于权重进行轮询的调度算法 不过为静态方法 在运行时调整其服务器权重不会生效
        source: 基于请求源IP的算法 可以使同一个客户端的IP请求始终由一台服务器处理
        leastconn: 将新的连接请求转发到最有最少连接数目的后端服务器 长会话的环境中比较适用
        uri: 此算法会对部分或整个URI进行hash运算 再经过与服务器的总权重相除 转发到匹配的服务器
        uri-param: 根据URL路径中的参数转发 可以保证同一用户的请求始终分发到同一台服务器上
        hdr: 根据http头进行转发 如果http头名称不存在 则使用roundrobin算法进行策略转发
    cookie: 表示允许向cookie插入SERVERID 每台服务器的SERVERID可由server关键字定义
    option httpchk <method> <uri> <version>: 表示启用HTTP的服务状态检测功能 method支持以下几种方式
        OPTIONS GET HEAD 一般的健康检查只需要采用HEAD方式 只查看Response的状态码是否是200就可以了
        uri则是要检测的URL地址 version指定检测时的HTTP版本号 默认HTTP/1.0
    server <name> <address>[:port] [param*]: 这个则是定义多台后端服务器了 
        name: 为后端服务器指定一个名称
        address: 后端真实服务器的IP
        port: 后端真实服务器监听的端口号
        param*: 为后端服务器设定的一系列参数 常用参数如下
            check: 表示对后端服务器执行健康检查
            inter: 设置监控状态检测的时间 单位是毫秒
            rise: 由故障状态转移到正常状态需要成功检查的次数 rise 2表示2次检查成功 此服务器才可用
            fall: 由正常状态转移到故障状态需要失败检查的次数
            cookies: 目的在于实现持久连接的功能 cookie server1 表示web1的serverid为server1
            weight: 后端服务器的权重 默认1 最大256 设置0不参与负载均衡 权重越大 被选中的概率越大
            backup: 不参与负载均衡 只有在所有服务器都不可用的情况下才启用
        
    
### <font color='#CDAA7D'>listen部分</font>
> frontend和backend部分的结合体 它们中的指令 listen中都能用 新版的haproxy为了兼容旧版的才保留了listen部分 目前haproxy中 两种配置方式选一个即可

    listen admin_stats
        bind 0.0.0.0:9188
        mode http
        log 127.0.0.1 local0 err
        stats refresh 30s
        stats uri /haproxy-status
        stats realm welcome login\ Haproxy
        stats auth admin:admin~!@
        stats hide-version
        stats admin if TRUE
        
    stats refresh: 监控统计页面的自动刷新时间
    stats uri: 监控统计页面的访问路径
    stats realm: 访问统计页面时的文本提示信息
    stats auth: 认证登陆的用户名和密码
    stats hide-version: 隐藏版本信息
    stats admin: 通过此选择 可以在监控页面上手工启用或禁用后端服务器


## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>HAProxy的日志配置策略</font>
> 默认情况下 HAProxy为了节省读写的I/0所消耗的性能 没有自动配置日志输出功能 但是为了方便维护和调试 还是需要开启的
    
    确定系统已经安装rsyslog
    yum install -y rsyslog
    
    添加配置文件 vim /etc/rsyslog.d/haproxy.conf
        $ModLoad imudp
        $UDPServerRun 514
        local0.* /var/log/haproxy.conf
       
    通过UDP 514端口接收日志 然后还要修改/etc/sysconfig/rsyslog
    修改为: SYSLOGD_OPTIONS="-c 2 -r -m 0"
    
    然后重启rsyslog服务即可
    service rsyslog restart
    
这里只讲解了HAProxy常用的配置方法 如果想深入了解其他配置项 可以查阅官方文档
官方文档位置: /usr/local/haproxy/doc/haproxy/
    
    
    
    
