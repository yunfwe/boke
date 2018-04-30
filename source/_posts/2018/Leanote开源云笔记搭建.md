---
title: Leanote开源云笔记搭建
date: 2018-01-02 14:05:00
categories: 
    - Leanote
tags:
    - Leanote
photos:
    - /uploads/photos/781P1050R31250.jpg
---


## <font color='#5CACEE'>简介</font>
> Leanote是一款开源的云笔记和博客系统 可以很方便的搭建自己的云笔记。在自己的云主机上搭建了Leanote后 就可以抛弃某云笔记了。而且还自带一套博客系统 写好的笔记可以一键生成到博客空间。Leanote还支持注册（注册功能可以关闭）或者手动添加用户，可以让好友也一起用的哦。
> Github地址: https://github.com/leanote/leanote

<!-- more -->

## <font color='#5CACEE'> 安装步骤</font>

1. 下载 leanote 二进制版。
2. 安装和启动 mongodb。
3. 导入初始数据。
4. 配置 leanote。
5. 运行 leanote。

### <font color='#CDAA7D'>下载 leanote 二进制版</font>
> 下载地址: http://leanote.org/#download

下载后将压缩包解压到目录中 linux为例

```
tar xf leanote-linux-amd64-v2.6.bin.tar.gz -C /usr/local/
ls /usr/local/leanote/
```

### <font color='#CDAA7D'> 安装和启动 mongodb</font>
> 可以使用包管理器下载比如apt或者yum 也可以从mongodb官方下载二进制包

```
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.1.tgz
tar xf mongodb-linux-x86_64-3.0.1.tgz -C /usr/local/
mv /usr/local/{mongodb-linux-x86_64-3.0.1,mongodb}
mkdir /usr/local/mongodb/data
/usr/local/mongodb/bin/mongod --dbpath /usr/local/mongodb/data/ &>>/tmp/mongod &
/usr/local/mongodb/bin/mongo
> show dbs      # 进入mongo cli后 查看所有库
```

### <font color='#CDAA7D'> 导入初始数据</font>
> 初始数据存放在 /usr/local/leanote/mongodb_backup/leanote_install_data/ 中

```
/usr/local/mongodb/bin/mongorestore -h localhost -d leanote --dir \
/usr/local/leanote/mongodb_backup/leanote_install_data/
```

输出没有异常的话可以重新进入 mongo cli 然后 show dbs 看看是否存在leanote库了

### <font color='#CDAA7D'> 配置 leanote</font>
> 默认leanote已经存在两个用户

| 用户             | 密码             |
| ---------------- | ---------------- |
| admin            | abc123           |
| demo@leanote.com | demo@leanote.com |

编辑 /usr/local/leanote/conf/app.conf 文件 修改app.secret 可以随便更改几个字符串

```
vim /usr/local/leanote/conf/app.conf 
```

默认启动端口啥的 也看着改吧

### <font color='#CDAA7D'> 运行 leanote</font>

```
cd /usr/local/leanote/bin/
bash run.sh
```

修改配置文件的`http.addr`为`0.0.0.0`可以外部访问leanote服务
接下来就可以浏览器访问Leanote这个专为IT人员打造的云笔记系统了。

## <font color='#5CACEE'>备注</font>

Leanote官网：https://leanote.com/
可以在官网下载Windows客户端 还可以登录到自己搭建的私网leanote服务器