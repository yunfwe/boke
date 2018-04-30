---
title: Nginx编译安装
date: 2016-03-31 10:13:00
categories: 
    - Nginx
tags:
    - web服务器
    - LNMP
    - 代理服务器
    - 负载均衡
---
## <font color='#5CACEE'>简介</font>
> Nginx是一款轻量级的Web 服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器，
并在一个BSD-like 协议下发行。由俄罗斯的程序设计师Igor Sysoev所开发，供俄国大型的入口网站及搜索引擎Rambler使用。其特点是占有内存少，并发能力强，事实上nginx的并发能力确实在同类型的网页服务器中表现较好，中国大陆使用nginx网站用户有：百度、新浪、网易、腾讯等。  
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=Ukw9pO_BXYDywPk3hHL0TU1E95GDHbVTNZY02lvt05axi2nV_ykjH-mHQNjsnPw0ot5Z0xrnKmaR7i8eZ6TujK)
<!-- more -->




	
## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|pcre|8.38|[<font color='#AAAAAA'>点击下载</font>](http://120.52.72.58/heanet.dl.sourceforge.net/c3pr90ntcsf0/project/pcre/pcre/8.38/pcre-8.38.tar.bz2)|
|openssl|1.0.1s|[<font color='#AAAAAA'>点击下载</font>](http://www.openssl.org/source/openssl-1.0.1s.tar.gz)|
|nginx|1.9.13|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.13.tar.gz)|

## <font color='#5CACEE'>步骤</font>
> 需要系统先初始化开发环境

    yum install -y gcc gcc-c++ zlib-devel make

### <font color='#CDAA7D'>解压pcre源码</font>
> Nginx的 HTTP rewrite module 依赖pcre库 所以所以nginx需要pcre的源码

```bash
tar xf pcre-8.38.tar.bz2
```
    解压备用 无需编译

### <font color='#CDAA7D'>解压openssl源码</font>
```bash
tar xf openssl-1.0.1s.tar.gz
```
    解压备用 无需编译

### <font color='#CDAA7D'>编译安装Nginx</font>
```bash
tar xf nginx-1.9.13.tar.gz
cd nginx-1.9.13
./configure --prefix=/usr/local/nginx \
--pid-path=/var/run/nginx/nginx.pid \
--lock-path=/var/lock/nginx.lock \
--user=nginx --group=nginx \
--with-http_ssl_module \
--with-http_flv_module \
--with-stream \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-openssl=/usr/local/ssl \
--http-client-body-temp-path=/var/tmp/nginx/client/ \
--http-proxy-temp-path=/var/tmp/nginx/proxy/ \
--http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ \
--http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
--http-scgi-temp-path=/var/tmp/nginx/scgi \
--with-pcre=../pcre-8.38 \          # pcre源码的路径
--with-openssl=../openssl-1.0.1s    # openssl源码的路径
make -j4 && make install            # nginx被安装到/usr/local/nginx中
```
### <font color='#CDAA7D'>运行Nginx</font>
> Nginx 默认运行用户是nginx 所以需要先创建nginx用户和组。
> 还需要创建Nginx运行需要的一些目录才能将Nginx正常启动

```bash
useradd nginx -M -s /sbin/nologin
mkdir -p /var/tmp/nginx/client/
/usr/local/nginx/sbin/nginx
```
    检查nginx是否正常启动web服务
    netstat -anpt |grep nginx
    tcp     0     0 0.0.0.0:80     0.0.0.0:*      LISTEN     33170/nginx

    通过浏览器访问服务器 看是否出现了Welcome to nginx!
   

## <font color='#5CACEE'>附录</font>
```bash
/usr/local/nginx/sbin/nginx -h
```

    nginx version: nginx/1.9.13
    Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

    Options:
      -?,-h         : 展示帮助
      -v            : 展示版本后退出
      -V            : 展示版本和配置信息后退出
      -t            : 测试配置文件后退出
      -T            : 测试配置文件后展示出来 然后退出
      -q            : 在配置测试过程中抑制非错误消息
      -s signal     : 向主线程发送信号: stop, quit, reopen, reload
      -p prefix     : 设置主目录 (default: /usr/local/nginx/)
      -c filename   : 设置配置文件 (default: conf/nginx.conf)
      -g directives : 设置全局指令的配置文件
    
