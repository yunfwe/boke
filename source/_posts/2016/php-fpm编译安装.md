---
title: PHP-fpm 编译安装
date: 2016-04-01 10:30:00
categories: 
    - PHP
tags:
    - php-fpm
    - php
    - LNMP
---
## <font color='#5CACEE'>简介</font>
> PHP（外文名:PHP: Hypertext Preprocessor，中文名：“超文本预处理器”）是一种通用开源脚本语言。
语法吸收了C语言、Java和Perl的特点，利于学习，使用广泛，主要适用于Web开发领域。
PHP 独特的语法混合了C、Java、Perl以及PHP自创的语法。它可以比CGI或者Perl更快速地执行动态网页。用PHP做出的动态页面与其他的编程语言相比，PHP是将程序嵌入到HTML（标准通用标记语言下的一个应用）文档中去执行，执行效率比完全生成HTML标记的CGI要高许多；PHP还可以执行编译后代码，编译可以达到加密和优化代码运行，使代码运行更快。  
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=CthX9WS3kW--1m7UmzKM8lPN_QCQfs-9X9XPhLf4ctJ5kSaRaJTd7KK1Hc9v83LGAowes5XIoRt1Uct9FyFXTQ-XjQn2NNd-cCNU2VhOffq)
<!-- more -->


## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|php|5.5.33|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-5.5.33.tar.xz)|
|php|5.6.19|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-5.6.19.tar.xz)|
|php|7.0.4|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-7.0.4.tar.xz)|
|libmcrypt|2.5.8|[<font color='#AAAAAA'>下载地址</font>](http://ufpr.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz)|



## <font color='#5CACEE'>步骤</font>
> 初始化系统编译环境 选择合适的PHP版本 实验用CentOS 6.7 编译安装 php-5.6.19

    yum -y install make gcc-c++ gcc bzip2-devel libjpeg-turbo-devel \
    libpng-devel freetype-devel curl-devel mysql-devel libxml2-devel

### <font color='#CDAA7D'>编译安装libmcrypt</font>
> PHP依赖libmcrypt yum源的基础仓库没有libmcrypt的开发包 如果想yum安装 可以拓展epel仓库

```bash
tar xf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=/usr/local/mcrypt
make && make install
```

### <font color='#CDAA7D'>开始编译PHP</font>
```bash
tar xf php-5.6.19.tar.xz
cd php-5.6.19
./configure \
--prefix=/usr/local/php \
--enable-fpm  --with-mcrypt \
--with-zlib --enable-mbstring \
--with-openssl --with-mysql \
--with-mysqli --with-mysql-sock \
--with-gd --with-jpeg-dir=/usr/lib \
--enable-gd-native-ttf  \
--enable-pdo --with-pdo-mysql \
--with-gettext --with-curl \
--with-pdo-mysql --enable-sockets \
--enable-bcmath --enable-xml \
--with-bz2 --enable-zip \
--with-freetype-dir=/usr \
--with-mcrypt=/usr/local/mcrypt
make -j4 && make install
```

### <font color='#CDAA7D'>配置运行环境</font>
```bash
mkdir /etc/php
cp ./php.ini-production /usr/local/php/lib/php.ini
cp /usr/local/php/etc/{php-fpm.conf.default,php-fpm.conf}
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
```
    
### <font color='#CDAA7D'>启动服务</font>
```bash
service php-fpm start               # 任意方式启动即可
/etc/init.d/php-fpm start
/usr/local/php/sbin/php-fpm --daemonize
```

    [root@45c4f07c6049 etc]# netstat -anpt |grep php-fpm
    tcp    0   0 127.0.0.1:9000      0.0.0.0:*      LISTEN    49135/php-fpm

    php-fpm默认使用nobody用户运行 监听127.0.0.1:9000端口
    如果想在前端显示调试信息等 可以将 --daemonize 换成 --nodaemonize 
    这些配置会覆盖掉php-fpm.conf中的配置 

## <font color='#5CACEE'>附录</font>
    一般php-fpm能正常监听 就没问题了 不同与Apache的模块方式
    fpm方式是通过Fastcgi方式提供服务的 web服务器将需要处理的php页面请求
    转发给php-fpm的监听端口 php-fpm将处理好的数据再返回给web服务器
    所以php-fpm方式是和web服务器无关的 只要你的web服务器支持Fastcgi
    就都可以将php页面转发给php-fpm处理 想要验证 可以搭配Nginx等服务器解析php页面试试






