---
title: PXE无人值守装机
date: 2016-09-31 10:13:00
categories: 
    - PXE
tags:
    - dhcp
    - tftp
---

## <font color='#5CACEE'>简介</font>
PXE是一种能够让计算机通过网络启动的引导方式，只要网卡支持PXE协议即可使用
虚拟机也支持PXE安装系统，实验中用一台CentOS6.7的虚拟机为另一台虚拟机安装系统

<!-- more -->

### 主机环境
|身份|系统|IP|
|-|:-:|-:|
|PXE服务端|CentOS 6.7|10.0.0.2|
|PXE客户端|待安装CentOS 6.7|由dhcpd服务分配|

软件环境
tftpd和dhcpd是PXE必须的程序 nginx只是为了让PXE客户端通过HTTP安装系统
同样PXE还支持通过FTP和NFS的方式 只需要将nginx换成提供相应服务的程序即可

### 软件包
tftpd	通过yum源安装
dhcpd	通过yum源安装
nginx	查看博客中nginx的编译安装教程

## 步骤
PXE模式装机原理是：

客户机从自己的PXE网卡启动 向局域网中的DHCP服务器请求IP地址和引导文件路径
DHCP服务器响应客户机请求 返回IP地址信息和引导文件路径
客户机向局域网中的TFTP服务器请求引导文件
TFTP服务器返回引导文件 客户机执行这个文件 进入引导界面
自动或用户手动选择引导项 客户机通过TFTP请求相应的内核和文件系统
此刻进入安装界面 通过HTTP/FTP/NFS方式之一进行系统安装
配置DHCP服务

注意：请确保系统的iptables防火墙和selinux已经关闭或者配置好相应的规则
iptables: service iptables stop
selinux: setenforce 0

### 安装DHCP软件包
yum安装dhcp程序 如果用虚拟机做实验 需要先关闭虚拟机产品提供的DHCP服务

yum install dhcp

修改配置文件
DHCPD服务程序配置文件为/etc/dhcp/dhcpd.conf

vim /etc/dhcp/dhcpd.conf 

subnet 10.0.0.0 netmask 255.255.255.0 {         # 子网网段声明
    option subnet-mask      255.255.255.0;      # 子网掩码
    range 10.0.0.20 10.0.0.200;                 # 地址池
    default-lease-time      21600;              # 默认租约时间
    max-lease-time          43200;              # 最大租约时间
    filename                "pxelinux.0";       # 引导文件地址
}

service dhcpd start                 # 启动DHCPD服务 监听UDP 67端口

用服务控制脚本启动服务可能会遇到服务无法启动的问题 
在确保不是因为配置文件不正常的情况下 可以直接通过dhcpd命令启动服务

/usr/sbin/dhcpd -4 -user dhcpd -group dhcpd

[root@localhost ~]# netstat -anpu
udp    0    0 0.0.0.0:67        0.0.0.0:*           2861/dhcpd     

### 配置TFTP服务

安装TFTP软件包
yum install tftp-server
修改配置文件
tftp程序由xinetd进行管理 配置文件为 /etc/xinetd.d/tftp

vim /etc/xinetd.d/tftp

    service tftp
    {
            socket_type             = dgram
            protocol                = udp
            wait                    = yes
            user                    = root
            server                  = /usr/sbin/in.tftpd
            server_args             = -s /var/tftp      # tftp的文件根目录 可以自己定义
            disable                 = no                # 注意 要将yes改为no
            per_source              = 11
            cps                     = 100 2
            flags                   = IPv4
    }

    service xinetd restart          # 重新启动xinetd服务 tftp监听UDP 69端口

    in.tftpd -l -s /var/tftp/       # 或者通过绝对路径启动

    [root@localhost ~]# netstat -anpu
    udp    0    0 0.0.0.0:69       0.0.0.0:*           2919/xinetd
配置HTTP服务
这里采用Nginx作为HTTP服务器程序 也可以选择apache等可以提供HTTP服务的程序 安装方式不限 也可以通过yum源安装

编译安装Nginx
服务器	安装文档地址
Nginx	点击打开文档内容
修改配置文件
修改web服务的根目录

  vim nginx.conf
    http {
        ...
        server {
            listen       80;
            server_name  localhost;

            location / {
                root   /var/www/html;           # 一会需要将系统镜像解压的位置
                index  index.html index.htm;
            }
            ...
        }
        ...
    }

  /usr/local/nginx/sbin/nginx                 # 启动nginx服务

  [root@localhost ~]# netstat -anpt
  tcp    0    0 0.0.0.0:80       0.0.0.0:*         LISTEN      8524/nginx

准备PXE装机需要的文件
以下列出一些PXE方式安装CentOS6.7所必须的文件

    文件名称	作用	获取方式
    pxelinux.0	系统引导程序 也就是bootloader	来自软件包: syslinux
    isolinux.cfg	引导模板文件 与grub.conf类似	CentOS6.7系统镜像
    vmlinuz,initrd.img	内核与内存盘镜像 启动安装进程	CentOS6.7系统镜像
    ks.cfg	无人值守安装的自动应答文件	anaconda-ks.cfg文件
    CentOS6.7镜像	系统安装镜像	镜像下载地址

