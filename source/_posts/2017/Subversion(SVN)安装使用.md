---
title: Subversion(SVN)安装使用
date: 2017-12-22
categories: 
    - SVN
tags:
    - SVN
photos:
    - /uploads/photos/9da3h7agf73.jpg
---


## <font color='#5CACEE'>简介</font>
>SVN是Subversion的简称，是一个开放源代码的版本控制系统，相较于RCS、CVS，它采用了分支管理系统，它的设计目标就是取代CVS。互联网上很多版本控制服务已从CVS迁移到Subversion。说得简单一点SVN就是用于多个人共同开发同一个项目，共用资源的目的

<!--more-->


## <font color='#5CACEE'>环境</font>

### 系统环境
> 是在 CentoOS 6.8 上部署的

### 软件环境
|源码包|版本|下载地址|
|-|-|-|
|Subversion|1.9.7|[点击下载](http://mirrors.hust.edu.cn/apache/subversion/subversion-1.9.7.tar.bz2)|
|Sqlite|3.2.1|[点击下载](https://www.sqlite.org/2017/sqlite-autoconf-3210000.tar.gz)|


## 步骤

### 安装依赖

```
yum install -y make gcc apr-devel apr-util-devel zlib-devel
```

#### 编译安装
```
tar xf subversion-1.9.7.tar.bz2
mkdir subversion-1.9.7/sqlite-amalgamation/
tar xf sqlite-autoconf-3210000.tar.gz -C subversion-1.9.7/sqlite-amalgamation/

./configure --prefix=/usr/local/subversion
make -j4 && make install
echo 'export PATH=$PATH:/usr/local/subversion/bin' > /etc/profile.d/subversion.sh
source /etc/profile.d/subversion.sh
```

#### 配置和使用
```
cd /data/svn/conf
echo "svn = svn" > passwd        # 修改passwd文件 添加用户和密码 格式：user = password  
```
修改 `authz` 对svn用户配置访问权限 在文件末尾添加：

    [/]
    svn = rw
    * = r

修改 `svnserve.conf` 文件 `[general]`配置块添加以下内容

    anon-access = read
    auth-access = write
    password-db = passwd
    authz-db = authz
    realm = mysvn

`svnserve -d -r /date/` 启动svn服务
`-d daemon`模式  `-r`指定svn根目录 
比如指定`/data`为根 那么访问svn目录就是`svn://ip/svn`了
`/data`下可以用`svnadmin`创建多个不同的svn目录 每个目录的配置都可以不同
也可以直接将`-r` 指定为`/data/svn` 那访问`snv://ip` 就直接访问这个目录了
`-X` 前台启动 `--listen-port` 更改监听端口号 默认`3690`


## 附录
`Windows`的svn客户端可以使用`TortoiseSVN`
官方地址：https://tortoisesvn.net/