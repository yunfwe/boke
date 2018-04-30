---
title: LNMP环境部署
date: 2016-07-19
categories: 
    - LAMP
tags: 
    - php
    - mysql
    - apache
    - zabbix
---
## <font color='#5CACEE'>简介</font>
> Linux+Apache+Mysql/MariaDB+Perl/PHP/Python一组常用来搭建动态网站或者服务器的开源软件，本身都是各自独立的程序，但是因为常被放在一起使用，拥有了越来越高的兼容度，共同组成了一个强大的Web应用程序平台。随着开源潮流的蓬勃发展，开放源代码的LAMP已经与J2EE和.Net商业软件形成三足鼎立之势，并且该软件开发的项目在软件方面的投资成本较低，因此受到整个IT界的关注。从网站的流量上来说，70%以上的访问流量是LAMP来提供的，LAMP是最强大的网站解决方案．
<!-- more -->


## <font color='#5CACEE'>环境</font>
> 本教程中的各服务搭建在不同的服务器上 当然也可以搭建在同一个服务器上

### <font color='#CDAA7D'>主机环境</font>
|      身份     |      系统     |       IP       |
| ------------- |:-------------:| --------------:|
| Apache 服务器   |   CentOS 6.7  |   172.18.0.4   |
| MySQL 服务器   |   CentOS 6.7  |   172.18.0.2   |
| PHP-fpm 服务器 |   CentOS 6.7  |   172.18.0.3   | 

### <font color='#CDAA7D'>软件环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|Apache|2.4.23|[<font color='#AAAAAA'>点击下载</font>](http://mirrors.aliyun.com/apache/httpd/httpd-2.4.23.tar.bz2)|
|MySQL|5.6.28|[<font color='#AAAAAA'>点击下载</font>](http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz)|
|PHP|5.6.19|[<font color='#AAAAAA'>点击下载</font>](http://cn2.php.net/distributions/php-5.6.19.tar.xz)|


## <font color='#5CACEE'>步骤</font>
> httpd和php结合的方式有两种 一种是和nginx相同的 通过php-fpm启动监听的方式 然后转发php页面请求给php-fpm服务 还有一种就是php编译为httpd模块的方式提供php页面的解析能力
### <font color='#CDAA7D'>编译安装各组件</font>
|服务器|安装文档地址|
|-|:-:|-|
|Apache|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/03/31/nginx/nginx编译安装)|
|MySQL|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/mysql/MySQL编译安装)|
|PHP-fpm|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/php/php-fpm编译安装)|

### <font color='#CDAA7D'>httpd + php-fpm</font>
> 这个是httpd通过fast-cgi方式和php-fpm搭配

#### <font color='#DDA0DD'>配置PHP-fpm</font>
    打开编辑php-fpm.conf
    vim /usr/local/php/etc/php-fpm.conf
    
    修改listen监听地址为0.0.0.0:9000
    listen = 0.0.0.0:9000 
    
    配置仅允许连接的客户机 默认运行所有主机连接 172.0.0.7是Nginx服务器的IP
    listen.allowed_clients = 172.17.0.7
    
    然后启动PHP-fpm的服务
    service php-fpm start
    

#### <font color='#DDA0DD'>修改httpd配置文件</font>    

    打开编辑httpd.conf
	vim /usr/local/httpd/conf/httpd.conf

	修改 DocumentRoot 路径为"/var/www/html" 这个是网站根目录 
	紧接着的 Directory 配置段也修改为 <Directory "/var/www/html">

	去掉mod_proxy.so和mod_proxy_fcgi.so之前的注解 让httpd启动时加载这两个模块
	LoadModule proxy_module modules/mod_proxy.so
	LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so 

	然后添加配置段 让php页面交给php-fpm去解析
	<FilesMatch \.php$>
		 SetHandler "proxy:fcgi://172.18.0.3:9000"
	</FilesMatch>

	然后定位DirectoryIndex配置项 添加index.php
	DirectoryIndex index.php index.html

	最后启动httpd服务
	/usr/local/httpd/bin/httpd

	下面有详细的方法检测是否搭配成功
    
### <font color='#DDA0DD'>httpd + php模块</font>  
> 接下来开始介绍如何将php编译为httpd的模块方式搭配php和httpd

#### <font color='#CDAA7D'>将php编译为httpd模块</font>
> 将php编译为httpd模块方式和php-fpm模式的编译唯一的区别就是将–enable-fpm替换为–with-apxs2=/usr/local/httpd/bin/apxs
    
```bash
tar xf php-5.6.19.tar.xz
cd php-5.6.19
./configure \
--prefix=/usr/local/php \
--with-apxs2=/usr/local/httpd/bin/apxs \
--with-mcrypt \
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

	ls /usr/local/httpd/modules/libphp5.so
	可以看到 在httpd的modules目录下 已经出现了libphp5.so这个模块了
	接下来依然要给php模块提供个配置文件 

	cp ./php.ini-production /usr/local/php/lib/php.ini
        

#### 修改httpd配置文件
> php模块方式对httpd.conf的修改和php-fpm方式是完全不同的

	cd到httpd的conf目录 可以发现多出来一个httpd.conf.bak的文件 
	这个是php安装期间 对httpd.conf做出修改后的备份 其实做的修改也仅仅是添加和启用了libphp5这个模块
	LoadModule php5_module        modules/libphp5.so

	如果沿用的是刚才的php-fpm模式的配置文件 需要先清理掉<FilesMatch \.php$>配置段
	如果是全新的配置 同样修改网站根目录和添加index.php 这里不再赘述

	添加如下两行配置
	AddType application/x-httpd-php  .php
	AddType application/x-httpd-php-source  .phps

	最后启动httpd服务
	/usr/local/httpd/bin/httpd
	
### 验证是否搭配成功
> 请注意 如果php-fpm和httpd服务不在同一个服务器 可以将网站根目录通过nfs共享访问 或者克隆一份web页面放到两台服务器相同的路径下

MySQL创建远程登录用户 php 允许所有地址连接 密码 php123
grant all privileges on *.* to "php"@"%" identified by "php123";

	在/var/www/html中编写index.php
		<?php
			phpinfo();
		?>

	在/var/www/html中编写dbtest.php
		<?php 
			$link=mysql_connect("172.18.0.2","php","php123"); 
			if(!$link) echo "连接错误!"; 
			else echo "可以连接!"; 
		?>

	分别访问两个php文件
	http://172.18.0.4/  和  http://172.18.0.4/dbtest.php
	若浏览器出现大大的PHP Version 5.6.19 则index.php被正常识别
	访问dbtest.php若出现 "可以连接!" 则数据库连接成果

	以下是用curl访问dbtest.php的结果
	# curl http://172.18.0.4/dbtest.php
	可以连接
		
		
## <font color='#5CACEE'>附录</font>
    可以看到 LAMP 和 LNMP 在php-fpm上是非常相似的 
	推荐使用php-fpm的方式 这样比php模块更节省服务器资源

	因为httpd的高并发能力比Nginx弱很多 所以高并发环境下推荐使用LNMP