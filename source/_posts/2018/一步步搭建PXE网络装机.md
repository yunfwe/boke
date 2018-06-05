---
title: 一步步搭建PXE网络装机
date: 2018-06-03 14:44:00
categories: 
    - PXE
tags:
    - pxe
photos:
    - /uploads/photos/b869de9f1d.jpg
---

## 简介
> PXE (preboot execute environment，预启动执行环境) 是由 Intel 公司设计的协议，它可以使计算机通过网络启动。当计算机引导时，BIOS 把 PXE client 调入内存执行，并显示出命令菜单，经用户选择后，PXE client将放置在远端的操作系统通过网络下载到本地运行。除了可以通过网络直接运行操作系统外，也可以用于通过网络来将系统安装到本地。在运维中工作中，通过 PXE 来为机房服务器批量部署系统是非常方便的。

<!-- more -->

## 环境

PXE 对运行环境没有什么需求，只需能提供 `tftp`, `dhcp`, `http` 等服务的系统即可。这里使用 Linux 环境来搭建PXE服务。使用 `dnsmasq` 这个小巧玲珑的软件提供 `tftp` 和 `dhcp` 服务，使用 `Nginx` 来提供 `http` 服务。

## 步骤

PXE 的启动原理是 PXE client 在网卡的 ROM 中，可以在计算机开机的时候选择通过硬盘引导还是 PXE 等引导方式，比如 DELL 的服务器在出现开机 LOGO 画面后通过键入 `F12` 来进入 PXE 引导，Vmware 新创建的虚拟机在第一次启动的时候如果没有装载光驱或者ISO镜像，则会尝试通过网络引导。如果是笔记本或者台式机可以在开机的时候进入引导菜单，然后选择通过网卡设备启动。

当进入 PXE 引导界面后，PXE client 会向网络中的 dhcp 服务器请求IP地址，dhcp 服务器发现是个 PXE client 的请求会将分配好的IP和引导程序的访问地址返回给 PXE client。这个引导程序一般是名为 `pxelinux.0` 的文件，这个文件是通过 tftp 协议发送给 PXE client 的。当客户端成功获取到引导文件和引导文件的相关配置文件后就成功加载出引导菜单。这个菜单则是我们通过更改 `pxelinux.0` 的配置文件来的。下面是通过Vmware引导的效果：
![](/uploads/2018/pxe/8s7gt0i5pp7jj4k9.jpg)

如果在30秒内没做任何选择则默认从本地磁盘启动，这样就避免了某些将PXE启动作为第一启动项的服务器重启后误重装系统。当选择了某个项目的时候，比如 `Install CentOS6.8 for vmware` 则向服务器获取根据配置文件中指定的 CentOS 内核文件和启动参数。当需要的数据都准备好后，系统则开始启动 Linux 内核，接下来的操作就跟普通的安装系统没两样了，只不过需要的数据都是通过网络获取的。比如安装 CentOS 过程中需要的所有 rpm 包都是通过 http 服务提供的 CentOS 镜像站提供的了。

但是如何通过 PXE 来同时安装成百上千台服务器呢？在安装系统的过程中，总会遇到各种需要交互的地方，比如给硬盘分区，选择语言，创建用户等地方，幸好大部分的系统安装镜像都支持通过 Kickstart 自动应答在安装过程中免人工干预的进行系统安装。就像是你的所有问题的回答我先写成一个文件，然后你需要问的时候先从文件中找答案一样。自动应答文件通常是 `ks.cfg` 文件，此文件的位置大多通过在启动 Linux 内核的时候通过启动参数的方式告诉内核。

接下来就看看 PXE 启动该如何配置。

### 服务配置

#### 安装 dnsmasq

可以首先从Linux发行版的官方仓库中找找有没有 `dnsmasq` 的软件包，如果没有可以下载编译。

**编译方法：**
```bash
cd /usr/local/src/
wget http://www.thekelleys.org.uk/dnsmasq/dnsmasq-2.79.tar.xz
tar xf dnsmasq-2.79.tar.xz
cd dnsmasq-2.79 && make
cp src/dnsmasq /usr/local/bin/
```

