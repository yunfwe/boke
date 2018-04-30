---
title: Apache编译安装
date: 2016-09-21 10:12:00
categories: 
    - Apache
tags:
    - Apache
---
## <font color='#5CACEE'>简介</font>
Apache是世界使用排名第一的Web服务器软件。它可以运行在几乎所有广泛使用的计算机平台上，由于其跨平台和安全性被广泛使用，是最流行的Web服务器端软件之一。它快速、可靠并且可通过简单的API扩充，将Perl/Python等解释器编译到服务器中。同时Apache音译为阿帕奇，是北美印第安人的一个部落，叫阿帕奇族，在美国的西南部。也是一个基金会的名称、一种武装直升机等等
<!-- more -->

##  <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|pcre|8.39|[<font color='#AAAAAA'>点击下载</font>](http://heanet.dl.sourceforge.net/project/pcre/pcre/8.39/pcre-8.39.tar.bz2)|
|openssl|1.0.1s|[<font color='#AAAAAA'>点击下载</font>](http://www.openssl.org/source/openssl-1.0.1s.tar.gz)|
|apr|1.5.2|[<font color='#AAAAAA'>点击下载</font>](http://mirrors.aliyun.com/apache/apr/apr-1.5.2.tar.bz2)|
|apr-util|1.5.4|[<font color='#AAAAAA'>点击下载</font>](http://mirrors.aliyun.com/apache/apr/apr-util-1.5.4.tar.bz2)|
|httpd|2.4.23|[<font color='#AAAAAA'>点击下载</font>](http://mirrors.aliyun.com/apache/httpd/httpd-2.4.23.tar.bz2)|


##  步骤
> 需要系统先初始化开发环境

    yum install -y make gcc gcc-c++ perl tar bzip2 vim

### 编译安装apr和apr-util
>apr 和 apr-util 是 httpd 的运行依赖

```
# apr-1.5.2
tar xf apr-1.5.2.tar.bz2
cd apr-1.5.2 
./configure --prefix=/usr/local/apr
make -j4 && make install

# apr-util-1.5.4
tar xf apr-util-1.5.4.tar.bz2
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/
make -j4 && make install
```

### 编译安装pcre
>pcre是一个perl的正则表达式库 httpd的rewrite需要用到

```
tar xf pcre-8.39.tar.bz2
cd pcre-8.39
./configure --prefix=/usr/local/pcre
make -j4 && make install
```

### 编译安装openssl
>OpenSSL 是一个强大的安全套接字层密码库 搭建https的网站需要用到

```
tar xf openssl-1.0.1s.tar.gz
cd openssl-1.0.1s
./config  -fPIC no-shared
make depend && make install
```

### 编译安装httpd

```
tar xf httpd-2.4.23.tar.bz2
cd httpd-2.4.23
./configure --prefix=/usr/local/httpd \
--enable-ssl --enable-cgi  \
--enable-rewrite  --enable-so \
--with-pcre --with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util/ \
--with-pcre=/usr/local/pcre/ \
--with-ssl=/usr/local/ssl \
--with-mpm=event --with-zlib
make -j4 && make install
```

### 运行httpd
> httpd默认运行用户是daemon 若不存在需要先创建 也可以在配置文件中重新指定运行用户

```
修改配置文件
vim /usr/local/httpd/conf/httpd.conf
添加：ServerName localhost

不添加这行配置 httpd服务也是可以正常启动的 但是会弹出提示
然后就可以启动httpd服务了

/usr/local/httpd/bin/httpd

检查httpd是否正常监听
netstat -anpt |grep httpd
tcp    0   0 :::80           :::*            LISTEN      51272/httpd

通过浏览器访问服务器 看是否出现了大大的 It works!
```

## 附录

httpd的主要目录作用

    ls /usr/local/httpd/
    bin  build  cgi-bin  conf  error  htdocs  icons  include  logs  man  manual  modules

    bin:        存放着apache提供的一些小工具和httpd主程序
    cgi-bin:    存放cgi脚本的目录
    conf:       存放httpd的配置文件 主配置文件为httpd.conf
    htdocs:     web的默认根目录 存放网页文件
    logs:       存放着httpd的访问日志 错误日志 以及pid文件
    modules:    存放着httpd动态编译的模块 比如刚才的openssl就被编译为了mod_ssl.so