---
title: Dnsmasq安装配置
date: 2016-04-06 09:03:00
categories: 
    - Dnsmasq
tags:
    - dns
    - dhcp
    - tftp
    - pxe
---
## <font color='#5CACEE'>简介</font>
> DNSmasq是一个小巧且方便地用于配置DNS和DHCP的工具，适用于小型网络，它提供了DNS功能和可选择的DHCP功能。
它服务那些只在本地适用的域名，这些域名是不会在全球的DNS服务器中出现的。
DHCP服务器和DNS服务器结合，并且允许DHCP分配的地址能在DNS中正常解析，
而这些DHCP分配的地址和相关命令可以配置到每台主机中，也可以配置到一台核心设备中（比如路由器），DNSmasq支持静态和动态两种DHCP配置方式。
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=YR5BrsDncVQl0sly_MwHJSy4cXoid99NBAj_yluOPIgOttaDl_XZRubXZIyFT4vMWrmt81ak3SWE5F6ijyAocq)
<!-- more -->




	
## <font color='#5CACEE'>环境</font>
> dnsmasq几乎没有额外的依赖 只需要系统安装好编译环境即可

|软件名称|版本号|下载地址|
|-|:-:|-:|
|dnsmasq|2.75|[<font color='#AAAAAA'>下载地址</font>](http://www.thekelleys.org.uk/dnsmasq/dnsmasq-2.75.tar.xz)|


## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>编译安装</font>
```bash
tar xf dnsmasq-2.75.tar.xz
cd dnsmasq-2.75
make && make install                            # dnsmasq主程序在/usr/local/dnsmasq
cp dnsmasq.conf.example /etc/dnsmasq.conf       # 配置文件
```

    一般到这就编译完成了 如果有特殊需求 可以通过修改Makefile文件实现
    vim Makefile
        PREFIX        = /usr/local/dnsmasq      # 安装的位置
        BINDIR        = $(PREFIX)/sbin
        MANDIR        = $(PREFIX)/share/man
        LOCALEDIR     = $(PREFIX)/share/locale
        BUILDDIR      = $(SRC)
        DESTDIR       =
        CFLAGS        = -Wall -W -O2
        LDFLAGS       = -s -static              # 去掉编译debug信息 采用静态编译 
        
        注意 并不是所有平台修改过Makefile后都可以正常编译
### <font color='#CDAA7D'>用法详解</font>
> dnsmasq程序虽小 可五脏俱全 可以用来做DNS DHCP TFTP服务器 甚至可以用作PXE装机用
打开/etc/dnsmasq.conf配置文件 可以看到所有的选项和说明 通过man 8 dnsmasq 可以看到更详细的内容
为了方便配置不同的服务 将不同服务的配置文件分开 开启conf-dir=/etc/dnsmasq.d/,\*.conf配置项
这样 dnsmasq就会在启动的时候加载/etc/dnsmasq.d/内的\*.conf文件了

```bash
vim /etc/dnsmasq.conf
```

**修改如下内容**

    conf-dir=/etc/dnsmasq.d/,\*.conf


#### <font color='#DDA0DD'>DNS服务</font>
> dnsmasq默认会启动dns服务 并读取系统的/etc/resolv.conf和/etc/hosts
/etc/resolv.conf中的nameserver会被dnsmasq作为上行DNS server 
在遇到dnsmasq找不到的记录就像上行服务器发出请求 然后将结果返回客户机
下面是dnsmasq中DNS功能一些常用的配置项

    port=53                                # port设置为0 会关闭dns功能
    resolv-file=/etc/dnsmasq.resolv.conf   # 从另一个文件获取上行DNS服务器地址
    addn-hosts=/etc/dnsmasq.hosts.conf     # 从另一个文件获取主机名IP地址映射
    no-resolv                              # 禁用resolv 不获取上行DNS服务器 同时resolv-file失效
    no-hosts                               # 不使用系统的hosts文件 仅使用addn-hosts配置的
    listen-address=127.0.0.1               # 配置监听地址
    interface=lo                           # 配置监听网卡接口
    except-interface=eth0                  # 配置不监听的网卡接口
    
    如果配置了resolv-file dnsmasq就不会去读取系统的/etc/resolv.conf
    而配置了addn-hosts dnsmasq会同时读取系统的/etc/hosts和配置指定的文件
    
>为了能让系统能使用自己启动的DNS服务 并且不影响访问外网等操作 可以将系统的resolv.conf的nameserver改为127.0.0.1 然后在resolv-file指定的文件写入上行DNS服务器

```bash
vim /etc/dnsmasq.d/dns.conf
```

**写入如下内容**

    resolv-file=/etc/dnsmasq.resolv.conf
    addn-hosts=/etc/dnsmasq.hosts.conf


```bash
echo 'nameserver 127.0.0.1' > /etc/resolv.conf              # 系统使用本地的DNS服务器
echo 'nameserver 180.76.76.76' > /etc/dnsmasq.resolv.conf   # dnsmasq去查询的DNS服务器
echo '127.0.0.1 test' > /etc/dnsmasq.hosts.conf             # 测试dns解析效果
/usr/local/dnsmasq/sbin/dnsmasq -d                          # 默认后台运行 -d 可以阻止
```
    
接下来用ping命令检查域名解析服务是否正常了

    root@ubuntu:/etc/dnsmasq.d# ping -c4 test 
    PING test (127.0.0.1) 56(84) bytes of data.
    64 bytes from localhost (127.0.0.1): icmp_seq=1 ttl=64 time=0.050 ms
    64 bytes from localhost (127.0.0.1): icmp_seq=2 ttl=64 time=0.037 ms
    64 bytes from localhost (127.0.0.1): icmp_seq=3 ttl=64 time=0.034 ms
    64 bytes from localhost (127.0.0.1): icmp_seq=4 ttl=64 time=0.033 ms

    --- test ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3996ms
    rtt min/avg/max/mdev = 0.033/0.037/0.050/0.009 ms
    
用dig命令检查 可以清楚的看到解析的A记录

    root@ubuntu:/etc/dnsmasq.d# dig @127.0.0.1 test
    test.			0	IN	A	127.0.0.1
    
也可以用nslookup命令检查 Windows平台的话 需要将127.0.0.1改为dnsmasq所在服务器的IP

    root@ubuntu:/etc/dnsmasq.d# nslookup test 127.0.0.1
    Server:		127.0.0.1
    Address:	127.0.0.1#53

    Name:	test
    Address: 127.0.0.1
    
以后只需要将需要解析的IP和名称写入/etc/dnsmasq.resolv.conf文件就可以了，不过美中不足的一点就是 每次修改了配置文件 都需要重新启动dnsmasq服务。
    
#### <font color='#DDA0DD'>DHCP服务</font>
> DHCP服务在dnsmasq中的配置非常简单 甚至只用一行配置就可以启动一个正常工作的DHCP服务器
一下是DHCP服务的常用配置项

    dhcp-range=192.168.1.50,192.168.1.100,12h               # 起始 结束 还有租约时间
    dhcp-range=192.168.0.50,192.168.0.150,255.255.255.0,12h # 网段
    dhcp-host=aa:bb:cc:dd:ee:ff,192.168.1.50                # mac地址 IP
    dhcp-host=00:0e:7b:ca:1c:6e,daunbook,192.168.0.12       # mac地址 主机名 IP
    dhcp-option=3,192.168.0.1                               # 默认网关
    dhcp-option=option:router,1.2.3.4                       # 默认网关 和上面的一样
    dhcp-option=option:ntp-server,192.168.0.4,10.10.0.5     # ntp服务地址
    dhcp-option=option:dns-server,180.76.76.76              # dns服务器地址
    no-dhcp-interface=eth0                                  # 不提供dhcp的接口

> 其中只要有dhcp-range或者dhcp-host的配置 dhcp服务就会启动 接下来 添加dhcp的配置项 并检测dhcp服务是否正常分配IP

```bash
# 由于只能给同网段的主机分配IP 所以这里需要在网卡上绑定一个子接口
ifconfig ens32:0 192.168.100.1/24            # 网卡名称根据实际情况来定
vim /etc/dnsmasq.d/dhcp.conf
```

**写入如下内容**

    dhcp-range=192.168.100.10,192.168.100.20,12h  # 这里使用和当前局域网不同的网段
    dhcp-option=option:router,192.168.100.1  # 自己同时作为网关


```bash
/usr/local/dnsmasq/sbin/dnsmasq -d
```

可以清楚的看到dnsmasq的输出有DHCP的一些信息

    dnsmasq-dhcp: DHCP, IP range 192.168.100.10 -- 192.168.100.20, lease time 12h
    
接下来检测DHCP服务是否能正常提供服务，在另外一台机器上 强行使用dhclient命令为网卡获取动态IP。

    [root@localhost ~]# dhclient -v ens32:0
    Internet Systems Consortium DHCP Client 4.2.5
    Copyright 2004-2013 Internet Systems Consortium.
    All rights reserved.
    For info, please visit https://www.isc.org/software/dhcp/

    Listening on LPF/ens32/00:0c:29:44:eb:ec
    Sending on   LPF/ens32/00:0c:29:44:eb:ec
    Sending on   Socket/fallback
    DHCPREQUEST on ens32 to 255.255.255.255 port 67 (xid=0xba1741)
    DHCPACK from 192.168.100.1 (xid=0xba1741)
    bound to 192.168.100.19 -- renewal in 19449 seconds.
    
可以看到从192.168.100.1获取了192.168.100.19这个IP 同时DHCP server端有这次请求信息。

    dnsmasq-dhcp: DHCPREQUEST(ens32) 192.168.100.19 00:0c:29:44:eb:ec 
    dnsmasq-dhcp: DHCPACK(ens32) 192.168.100.19 00:0c:29:44:eb:ec
    
也可以先将网卡配置为DHCP获取IP 然后重启 看看是否获取到了配置的IP段的IP 以及网关是否正确
    
    
#### <font color='#DDA0DD'>TFTP服务</font>
> tftp是简单文件传输协议 有区别与一般的ftp服务 tftp使用UDP的69端口 一般用作小文件传输 下面就是如何用dnsmasq配置tftp服务

    enable-tftp                     # 表示启动tftp服务
    tftp-root=/tftp                 # 配置tftp的文件根目录

```bash
vim /etc/dnsmasq.d/tftp.conf
```

**写入如下内容**

    enable-tftp
    tftp-root=/tftp

```
mkdir /tftp
echo 'hello' > /tftp/test           # 添加测试文件
/usr/local/dnsmasq/sbin/dnsmasq -d
```

启动dnsmasq后 可以看到tftp服务也启动了

    dnsmasq-tftp: TFTP root is /tftp

接下来验证tftp服务是否正常工作 通过tftp命令连接tftp服务 如果没有tftp命令 自行安装相应的包

    root@ubuntu:/tmp# tftp 127.0.0.1            # 连接本地的tftp服务
    tftp> get test                              # 获取刚才写入的test文件
    Received 7 bytes in 0.0 seconds
    tftp> quit                                  # quit命令退出交互
    root@ubuntu:/tmp# cat test                  # 查看获取的文件
    hello                                       # 内容没有问题
    
tftp是一个非常简单的文件传输协议 只有文件上传下载功能 列出目录之类的功能就不用想了，支持的命令也非常少 可以在ftfp的交互界面 通过输入?来查询支持的命令 或许有些命令 服务端也并不支持。

## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>用dnsmasq部署pxe自动装机</font>
> 由于dnsmasq包含了DHCP和TFTP 所以用dnsmasq搭建pxe自动装机服务是完全可行的 而且只需要简简单单的几项配置就可以了

    enable-tftp
    tftp-root=/tftp
    dhcp-boot=pxelinux.0
    dhcp-range=192.168.100.10,192.168.100.20,12h
    
记得要将pxe装机需要的pxelinux.0等文件放到tftp-root配置的目录下，还要注意给客户分配的网段要根据实际情况分配。