只需要将 dnsmasq 的二进制文件放到系统环境变量就可以了，接下来给它提供一个配置文件来告诉它要启动哪些服务。源码目录下有一个官方提供的配置文件模板，不过我们并不需要这么多的配置。

```bash
mkdir -p /data/pxeboot          # PXE启动所需要的文件就都放到这里了
cd /data/pxeboot
vim dnsmasq.conf
```
然后写入以下内容：

    # enable dhcp
    dhcp-range=192.168.4.10,192.168.4.200,12h
    dhcp-option=3,192.168.4.254
    dhcp-option=option:dns-server,114.114.114.114,119.29.29.29
    #dhcp-boot=pxelinux.0
    dhcp-boot=undionly.kpxe

    # disable dns
    port=0

    # enable tftp
    enable-tftp
    tftp-root=/data/pxeboot

一定要注意，`dhcp-range` 给客户端分配的IP地址池一定要是自己网段的。根据前面讲解的 PXE 启动的原理，可能大家会比较好奇，为什么这里 dhcp 推送的是 `undionly.kpxe` 这个文件呢？这个会在下面讲到，接下来就可以先启动 dnsmasq 了。

```bash
dnsmasq -C dnsmasq.conf -d      # 如果不加 -d 参数，dnsmasq 则进入后台运行
```

    [root@localhost pxeboot]# dnsmasq -C dnsmasq.conf -d
    dnsmasq: started, version 2.79 DNS disabled
    dnsmasq: compile time options: IPv6 GNU-getopt no-DBus no-i18n no-IDN ......
    dnsmasq-dhcp: DHCP, IP range 192.168.4.10 -- 192.168.4.200, lease time 12h
    dnsmasq-tftp: TFTP root is /data/pxeboot 

现在基础的 `dhcp` 和 `tftp` 服务已经搭建完成了，`dhcp` 监听在 `udp 67` 端口，`tftp` 监听在 `udp 69`，使用前最好关闭服务器的 selinux 和 iptables。

#### 安装 Nginx

也不一定非要使用 Nginx，只要是能提供通过 HTTP 协议对文件进行访问服务的程序都可以，只不过感觉 Nginx 用起来更得心应手一些。同样，如果可以从发行版的官方仓库安装就非常省事了，或者手动编译也可以。

**编译方法：**

```bash
cd /usr/local/src/
wget http://nginx.org/download/nginx-1.14.0.tar.gz
tar xf nginx-1.14.0.tar.gz
cd nginx-1.14.0
./configure --prefix=/usr/local/nginx --without-http_rewrite_module
make -j4 && make install
```

因为用不到 Nginx 的 rewrite 规则，而且这个模块依赖 pcre 库，所以就去掉了，接下来简单的配置下 Nginx。

```bash
mkdir -p /data/wwwroot/pxefiles         # /data/wwwroot 作为HTTP根目录
vim /usr/local/nginx/conf/nginx.conf
```
然后写入以下内容：

    worker_processes  4;
    events {
        worker_connections  1024;
    }
    http {
        include       mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        autoindex       on;
        keepalive_timeout  65;
        server {
            listen       80;
            server_name  localhost;
            location / {
                root   /data/wwwroot;
                index  index.html index.htm;
            }
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   html;
            }
        }
    }

```bash
/usr/local/nginx/sbin/nginx     # 启动Nginx服务
```

#### 安装 ipxe 引导文件

为什么这里又出现了 ipxe 引导文件呢？理论上来说，只是用 pxelinux.0 确实也可以引导各种系统，但是 pxelinux.0  只支持使用 tftp 协议来加载需要的文件。 tftp 在使用 UDP 传输数据，为了保证文件的完整性，tftp 自己实现了一套数据校验机制，但是却大大降低了文件传输效率。而且某些未知情况下 tftp 在局域网内居然只有 KB 级别的传输速率。于是，一些支持 http 、ftp、nfs 等文件传输协议的引导程序诞生了，ipxe 就是其中一种。