当PXE申请到IP地址和引导文件地址后 通过TFTP的方式获取这个引导程序 之后PXE将执行这个引导程序 控制权交给了pxelinux.0
之后 pxelinux.0会根据pxelinux.cfg配置的内容去加载内核 等内核文件获取成功后 控制权交给了内核 内核启动系统安装进程
剩下的步骤和普通系统的安装方式没什么区别了 只不过需要将系统安装的介质设置为通过网络方式进行安装 这个就是由HTTP/FTP/NFS方式提供的服务
每次安装完新系统后 在root的家目录下都会出现anaconda-ks.cfg这个文件 这个文件就是记录了系统安装过程中的交互信息 不同的主机产生的anaconda-ks.cfg文件是有些不同的 比如磁盘分区不同 网卡信息不同等 都会导致anaconda-ks.cfg文件不同 所以需要修改这个文件 改为适合自己实际环境的

将文件放入相应的位置
根据前面的配置 tftp的目录在/var/tftp http服务的目录在/var/www/html

```
yum install -y syslinux
cp /usr/share/syslinux/pxelinux.0 /var/tftp          # 复制引导程序
mount -o loop CentOS-6.7-x86_64-bin-DVD1.iso /media/      # 将镜像挂载到/media目录
cp /media/images/pxeboot/{vmlinuz,initrd.img} /var/tftp   # 复制内核文件
cp /media/isolinux/{vesamenu.c32,boot.msg} /var/tftp # pxelinux.0要用到的程序等文件
mkdir /var/tftp/pxelinux.cfg                         # 引导模板文件文件放在这个目录中
cp /media/isolinux/isolinux.cfg /var/tftp/pxelinux.cfg/default 
cp /media/isolinux/splash.jpg /var/tftp/
# isolinux.cfg被重命名为default splash.jpg是引导界面显示的图片 这个并非必须的
cp -rf /media/* /var/www/html                        # 将镜像的所有文件放到web目录下
cp /root/anaconda-ks.cfg /var/www/html/ks.cfg        # 复制自动应答文件
chmod -R a+r /var/www/html/                          # 赋予所有文件读取权限
```
此刻 /var/tftp 下的文件应该是这样子的
[root@localhost ~]# ls /var/tftp/
boot.msg  initrd.img  pxelinux.0  pxelinux.cfg  splash.jpg  vesamenu.c32  vmlinuz

vim /var/tftp/pxelinux.cfg/default   编辑引导模板文件
```
default vesamenu.c32
#prompt 1
timeout 600
display boot.msg
menu background splash.jpg
menu title Welcome to CentOS 6.7!
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color scrollbar 0 #ffffffff #00000000
label linux
  menu label ^Install or upgrade an existing system
  menu default
  kernel vmlinuz ks=http://10.0.0.2/ks.cfg
  append initrd=initrd.img
label vesa
  menu label Install system with ^basic video driver
  kernel vmlinuz
  append initrd=initrd.img nomodeset
label rescue
  menu label ^Rescue installed system
  kernel vmlinuz
  append initrd=initrd.img rescue
label local
  menu label Boot from ^local drive
  localboot 0xffff
label memtest86
  menu label ^Memory test
  kernel memtest
  append -
```
需要注意修改的地方是需要给内核提供ks文件的地址

    label linux
      menu label ^Install or upgrade an existing system
      menu default
      kernel vmlinuz ks=http://10.0.0.2/ks.cfg          # ks.cfg文件的访问地址
      append initrd=initrd.img

    vim /etc/var/www/html/ks.cfg 编辑ks.cfg文件
    install
    url --url=http://10.0.0.2              
    ...
    repo --name="CentOS"  --baseurl=http://10.0.0.2 --cost=100
    reboot
    %packages --nobase
    @core
    %end

注意：需要修改安装介质 要由 cdrom 改为 url --url=http://10.0.0.2
同时这个web服务还是个yum源 系统安装需要从这里下载rpm包
添加reboot指令会让机器安装完系统后自动重启

接下来就可以新建一台虚拟机 选择PXE引导 来看看是否正常进入安装界面了

如果客户机没有正常进入引导界面
从iptables防火墙策略、服务是否正常启动、文件路径是否正确、以及客户机是否有读取权限
附录
dnsmasq搭建PXE装机环境
ks.cfg自动应答文件详解
isolinux.cfg引导模板文件详解
PXE装机是非常简单的 难点在于ks.cfg的配置 因为想要实现只需要打开服务器电源按钮 就可以自动安装系统并重启是比较费心的 因为不同的服务器有不同的配置 同一个ks.cfg文件并不一定合适所有的服务器
CentOS6.7的镜像也可以解压到其他服务器上 只要配置了合适访问方式即可

ks.cfg文件也可以通过system-config-kickstart命令进行生成 这个工具会模拟安装系统时所有的交互 然后记录用户的选择等信息 最后保存为ks.cfg文件 需要图形化界面支持
安装方式：yum install system-config-kickstart
启动方式 system-config-kickstart