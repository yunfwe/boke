---
title: PHP模块拓展
date: 2016-07-12 13:00:33
categories: 
    - PHP
tags:
    - php-fpm
    - php
    - LNMP
---
## <font color='#5CACEE'>简介</font>
> 在PHP开发环境中可能发现项目依赖一些先前并没有编译进入的模块 或者需要用到一些第三方模块 那么该如何对PHP进行动态的拓展模块 而不用重新编译PHP呢
<!-- more -->


## <font color='#5CACEE'>环境</font>
> 实验已安装环境为PHP 5.5.33版本 

|软件名称|版本号|下载地址|
|-|:-:|-:|
|php|5.5.33|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-5.5.33.tar.xz)|
|php|5.6.19|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-5.6.19.tar.xz)|
|php|7.0.4|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-7.0.4.tar.xz)|
|memcache|3.0.8|[<font color='#AAAAAA'>下载地址</font>](http://pecl.php.net/get/memcache-3.0.8.tgz)|




## <font color='#5CACEE'>步骤</font>
> 如果后期的开发需要用到php的其他模块 或者第三方模块 那就需要对php进行模块升级
模块安装的方式有两种 在linux 可以选择将模块编译入php程序中 也可以作为单独的so文件让php加载

    准备好php的源码包 要和当前php版本一致 下面用第三方模块memcache和自带模块soap做示例

### <font color='#CDAA7D'>编译安装自带模块soap</font>
> 解压了PHP的源码包后 进入到源码包目录的ext目录下 这个是PHP自带的所有模块

```bash
tar xf php-5.5.33.tar.xz
cd php-5.5.34/ext/soap/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && mkdir /usr/local/php/extensions/
cp modules/soap.so /usr/local/php/extensions/
```

    可以看到 ext目录下 有非常多的模块文件夹 进入soap目录中后 先执行phpize脚本才会生成configure文件
    之后指定php-config的位置来进行生成Makefile文件 最后生成的二进制so文件在modules目录内
    为什么不直接make install呢 因为make install安装到的目录感觉并不是非常方便管理
    在php安装目录下建立一个文件夹 可以将所有的二进制so文件都放入到这个文件夹内
    
    接下来就是让php加载这个模块了 修改php.ini文件 添加以下配置
    
    extension_dir = "/usr/local/php/extensions"
    extension=soap.so
    
    先是配置好拓展模块的目录 然后下面启用的模块就可以只写模块名了 否则需要写模块的完整路径
    
    [root@e1adb08f8c82 lib]# /usr/local/php/bin/php -m |grep soap
    soap
    [root@e1adb08f8c82 lib]#
    
    可以看到 php已经出现了soap这个模块 不放心的话 也可以通过phpinfo页面看看有没有soap模块
    
    还有一种方法安装soap模块就是重新编译php 添加 --enable-soap 配置项即可 这里不再赘诉

### <font color='#CDAA7D'>编译安装第三方memcache模块</font>
> php所有的第三方模块都可以在 **http://pecl.php.net/** 找到 这里以memcache为例

```bash
tar xf memcache-3.0.8.tgz
/usr/local/php/bin/phpize 
./configure --with-php-config=/usr/local/php/bin/php-config
cp modules/memcache.so /usr/local/php/extensions/
```

    接下来也是修改php.ini文件 将memcache.so加载就可以了
    extension=memcache.so
    
    [root@e1adb08f8c82 lib]# /usr/local/php/bin/php -m |grep memcache
    memcache
    [root@e1adb08f8c82 lib]#
    
    可以看到 memcache也成功的出现在 php的模块中 
    
    



## <font color='#5CACEE'>附录</font>
    
    不同版本的php模块是不能够通用的 反之如果环境相同的php 那么模块就不用重复编译了
    模块不通用的原因是因为 不同版本的PHP 可能使用的API不相同
    
    [root@e1adb08f8c82 memcache-3.0.8]# /usr/local/php/bin/phpize 
    Configuring for:
    PHP Api Version:         20121113
    Zend Module Api No:      20121212
    Zend Extension Api No:   220121212
    
    正如每次执行phpize脚本中显示的那样




