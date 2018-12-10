---
title: Ubuntu 安装 Oracle 数据库
date: 2018-08-13 10:12:00
categories: 
    - Oracle
tags:
    - oracle
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
---

## 简介
> 在 Ubuntu 16.04 上安装 Oracle 数据库，特此记录一下安装过程。
<!-- more -->

## 安装

```bash
apt-get update
apt-get upgrade
apt-get install -y bzip2 elfutils  automake  autotools-dev binutils expat gawk gcc gcc-multilib g++-multilib ksh   less    lib32z1 libaio1 libaio-dev libc6-dev libc6-dev-i386 libc6-i386 libelf-dev  libltdl-dev  libodbcinstq4-1 libodbcinstq4-1:i386 libpth-dev   libpthread-stubs0-dev  libstdc++5    make  openssh-server  rlwrap rpm sysstat unixodbc unixodbc-dev unzip x11-utils zlibc 
```

编辑 `/etc/sysctl.conf` 添加如下内容

    fs.aio-max-nr = 1048576
    fs.file-max = 6815744
    kernel.shmall = 2097152
    kernel.shmmax = 536870912
    kernel.shmmni = 4096
    kernel.sem = 250 32000 100 128
    net.ipv4.ip_local_port_range = 9000 65500
    net.core.rmem_default = 262144
    net.core.rmem_max = 4194304
    net.core.wmem_default = 262144
    net.core.wmem_max = 1048586

执行 `sysctl -p` 使配置生效