ipxe 提供的引导文件针对不同使用场合又分好几种，比如 `.pxe`，`.kpxe`，`.kkpxe` 格式的引导文件。比较常见的是 `.pxe`，`.kpxe`，其中的区别可以看这里：[点此打开](http://etherboot.org/wiki/gpxe_imagetypes)，这里使用 `undionly.kpxe` 引导文件，采用链式加载的方法加载 pxelinux.0。这样就可以实现既使用 ipxe 提供的网络协议支持，还可以使用 pxelinux.0 提供的引导界面了。

**编译 undionly.kpxe：**

```bash
cd /usr/local/src/
git clone git://git.ipxe.org/ipxe.git
cd ipxe/src
vim embed.ipxe
```
写入如下内容：

    #!ipxe
    dhcp
    chain tftp://${next-server}/menu.ipxe

其中 `${next-server}` 会自动解析为 dhcp 服务器的地址，tftp 也搭建在这个地址上。当通过 dhcp 获取到IP地址后，通过 tftp 协议请求 `menu.ipxe` 文件，然后 ipxe 会解析和执行文件里的内容，这个文件可以说就是 ipxe 的配置文件了。接着编译出 undionly.kpxe，这样 undionly.kpxe 才会默认就加载同目录下的 menu.ipxe 文件了。

```bash
make bin/undionly.kpxe EMBED=embed.ipxe
cp bin/undionly.kpxe /data/pxeboot/
```

其中编译步骤需要 `lzma.h` 这个头文件，需要安装你的发行版上提供这个头文件的软件包。编译好的 `undionly.kpxe` 可以保存下来下次搭建环境的时候直接用，如果服务是搭建在 Windows 系统上也可以使用这个编译好的文件。

然后编辑 `menu.ipxe` 文件，配置接下来的文件都通过 http 协议来访问，并且链接到 pxelinux.0。

```bash
vim /data/pxeboot/menu.ipxe
```
写入如下内容：

    #!ipxe
    set 210:string http://192.168.4.6/pxefiles/
    set 209:string pxelinux.cfg/default
    chain ${210:string}pxelinux.0

其中 `set 210:string` 定义了请求的文件的主目录，因为之前创建的 `/data/wwwroot/` 为 http 的根目录，`/data/wwwroot/pxefiles/` 目录中存放 pxelinux.0 相关的数据文件。其中的服务器IP地址需要替换为你实际的服务器IP。
`set 209:string` 则定义了 pxelinux.0 直接加载 `pxelinux.cfg/default` 这个配置文件，否则 pxelinux.0 会阶梯性的查找配置文件，如果都没找到最后默认才加载 `pxelinux.cfg/default`。

#### 安装 pxelinux.0 引导文件

接下来的操作就是在 `/data/wwwroot/pxefiles/` 目录下进行了，因为 `ipxe` 启动后剩下的文件都是通过 http 协议访问的。

pxelinux.0 可以通过发行版的 `syslinux` 包来获取，或者自己从官方下载也可，这里采用从官方下载的方式。

```bash
cd /usr/local/src/
wget https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing/3.86/syslinux-3.86-pre4.tar.xz
tar xf syslinux-3.86-pre4.tar.xz
cd syslinux-3.86-pre4
cp com32/menu/vesamenu.c32 /data/wwwroot/pxefiles/
cp core/pxelinux.0 /data/wwwroot/pxefiles/
```

syslinux 最新版是16年发布的 6.04，但是使用中发现无法引导 ESXI，而且 pxelinux.0 引导后还要加载好几个 `.c32` 文件，所以采用老一点的 3.86 版本。 接着给 pxelinux.0 提供配置文件

```bash
cd /data/wwwroot/pxefiles/
mkdir pxelinux.cfg
vim pxelinux.cfg/default
```
写入以下内容：

    default vesamenu.c32
    timeout 300

    menu title Welcome to PXE server!
    menu background splash.jpg
    menu color border 0 #ffffffff #00000000
    menu color sel 7 #ffffffff #ff000000
    menu color title 0 #ffffffff #00000000
    menu color tabmsg 0 #ffffffff #00000000
    menu color unsel 0 #ffffffff #00000000
    menu color hotsel 0 #ff000000 #ffffffff
    menu color hotkey 7 #ffffffff #ff000000
    menu color scrollbar 0 #ffffffff #00000000

    label local
        menu label Boot from local drive
        menu default
        localboot 0xffff
      
这里为了界面美观使用了一张背景图片: `splash.jpg`，图片需要是一张 640*480 像素的 jpg 图片，并根据图片的主题颜色调整下页面边框、文字等颜色，如果不需要使用背景图片的话可以将 `menu background` 和 `menu color` 的配置项都删掉或者注释掉。

其中 `timeout 300` 会在引导界面30秒无操作就就启动下面 `label` 中定义为 `menu default` 的条目。到这一步已经可以尝试将虚拟机或者主机通过 PXE 启动，看看是否可以加载出引导界面了。
![](/uploads/2018/pxe/6vkt321i87dn5iut.jpg)

接下来，试试通过 PXE 实际启动或安装一些系统吧！

### 网络启动
> 即使是通过网络安装，也是需要系统的镜像包的。最好先将需要安装的系统的镜像下载到本地，当然如果对自己网速很自信的话是可以直接通过公网来安装系统的(方法见附录)。

#### 安装 CentOS

##### 下载系统镜像

下载最新的CentOS镜像可以去官网或者国内的镜像站找，旧版本的可以在[官网](https://wiki.centos.org/Download)里找到。或者一个简单的方法，`http://mirror.nsc.liu.se/centos-store/6.8/isos/x86_64/`  把其中的6.8改为相应的版本号就可以了。

这里使用和机房服务器系统版本一致的 CentOS 6.8 镜像，如果只是想安装一个最小化的 CentOS 系统的话，选择 `minimal.iso`，而如果想安装带桌面的甚至想搭建一个本地的yum源，就使用 `bin-DVD1.iso` 和 `bin-DVD2.iso` 这两个镜像。其中 `bin-DVD2.iso` 不可用于系统安装，因为里面只是额外的RPM包，搭建 yum源的话可以将两个镜像的内容合并到一个目录中。还有个是 `LiveCD.iso` 或者 `LiveDVD.iso` 的镜像，这种镜像可以直接刻录到光盘并从光盘启动系统。

这里直接使用 `bin-DVD` 的镜像。

##### 配置安装源

首先将 `bin-DVD1.iso` 和 `bin-DVD2.iso` 的内容合并到一个目录中
```bash
mkdir -p /data/wwwroot/yum/CentOS6.8/ 
mount -o loop CentOS-6.8-x86_64-bin-DVD1.iso /mnt/
cp -rf /mnt/* /data/wwwroot/yum/CentOS6.8/
umount /mnt/
mount -o loop CentOS-6.8-x86_64-bin-DVD2.iso /mnt/
cp -rf /mnt/* /data/wwwroot/yum/CentOS6.8/      # 所有同名文件都覆盖掉
umount /mnt/
ln -s /data/wwwroot/yum/ /data/wwwroot/pxefiles/yum  
```

这里创建了一个软链接的原因是 `menu.ipxe` 中定义为pxe主目录在 `/data/wwwroot/pxefiles/` 中。

##### 准备自动应答文件

每次安装完 CentOS 的系统后不知道大家是否有留意root用户家目录下的三个文本文件 `anaconda-ks.cfg`，`install.log`，`install.log.syslog`。其中 `anaconda-ks.cfg` 就是系统安装过程中的所有问答产生的 `ks.cfg` 自动应答文件，这个是可以直接拿来用的。

如果这个文件被删除了，那么也可以通过软件包 `system-config-kickstart` 来定制，此工具需要在图形化界面下或者配置好了X11转移的环境中使用。使用 `yum -y install system-config-kickstart` 安装后使用 `system-config-kickstart` 运行程序。
![](/uploads/2018/pxe/5mqiz0t4cj3kl885.png)

配置好后使用 `Ctrl+S` 保存并退出，将制作好的 `ks.cfg` 文件或者 `anaconda-ks.cfg` 复制到刚才创建的yum源中。因为不同的主机类型可能对应着不同的自动应答文件，所以可以保存为针对不同安装类型或平台的自动应答文件。

```bash
cp /root/anaconda-ks.cfg /data/wwwroot/yum/CentOS6.8/ks-minimal-vmware.cfg
```

`ks-minimal-vmware.cfg` 文件内容为：

    install
    reboot
    text
    url --url=http://192.168.4.6/yum/CentOS6.8
    lang zh_CN.UTF-8
    keyboard us
    network --onboot yes --device eth0 --mtu=1500 --bootproto dhcp --noipv6
    # root passwd : 123456
    rootpw  --iscrypted $6$5dCFp4Me$YkPWb8h0M/wRUPH3puKXcmbhsErJxfFPCXTtIzfglpfHriMBJsRtqjS5Ewh6Vj/h3mnRdXfsAGcadD3TpRAlk1
    firewall --service=ssh
    authconfig --enableshadow --passalgo=sha512
    selinux --disabled
    timezone --utc Asia/Shanghai
    bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb rhgb quiet quiet"
    zerombr
    clearpart --all --drives=sda
    part /boot --fstype=ext4 --size=500
    part swap --size=2048
    part / --fstype=ext4 --grow --size=1
    repo --name="CentOS"  --baseurl=http://192.168.4.6/yum/CentOS6.8 --cost=100
    %packages
    @Base
    @Core
    %post
    cd /etc/yum.repos.d/
    mkdir bak
    mv * bak
    cat >> CentOS-Base.repo <<END
    [base]
    name=CentOS-$releasever Base
    baseurl=http://192.168.4.6/yum/CentOS6.8
    enabled=1
    gpgcheck=0
    END
    yum update
    yum -y install lrzsz

其中配置了 root 密码为 `123456`，只安装了最基础的软件包。在安装完之后自动配置系统的yum源到本地服务器上，并且安装 `lrzsz` 工具包。这里密码是通过加密后的，也可以直接使用 `rootpw 123456` 这种方式。其中 `reboot` 会在安装完成后自动重启。


##### 添加PXE启动项

该为 pxelinux.0 添加 CentOS6.8 的启动项了，编辑 `pxelinux.cfg/default`，在 `label local` 前添加如下配置块：

    label centos6.8
        menu label Install CentOS6.8 for vmware (minimal install)
        kernel /yum/CentOS6.8/images/pxeboot/vmlinuz
        append initrd=/yum/CentOS6.8/images/pxeboot/initrd.img ks=http://192.168.4.6/yum/CentOS6.8/ks-minimal-vmware.cfg ksdevice=eth0

`kernel` 和 `initrd` 可以使用文件对于URL的相对路径，加载的内核也是 CentOS 镜像中提供的支持PXE启动的内核文件。`ks` 是传给内核的参数，制定了自动应答文件的位置。内核启动后就不是由PXE控制网卡了，就无法使用相对路径的方式获取文件，所以自动应答文件要使用全路径。`ksdevice` 在单网卡的情况下可以不指定，如果是多网卡的服务器不指定 `ksdevice` 的话，安装过程则会停在让你手动选择要使用的网卡界面。

##### 开始安装

再次进入PXE引导界面，可以看到刚才新加的启动项生效了，接着选择它并回车。
![](/uploads/2018/pxe/3ihwi58wc69mw74s.jpg)

可以看到剩下的过程根本没有人工干预就安装完成了。
![](/uploads/2018/pxe/x4veg4eehtzk2o75.jpg)

安装完成后会自动重启。

#### 安装 Ubuntu

##### 下载系统镜像

镜像可以从Ubuntu官网下载，也可以在中科大或其他的国内开源镜像站中下载。[点此打开](http://mirrors.ustc.edu.cn/ubuntu-releases/)

这里使用 `ubuntu-16.04.4-server-amd64.iso` 这个镜像，最新的 `ubuntu-18.04` 并没有经过测试，不知道是否还能用此方法进行安装。

##### 配置安装源

同理将镜像解压到web目录。

```bash
mkdir -p /data/wwwroot/apt/ubuntu16.04
mount -o loop ubuntu-16.04.4-server-amd64.iso /mnt/
cp -rf /mnt/* /data/wwwroot/apt/ubuntu16.04
umount /mnt/
ln -s /data/wwwroot/apt/ /data/wwwroot/pxefiles/apt
```

##### 准备自动应答文件

也可以在 ubuntu 上使用 `system-config-kickstart` 工具来制作自动应答文件，使用前先安装：`apt install system-config-kickstart`。ubuntu 的自动应答文件不可以和 CentOS 的通用。

```bash
vim /data/wwwroot/apt/ubuntu16.04/ks-server-vmware.cfg
```

文件内容如下：

    lang en_US
    langsupport en_US
    keyboard us
    mouse
    timezone Asia/Shanghai
    rootpw --disabled
    # ubuntu password: 123456
    user ubuntu --fullname "ubuntu" --iscrypted --password $1$4C9x9TxO$PfPaSIUWQwN80J0MtEyQ3.
    reboot
    text
    install
    url --url http://192.168.4.6/apt/ubuntu16.04/
    bootloader --location=mbr 
    zerombr yes
    clearpart --all --initlabel 
    part / --fstype ext4 --size 1 --grow 
    part swap --size 2048 
    auth  --useshadow  --enablemd5 
    network --bootproto=dhcp --device=eth0
    firewall --disabled 
    skipx
    %packages
    @^minimal
    @core
    openssh-server

其中新建了一个叫 `ubuntu` 的用户，用户密码是 `123456`。默认没有配置root用户的密码，可以使用普通用户登陆后使用 `sudo` 来切换到 root 用户。ubuntu 默认是不允许 root 用户登陆的，需要修改 `/etc/ssh/sshd_config` 中的 `PermitRootLogin` 为 `yes`。

##### 添加PXE启动项

编辑 `pxelinux.cfg/default` 添加如下 `label` 块：

    label ubuntu server 16.04
        menu label Install Ubuntu server 16.04.4 (minimal install)
        kernel /apt/ubuntu16.04/install/netboot/ubuntu-installer/amd64/linux
        append initrd=apt/ubuntu16.04/install/netboot/ubuntu-installer/amd64/initrd.gz ks=http://192.168.4.6/apt/ubuntu16.04/ks-server-vmware.cfg  --- quiet live-installer/net-image=http://192.168.4.6/apt/ubuntu16.04/install/filesystem.squashfs

##### 开始安装

![](/uploads/2018/pxe/2b5ofwx57dqotb0o.jpg)

![](/uploads/2018/pxe/8rpwsvrzb3qmt4n1.png)

安装完成后会自动重启。

#### 安装 ESXI

##### 下载系统镜像

在官网下载需要登陆，[官方下载地址](https://my.vmware.com/web/vmware/details?downloadGroup=ESXI650&productId=614)。如果是用于服务器安装，那最好找找有没有服务器官方提供的针对服务器硬件的 ESXI 版本，比如戴尔官方提供的定制版 ESXI [戴尔官方下载地址](https://www.dell.com/support/article/cn/zh/cndhs1/sln290857/dell%E5%AE%9A%E5%88%B6%E7%9A%84esxi-%E7%B3%BB%E7%BB%9F%E4%B8%8B%E8%BD%BD%E5%8F%8A%E7%89%88%E6%9C%AC%E8%AF%B4%E6%98%8E?lang=zh)

这里使用戴尔官方提供的 `VMware ESXi 5.5 Update 3` [点此下载](https://downloads.dell.com/FOLDER03324804M/1/VMware-VMvisor-Installer-5.5.0.update03-3029944.x86_64-Dell_Customized-A00.iso)

##### 配置安装源

ESXI 的镜像比较特殊，需要做些调整才可以通过 PXE 安装。
```bash
mkdir -p /data/wwwroot/esxi/5.5
mount -o loop VMware-VMvisor-Installer-5.5.0.update03-3029944.x86_64-Dell_Customized-A00.iso /mnt
cp -rf /mnt/* /data/wwwroot/esxi/5.5/
umount /mnt
ln -s /data/wwwroot/esxi/ /data/wwwroot/pxefiles/esxi
```

修改 `exsi/5.5` 目录中的 `boot.cfg`

```bash
sed -i '1a\prefix=/esxi/5.5/' /data/wwwroot/esxi/5.5/boot.cfg
sed -i '6s/\///g' /data/wwwroot/esxi/5.5/boot.cfg
sed -i 's/^kernel=.*$/kernel=tboot.b00/g' /data/wwwroot/esxi/5.5/boot.cfg
```

##### 准备自动应答文件

编辑 `/data/wwwroot/esxi/5.5/ks.cfg`，写入如下内容：

    accepteula
    rootpw 12345678
    clearpart --firstdisk=local --overwritevmfs
    install --firstdisk=local  --overwritevmfs
    network --bootproto=dhcp --device=vmnic0
    reboot

root 用户的密码是 `12345678`

##### 添加PXE启动项

编辑 `pxelinux.cfg/default` 添加如下 `label` 块：

    LABEL Install ESXI 5.5 for dell
        MENU Install ESXI 5.5 for dell
        kernel /esxi/5.5/mboot.c32
        append -c /esxi/5.5/boot.cfg ks=http://192.168.4.6/esxi/5.5/ks.cfg 

##### 开始安装

虽然下载的是针对服务器的，但是为了方便截图依然使用虚拟机测试。需要注意的是，虚拟机安装 ESXI 需要将操作系统设置为 `VMware EXS(X)`
![](/uploads/2018/pxe/a05bhdk9pm6i7c3c.png)

然后正常进入PXE引导菜单
![](/uploads/2018/pxe/b9k26937082vpanv.jpg)

![](/uploads/2018/pxe/6sj1599227upe6k0.png)

安装完成后会自动重启。

#### 安装 Windows

Windows 系统的安装就比较特殊了，因为不像 Linux 可以通过内核引导启动，虽然也可以实现无人应答安装，但是研究的成本高于工作中的实际成本，所以这里只实现了可以通过网络手动安装 Windows 系统。

Windows 系统的安装需要一个 WinPE 的安装环境，先通过网络引导启动 WinPE，然后在 WinPE 环境中安装 Windows 镜像。

##### 下载系统镜像

除了可以在微软官方下载镜像，也可以在国内好心人制作的 [**MSDN I Tell You**](https://msdn.itellyou.cn/) 里下载。

这里使用 `windows_server_2008_R2_standard_enterprise_and_datacenter_x64_dvd_x15-59777.iso` 这个镜像。

##### 配置镜像站

首先需要一个带网络功能的 WinPE，如果不嫌麻烦的话可以百度如何制作 WinPE 镜像，如果采用第三方提供做好的 WinPE 就需要保证镜像是否是干净安全的，而且还需要集成了网卡驱动，如果是用于服务器安装，可能还需要集成 Raid 卡的驱动。

这里使用无垠PE制作的 `Win8PE64网络版.iso` [点此打开网盘分享](https://pan.baidu.com/s/1U0UrufcDA3RMIFkBKucBEQ) 密码：`sees`。其中有一个 `win8pe_x64_raid_network.iso` 的镜像据说是集成了 Raid 卡驱动适用于服务器的 WinPE，实际还并未测试过。

PXE环境对中文的支持能力几乎没有，所以下载后需要将文件名中的中文去掉，然后放到相应目录。然后将 Windows 系统安装镜像解压。

```bash
mkdir -p /data/wwwroot/windows/windows_server_2008_x64
mv Win8PE64网络版.iso /data/wwwroot/windows/win8pe.iso
ln -s /data/wwwroot/windows/ /data/wwwroot/pxefiles/windows
mount -o loop windows_server_2008_R2_standard_enterprise_and_datacenter_x64_dvd_x15-59777.iso /mnt
cp -rf /mnt/* /data/wwwroot/windows/windows_server_2008_x64/
umount /mnt
```

接下来就是另一个比较麻烦的地方了，因为在 WinPE 中通过网络安装 Windows 系统最简单方便的方法就是在 Linux 上创建 Samba 共享，然后 WinPE 中挂载使用。Samba 软件也可以从发行版的官方仓库中获得，或者手动编译安装。

**编译安装 Samba：**

```bash
wget https://download.samba.org/pub/samba/stable/samba-4.8.2.tar.gz
tar xf samba-4.8.2.tar.gz
cd samba-4.8.2
./configure --prefix=/usr/local/samba
make -j4 && make install
```

配置过程中如果出现了什么错误，就根据提示自行解决依赖。接着配置 Samba 共享目录并启动服务。

```bash
vim /usr/local/samba/etc/smb.conf
```
写入如下内容：

    [global]
    workgroup = MYGROUP
    server string = Samba Server
    server role = standalone server
    log file = /dev/stdout
    max log size = 50
    dns proxy = no 
    pam password change = yes
    map to guest = bad user
    usershare allow guests = yes
    create mask = 0664
    force create mode = 0664
    directory mask = 0775
    force directory mode = 0775
    force user = root
    force group = root
    follow symlinks = yes
    load printers = no
    printing = bsd
    printcap name = /dev/null
    disable spoolss = yes
    socket options = TCP_NODELAY
    strict locking = no
    vfs objects = recycle
    recycle:keeptree = yes
    recycle:versions = yes
    min protocol = SMB2

    [public]
    path = /data/wwwroot/windows/
    browsable = yes
    read only = yes
    guest ok = yes
    veto files = /._*/.apdisk/.AppleDouble/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/
    delete veto files = yes

启动 Samba 服务后可以在 Windows 上连接试试

```bash
/usr/local/samba/sbin/smbd -D
```

在 Windows 资源管理器中输入 `\\192.168.4.6` 就可以打开共享的目录了。
![](/uploads/2018/pxe/2w9a7x5g6s92nk48.png)


##### 添加PXE启动项

还记得之前和 pxelinux.0 同一目录的 `memdisk` 文件吧，这通过这个文件可以将 iso 镜像加载到内存中启动，就利用这个方式来启动 WinPE 镜像。

编辑 `pxelinux.cfg/default` 添加如下 `label` 块：

    LABEL Install windows for vmware (WinPE)
        MENU LABEL Install Windows for vmware (WinPE)
        kernel memdisk
        append initrd=/windows/win8pe.iso ksdevice=bootif raw iso


##### 开始安装

选择启动 WinPE
![](/uploads/2018/pxe/7oc9iwmnn6hc5i0w.jpg)

进入 WinPE 桌面环境后连接到服务端的 Samba 共享目录，然后执行 Windows 系统安装镜像中的 `setup.exe`
![](/uploads/2018/pxe/b78i7o7u8y0e231r.jpg)

剩下的步骤就是 Windows 系统的普遍安装方式了。


## 附录

**附件：**[点击下载](/uploads/2018/pxe/pxefiles.tar.xz)
压缩包里包含了所有的配置文件和dnsmasq, pxelinux.0, undionly.kpxe 这些就可以免去编译安装了。

再介绍一个好玩的，通过中科大网络启动服务来安装系统 [点此访问](https://lug.ustc.edu.cn/wiki/server/pxe/start?bootswatch-theme=cosmo)
