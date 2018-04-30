---
title: LNMP环境部署
date: 2016-04-01 13:12:00
categories: 
    - LNMP
tags: 
    - php
    - mysql
    - nginx
    - zabbix
---
## <font color='#5CACEE'>简介</font>
> NMP代表的就是：Linux系统下Nginx+MySQL+PHP这种网站服务器架构。
Linux是一类Unix计算机操作系统的统称，是目前最流行的免费操作系统。代表版本有：debian、centos、ubuntu、fedora、gentoo等。
Nginx是一个高性能的HTTP和反向代理服务器，也是一个IMAP/POP3/SMTP代理服务器。
Mysql是一个小型关系型数据库管理系统。
PHP是一种在服务器端执行的嵌入HTML文档的脚本语言。
这四种软件均为免费开源软件，组合到一起，成为一个免费、高效、扩展性强的网站服务系统。
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=bMxOeg20BJhz-ATbBQ88pBDZxMyQ92XX3lwJ5JmfK0DEJYPdFaDHLtMaLsTlyB4tT7AfyuVcLKrdX047yI0D2q)
<!-- more -->


## <font color='#5CACEE'>环境</font>
> 本教程中的各服务搭建在不同的服务器上 当然也可以搭建在同一个服务器上

### <font color='#CDAA7D'>主机环境</font>
|      身份     |      系统     |       IP       |
| ------------- |:-------------:| --------------:|
| Nginx 服务器   |   CentOS 6.7  |   172.17.0.7   |
| MySQL 服务器   |   CentOS 6.7  |   172.17.0.2   |
| PHP-fpm 服务器 |   CentOS 6.7  |   172.17.0.6   | 

### <font color='#CDAA7D'>软件环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|Nginx|1.9.13|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.13.tar.gz)|
|MySQL|5.6.28|[<font color='#AAAAAA'>点击下载</font>](http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz)|
|PHP|5.6.19|[<font color='#AAAAAA'>点击下载</font>](http://cn2.php.net/distributions/php-5.6.19.tar.xz)|


## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>编译安装各组件</font>
|服务器|安装文档地址|
|-|:-:|-|
|Nginx|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/03/31/nginx/nginx编译安装)|
|MySQL|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/mysql/MySQL编译安装)|
|PHP-fpm|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/php/php-fpm编译安装)|

### <font color='#CDAA7D'>搭配组合</font>
> 他们之间的搭配其实就是通过修改配置文件能互连起来 协调工作
如果跨主机搭建需要让Nginx和PHP-fpm能访问相同的web网页目录
或者只将PHP的页面放到PHP-fpm服务能访问到了路径即可
因为Nginx收到PHP页面的请求会将请求转发给PHP-fpm去处理 自己并不处理PHP的页面
但是如果其他的静态资源等 还是需要放到Nginx能访问到的路径
实验中 已经通过NFS共享方式让Nginx和PHP-fpm挂载相同的/var/www/html目录

#### <font color='#DDA0DD'>配置PHP-fpm</font>
    打开编辑php-fpm.conf
    vim /usr/local/php/etc/php-fpm.conf
    
    修改listen监听地址为0.0.0.0:9000
    listen = 0.0.0.0:9000 
    
    配置仅允许连接的客户机 默认运行所有主机连接 172.0.0.7是Nginx服务器的IP
    listen.allowed_clients = 172.17.0.7
    
    然后启动PHP-fpm的服务
    service php-fpm start
    

#### <font color='#DDA0DD'>配置Nginx</font>    

    打开编辑nginx.conf
    vim /usr/local/nginx/conf/nginx.conf
    
    更改网站根路径和添加php页面的识别
    location / {                                                          
            root   /var/www/html;                                             
            index  index.html index.htm index.php;                            
        }
        
    去掉php段的注释 并按实际环境修改以下内容
    location ~ \.php$ {                                                   
            root           /var/www/html;                                     
            fastcgi_pass   172.17.0.6:9000;                                   
            fastcgi_index  index.php;                                         
            fastcgi_param  SCRIPT_FILENAME  /var/www/html$fastcgi_script_name;
            include        fastcgi_params;                                    
        }
    
    重启或通知Nginx重新加载配置文件
    /usr/local/nginx/sbin/nginx -s reload
    
#### <font color='#DDA0DD'>配置MySQL</font>  
    MySQL创建远程登录用户 php 只允许 172.17.0.6连接 密码 php123
    grant all privileges on *.* to "php"@"172.17.0.6" identified by "php123";

### <font color='#CDAA7D'>验证是否搭配成功</font>
    
    在/var/www/html中编写index.php
        <?php
            phpinfo();
        ?>

    在/var/www/html中编写dbtest.php
        <?php 
            $link=mysql_connect("172.17.0.2","root","123.com"); 
            if(!$link) echo "连接错误!"; 
            else echo "可以连接!"; 
        ?>
        
    分别访问两个php文件
    http://172.17.0.7/  和  http://172.17.0.7/dbtest.php
    若浏览器出现大大的PHP Version 5.6.19 则index.php被正常识别
    访问dbtest.php若出现 "可以连接!" 则数据库连接成果
    
    以下是用curl访问dbtest.php的结果
    [root@45c4f07c6049 etc]# curl http://172.17.0.7/dbtest.php
    OK!可以连接
        
        
## <font color='#5CACEE'>附录</font>
    搭建好LNMP后 好多用到PHP运行环境的页面就可以在上面运行了 
    比如zabbix的web管理界面