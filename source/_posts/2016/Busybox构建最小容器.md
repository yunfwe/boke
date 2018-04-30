---
title: Busybox构建最小容器
date: 2016-04-21 10:12:00
categories: 
    - Docker
tags:
    - busybox
    - docker
---
## <font color='#5CACEE'>简介</font>
>BusyBox 是一个集成了一百多个最常用linux命令和工具的软件。BusyBox 包含了一些简单的工具，例如ls、cat和echo等等，还包含了一些更大、更复杂的工具，例grep、find、mount以及telnet。有些人将 BusyBox 称为 Linux 工具里的瑞士军刀。简单的说BusyBox就好像是个大工具箱，它集成压缩了 Linux 的许多工具和命令，也包含了 Linux 系统的自带的shell。
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=ItVb8LgSfWAdUsJW8rZ-5Zvvkw2nfdZUNAkJ6I9AMzLSy7p2VCtUY2j9_jiAcCUXaJ13OkVk7Rvy3Dp2KIbVfq)
<!-- more -->


## <font color='#5CACEE'>环境</font>
> busybox编译安装方式和编译内核的方式一样 所以需要安装make, ncurses, gcc支持
+ ubuntu: apt-get install make gcc libncurses5-dev
+ centos: yum install make gcc ncurses-devel

|软件名称|版本号|下载地址|
|-|:-:|-:|
|Busybox|1.24.2|[<font color='#AAAAAA'>下载地址</font>](https://busybox.net/downloads/busybox-1.24.2.tar.bz2)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>配置Busybox编译选项</font>
```bash
tar xf busybox-1.24.2.tar.bz2
cd busybox-1.24.2
make menuconfig
```

这时 将打开busybox编译的配置页面 为了方便起见 打算静态编译Busybox

        Busybox Settings  --->          # 这里是对busybox的设置
    --- Applets                         # 以下的都是对小程序的配置
        Archival Utilities  --->
        Coreutils  --->
        Console Utilities  --->
        Debian Utilities  --->
        Editors  --->
        Finding Utilities  ---> 
        Init Utilities  --->
        Login/Password Management Utilities  --->
        
静态编译Busybox属于Busybox的设定 上下键将光标选定Busybox Settings 回车进入

        General Configuration  --->             # 这里是通用配置
        Build Options  --->                     # 这里是编译选项
        Debugging Options  ---> 
        Installation Options ("make install" behavior)  --->    
        Busybox Library Tuning  --->
        
选择Build Options 回车进入

    [*] Build BusyBox as a static binary (no shared libs)       # 在这里
    [ ] Force NOMMU build (NEW)
    [*] Build with Large File Support (for accessing files > 2 GB) (NEW)
    ()  Cross Compiler prefix (NEW)
    ()  Path to sysroot (NEW)
    ()  Additional CFLAGS (NEW)
    ()  Additional LDFLAGS (NEW)
    ()  Additional LDLIBS (NEW)
    
光标处在Build BusyBox as a static binary处 空格键选择 [ ]变成了[*]
然后左右键切换光标到exit 回车回到上一个页面 选择 General Configuration 回车进入

    [*] Show applet usage messages (NEW)
    [*]   Show verbose applet usage messages (NEW)
    [*]   Store applet usage messages in compressed form (NEW)
    [*] Support --install [-s] to install applet links at runtime (NEW)
    [ ] Don't use /usr (NEW)
    [*] Enable locale support (system needs locale for this to work)    # 在这里
    [*] Support Unicode (NEW)
    [ ]   Use libc routines for Unicode (else uses internal ones) (NEW)
    [ ]   Check $LC_ALL, $LC_CTYPE and $LANG environment variables (NEW)
    (63)  Character code to substitute unprintable characters with (NEW)

在 Enable locale support  处摁空格进行勾选 启动locale支持 然后一路的exit 直到以下界面

        Do you wish to save your new configuration? 
 
                < Yes >      <  No  >   
                
选择 < Yes > 后页面将会退出 配置也就完成了 
### <font color='#CDAA7D'>修改源代码 提供中文显示支持</font>
> 默认busybox不支持中文字符显示 接下来修改源代码 提供中文显示支持

    
    vim ./libbb/printable_string.c
    
找到31,32行 删除或注释这两行 
找到45行 将"if (c < ' ' || c >= 0x7f)"注释"|| c >= 0x7f"
    
    29                 if (c < ' ')
    30                         break;
    31         //      if (c >= 0x7f)
    32         //              break;
    
    45          if (c < ' '/* || c >= 0x7f*/)
    46                  *d = '?';

### <font color='#CDAA7D'>开始编译安装</font>
```bash
make
make install
```

这时 busybox已经编译好了 就是当前目录下的busybox文件 检测一下busybox是否可以显示中文

    root@ubuntu:~/busybox-1.24.2# touch 中文测试
    root@ubuntu:~/busybox-1.24.2# ./busybox ls 中文测试
    中文测试
    root@ubuntu:~/busybox-1.24.2# ldd ./busybox
        not a dynamic executable
    
    可以看到 中文名称的文件被正常显示 同时这个程序是个没有依赖的二进制文件
    
    

执行make install后 会将busybox和小程序的软链接都安装到当前目录中的_install/目录中 接下来就是打包为一个能正常启动docker容器

### <font color='#CDAA7D'>打包为docker镜像</font>
> 如果只是编译安装Busybox的话 到这里就完了 下面是如何将Busybox制作为rootfs

    root@ubuntu:~/busybox-1.24.2# cd _install/
    root@ubuntu:~/busybox-1.24.2/_install# ls
    bin  linuxrc  sbin  usr
    
进入_install目录 可以看到已经存在几个busybox安装 小程序链接所存在的必须目录

    root@ubuntu2:~/busybox-1.24.2/_install# ls -lh bin |head 
    total 2.6M
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 ash -> busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 base64 -> busybox
    -rwxr-xr-x 1 root root 2.6M Apr 20 22:24 busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 cat -> busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 catv -> busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 chattr -> busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 chgrp -> busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 chmod -> busybox
    lrwxrwxrwx 1 root root    7 Apr 20 22:24 chown -> busybox

可以看到 其实所有的命令都是软链接到busybox程序的 执行不同的命令 就有不同的效果

    root@ubuntu:~/busybox-1.24.2/_install# bin/date
    Wed Apr 20 23:07:48 EDT 2016
    root@ubuntu:~/busybox-1.24.2/_install# bin/uname -a
    Linux ubuntu 4.2.0-16-generic #19-Ubuntu SMP Thu Oct 8 15:35:06 UTC 2015 x86_64 GNU/Linux

原理非常简单 busybox程序通过判断 $0 也就是自身的名字是什么 来执行相应的功能 默认也可以通过将命令作为 $1 传入busybox

    root@ubuntu:~/busybox-1.24.2/_install# bin/busybox date
    Wed Apr 20 23:11:01 EDT 2016
    root@ubuntu:~/busybox-1.24.2/_install# bin/busybox uname -a
    Linux ubuntu 4.2.0-16-generic #19-Ubuntu SMP Thu Oct 8 15:35:06 UTC 2015 x86_64 GNU/Linux

当前目录下的文件夹还缺少了很多Linux根文件系统存在的文件夹 现在创建这些文件夹

```bash
mkdir etc lib64 mnt proc run tmp var dev home lib media opt root sys
mkdir var/{log,opt,spool,run}
mkdir usr/{include,lib,share,src,local}
mkdir usr/local/{bin,sbin,include,lib,share,src}
cp /etc/{passwd,shadow,gshadow,group} etc/
chmod a+wrxt tmp/
```

    root@ubuntu:~/busybox-1.24.2/_install# ls
    bin  etc   lib    linuxrc  mnt  proc  run   sys  usr
    dev  home  lib64  media    opt  root  sbin  tmp  var

现在再看 好像已经像那么回事了 接下来就是将这个rootfs打包为docker镜像

    root@ubuntu:~/busybox-1.24.2/_install# tar -cf /dev/stdout *|docker import - busybox:1.24.2
    sha256:5b5e476a877a87b5c4c976a2a6db1782c2d89e8177e6f4d9658127320d27c1cb
    root@ubuntu:~/busybox-1.24.2/_install# docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    busybox             1.24.2              5b5e476a877a        10 seconds ago      2.635 MB
    
通过tar命令 将归档数据传入标准输出 通过管道符提交给docker去导入 然后命名新镜像为busybox:1.24.2 可以看到已经导入成功了 大小仅仅2.635 MB

### <font color='#CDAA7D'>测试Busybox运行效果</font>
> 从busybox镜像启动一个新的容器 进行简单的命令测试 以后打包服务为docker镜像时就可以使用这个镜像为基础了

    root@ubuntu:~/busybox-1.24.2/_install# docker run -ti --rm busybox:1.24.2 sh
    / # ifconfig eth0
    eth0      Link encap:Ethernet  HWaddr 02:42:AC:12:00:07  
              inet addr:172.18.0.7  Bcast:0.0.0.0  Mask:255.255.0.0
              inet6 addr: fe80::42:acff:fe12:7/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:6 errors:0 dropped:0 overruns:0 frame:0
              TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0 
              RX bytes:508 (508.0 B)  TX bytes:508 (508.0 B)

    / # ls /
    bin      etc      lib      linuxrc  mnt      proc     run      sys      usr
    dev      home     lib64    media    opt      root     sbin     tmp      var


## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>Busybox容器通过远程连接访问</font>
> buxybox自带了telnetd小程序 这样就可以通过telnet工具远程登录这个容器了

    / # telnetd             # 启telnetd程序 可以看到已经正常监听23端口
    / # netstat -anpt
    Active Internet connections (servers and established)
    Proto Recv-Q Send-Q Local Address       Foreign Address      State      PID/Program name    
    tcp        0      0 :::23               :::*                 LISTEN     8/busybox
    / # adduser busybox     # 然后添加一个远程登录的用户名 默认是禁止root登录
    Changing password for busybox
    New password: 
    Bad password: too weak
    Retype password: 
    Password for busybox changed by root

添加用户的同时会让你更改用户密码 接下来就可以试试用telnet工具远程登录到这个容器了

    root@ubuntu:~# telnet 172.18.0.7
    Trying 172.18.0.7...
    Connected to 172.18.0.7.
    Escape character is '^]'.

    ea68afe67966 login: busybox
    Password: 
    ~ $ date
    Thu Apr 21 03:50:10 UTC 2016
    ~ $

如果想切换到root用户 需要给busybox添加suid权限 在上一个本地会话中完成添加 

    / # chmod +s /bin/busybox
    / # vi /etc/passwd              # 由于不存在bash 切换root时会出错 所以需要更改root的默认shell
        root:x:0:0:root:/root:/bin/sh
    / # passwd root                 # 给root配置一个复杂些的密码
    Changing password for root
    New password: 
    Retype password: 
    Password for root changed by root
    / # 
    
然后回到telnet登录的会话中 用 su 命令切换到root用户 切换成功
    
    ~ $ su
    Password: 
    /home/busybox #
    
不仅telnetd服务 busybox还提供了httpd, udhcpd, tftpd, ntpd, dnsd等服务 还包括了linux常用的三四百条命令 真的是麻雀虽小五脏俱全  这样 一个功能强大 大小仅2.6MB的docker镜像就制作完成了