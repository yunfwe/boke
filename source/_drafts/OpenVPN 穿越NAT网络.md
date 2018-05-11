---
title: OpenVPN 穿越NAT网络
date: 2018-05-03 10:12:00
categories: 
    - OpenVPN
tags:
    - openvpn
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
---

## 简介
> 想和朋友联机打局域网游戏，在家需要连接到公司办公，如果是机密信息还要保证数据的加密传输，而且还要简单稳定好用，那么OpenVPN绝对是不二之选，OpenVPN是一个基于OpenSSL库的应用层VPN实现，完全开源免费，而且支持的平台众多，Linux平台，Windows平台，Android和IOS平台也都支持。

## 环境

想要连通两个NAT后的网络，比如家里的局域网和公司的局域网就必须存在一个公网IP来做数据中转。这里使用阿里云的一台主机来做数据中转。

系统使用的是 Ubuntu 16.04.03 64位
OpenVPN 使用最新的稳定版 2.3.18 [**点此下载**](https://swupdate.openvpn.org/community/releases/openvpn-2.3.18.tar.xz)

如果下载不了，可能需要自备梯子或者从其他地方下载。如果使用的 CentOS 系列安装可能需要先关闭 SElinux。

## 安装

也可以选择直接从官方仓库中下载安装使用。

### 解决依赖

```bash
apt-get install make gcc g++ libssl-dev liblzo2-dev libpam-dev unzip
```

这里只适用于 Ubuntu 系统

### 编译安装

```bash
tar xf openvpn-2.3.18.tar.xz
cd openvpn-2.3.18
./configure --prefix=/usr/local/openvpn
make -j4 && make install
mkdir /etc/openvpn
cp -rf sample/ /etc/openvpn/    # 拷贝配置文件模块
cp /etc/openvpn/sample/sample-config-files/server.conf /etc/openvpn/
```

由于系统环境的复杂，配置过程中可能会缺少某些库的头文件，只需要找到这些头文件所在的包然后安装下就好了。

### 配置证书

#### 服务端证书

##### 配置easy-rsa

```bash
cd /etc/openvpn
git clone -b release/2.x https://github.com/OpenVPN/easy-rsa.git
cd /etc/openvpn/easy-rsa/easy-rsa/2.0
```

然后编辑 `vars` 文件，修改下列内容的值为随意内容。需要注意的是，值不可以是空的。

    export KEY_COUNTRY="US"
    export KEY_PROVINCE="California"
    export KEY_CITY="SanFrancisco"
    export KEY_ORG="Fort-Funston"
    export KEY_EMAIL="me@myhost.mydomain"
    export KEY_OU="MyOrganizationalUnit"

我这里修改为了如下内容

    export KEY_COUNTRY="CN"
    export KEY_PROVINCE="BeiJing"
    export KEY_CITY="BeiJing"
    export KEY_ORG="wu"
    export KEY_EMAIL="admin@localhost.com"
    export KEY_OU="openvpn"

接着修改 `export KEY_NAME="EasyRSA"` 这句话，将 `EasyRSA` 改为自己喜欢的名字，这里就简单的使用 `server`，修改后就可以保存退出了。

##### 创建根证书

```bash
source vars
./clean-all
./build-ca 
```

这一步一路的回车就好，因为已经在 `vars` 文件中配置过了。

    root@ubuntu:/etc/openvpn/easy-rsa/easy-rsa/2.0# ./build-ca 
    Generating a 2048 bit RSA private key
    ............................................................+++
    ..........................+++
    writing new private key to 'ca.key'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [CN]:
    State or Province Name (full name) [BeiJing]:
    Locality Name (eg, city) [BeiJing]:
    Organization Name (eg, company) [wu]:
    Organizational Unit Name (eg, section) [openvpn]:
    Common Name (eg, your name or your server's hostname) [wu CA]:
    Name [server]:
    Email Address [admin@localhost.com]:

##### 颁发服务端证书
```
./build-key-server server
```
这个 `server` 就是刚才 `export KEY_NAME="EasyRSA"` 中指定的名字。之后就是一路的回车，当遇到两个问答的时候都回答 `y` 就可以了。

    root@ubuntu:/etc/openvpn/easy-rsa/easy-rsa/2.0# ./build-key-server server
    Generating a 2048 bit RSA private key
    .......................+++
    ..............+++
    writing new private key to 'server.key'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [CN]:
    State or Province Name (full name) [BeiJing]:
    Locality Name (eg, city) [BeiJing]:
    Organization Name (eg, company) [wu]:
    Organizational Unit Name (eg, section) [openvpn]:
    Common Name (eg, your name or your server's hostname) [server]:
    Name [server]:
    Email Address [admin@localhost.com]:

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:
    Using configuration from /etc/openvpn/easy-rsa/easy-rsa/2.0/openssl-1.0.0.cnf
    Check that the request matches the signature
    Signature ok
    The Subject's Distinguished Name is as follows
    countryName           :PRINTABLE:'CN'
    stateOrProvinceName   :PRINTABLE:'BeiJing'
    localityName          :PRINTABLE:'BeiJing'
    organizationName      :PRINTABLE:'wu'
    organizationalUnitName:PRINTABLE:'openvpn'
    commonName            :PRINTABLE:'server'
    name                  :PRINTABLE:'server'
    emailAddress          :IA5STRING:'admin@localhost.com'
    Certificate is to be certified until Apr 30 07:50:21 2028 GMT (3650 days)
    Sign the certificate? [y/n]:y


    1 out of 1 certificate requests certified, commit? [y/n]y
    Write out database with 1 new entries
    Data Base Updated

##### 生成Diffie-Hellman文件
> Diffie-Hellman是一种确保共享KEY安全穿越不安全网络的方法

```bash
./build-dh
/usr/local/openvpn/sbin/openvpn --genkey --secret keys/ta.key
```

这一步需要的时间会长一些。

#### 客户端证书

##### 颁发客户端证书

使用 `build-key` 命令可以颁发一个不带密码的证书，如果需要带密码保护的证书，可以使用 `build-key-pass` 命令。这里使用不带密码的凭证，证书名为 `client1`

```bash
./build-key client1
```

同理 一路回车后最后两个问答输入 `y`

    root@ubuntu:/etc/openvpn/easy-rsa/easy-rsa/2.0# ./build-key client1
    Generating a 2048 bit RSA private key
    ....................+++
    ..............................+++
    writing new private key to 'client1.key'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [CN]:
    State or Province Name (full name) [BeiJing]:
    Locality Name (eg, city) [BeiJing]:
    Organization Name (eg, company) [wu]:
    Organizational Unit Name (eg, section) [openvpn]:
    Common Name (eg, your name or your server's hostname) [client1]:
    Name [server]:
    Email Address [admin@localhost.com]:

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:
    Using configuration from /etc/openvpn/easy-rsa/easy-rsa/2.0/openssl-1.0.0.cnf
    Check that the request matches the signature
    Signature ok
    The Subject's Distinguished Name is as follows
    countryName           :PRINTABLE:'CN'
    stateOrProvinceName   :PRINTABLE:'BeiJing'
    localityName          :PRINTABLE:'BeiJing'
    organizationName      :PRINTABLE:'wu'
    organizationalUnitName:PRINTABLE:'openvpn'
    commonName            :PRINTABLE:'client1'
    name                  :PRINTABLE:'server'
    emailAddress          :IA5STRING:'admin@localhost.com'
    Certificate is to be certified until Apr 30 07:58:09 2028 GMT (3650 days)
    Sign the certificate? [y/n]:y


    1 out of 1 certificate requests certified, commit? [y/n]y
    Write out database with 1 new entries
    Data Base Updated

#### 安置证书

现在所有的证书都在 `keys` 目录中，为了方便使用，将 `keys` 目录直接软链到 `/etc/openvpn/` 下 

```bash
ln -s /etc/openvpn/easy-rsa/easy-rsa/2.0/keys/ /etc/openvpn/keys
```

到这里，安装的部分就结束了。

## 使用

### 服务端配置

#### 配置文件

编辑服务端配置文件：`/etc/openvpn/server.conf` 修改内容如下：

    port 2001
    proto udp
    dev tun
    ca keys/ca.crt
    cert keys/server.crt
    key keys/server.key  
    dh keys/dh2048.pem
    server 10.0.0.0 255.255.255.0
    ifconfig-pool-persist ipp.txt
    push "route 10.0.0.0 255.255.255.0"
    client-to-client
    keepalive 10 120
    tls-auth keys/ta.key 0 
    cipher AES-256-CBC
    auth SHA256
    key-direction 0
    user nobody
    group nogroup
    persist-key
    persist-tun
    status openvpn-status.log
    verb 3

需要注意的是，这里使用 udp 的 2001 端口，在阿里云等环境，还需要配置相应的安全组策略来开放这个端口的流量。

#### Linux配置

开启 Linux 的内核转发功能，编辑 `/etc/sysctl.conf` 文件，取消掉 `#net.ipv4.ip_forward=1` 之前的注释。然后执行 `sysctl -p` 命令。

    root@ubuntu:/etc/openvpn# sysctl -p
    net.ipv4.ip_forward = 1
    vm.swappiness = 0
    net.ipv4.neigh.default.gc_stale_time = 120
    net.ipv4.conf.all.rp_filter = 0
    net.ipv4.conf.default.rp_filter = 0
    net.ipv4.conf.default.arp_announce = 2
    net.ipv4.conf.lo.arp_announce = 2
    net.ipv4.conf.all.arp_announce = 2
    net.ipv4.tcp_max_tw_buckets = 5000
    net.ipv4.tcp_syncookies = 1
    net.ipv4.tcp_max_syn_backlog = 1024
    net.ipv4.tcp_synack_retries = 2
    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    net.ipv6.conf.lo.disable_ipv6 = 1

还需要确保 iptable 的 `FORWARD` 链允许数据转发

```bash
iptables -P FORWARD ACCEPT
```

#### 启动OpenVPN

```bash
/usr/local/openvpn/sbin/openvpn --cd /etc/openvpn/ --config /etc/openvpn/server.conf
```
以调试模式启动 OpenVPN，如果启动过程中有什么错误的话会显示在输出里，确定没有问题了，可以添加 `--daemon` 参数在后台运行 OpenVPN

    root@ubuntu:/etc/openvpn# /usr/local/openvpn/sbin/openvpn --cd /etc/openvpn/ --config /etc/openvpn/server.conf 
    Thu May  3 16:32:55 2018 OpenVPN 2.3.18 x86_64-unknown-linux-gnu [SSL (OpenSSL)] [LZO] [EPOLL] [MH] [IPv6] built on May  3 2018
    Thu May  3 16:32:55 2018 library versions: OpenSSL 1.0.2g  1 Mar 2016, LZO 2.08
    Thu May  3 16:32:55 2018 Diffie-Hellman initialized with 2048 bit key
    Thu May  3 16:32:55 2018 Control Channel Authentication: using 'keys/ta.key' as a OpenVPN static key file
    Thu May  3 16:32:55 2018 Outgoing Control Channel Authentication: Using 160 bit message hash 'SHA1' for HMAC authentication
    Thu May  3 16:32:55 2018 Incoming Control Channel Authentication: Using 160 bit message hash 'SHA1' for HMAC authentication
    Thu May  3 16:32:55 2018 Socket Buffers: R=[212992->212992] S=[212992->212992]
    Thu May  3 16:32:55 2018 ROUTE_GATEWAY 172.31.143.253/255.255.240.0 IFACE=eth0 HWADDR=00:16:3e:08:fb:5f
    Thu May  3 16:32:55 2018 TUN/TAP device tun0 opened
    Thu May  3 16:32:55 2018 TUN/TAP TX queue length set to 100
    Thu May  3 16:32:55 2018 do_ifconfig, tt->ipv6=0, tt->did_ifconfig_ipv6_setup=0
    Thu May  3 16:32:55 2018 /sbin/ifconfig tun0 10.0.0.1 pointopoint 10.0.0.2 mtu 1500
    Thu May  3 16:32:55 2018 /sbin/route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.2
    Thu May  3 16:32:55 2018 GID set to nogroup
    Thu May  3 16:32:55 2018 UID set to nobody
    Thu May  3 16:32:55 2018 UDPv4 link local (bound): [undef]
    Thu May  3 16:32:55 2018 UDPv4 link remote: [undef]
    Thu May  3 16:32:55 2018 MULTI: multi_init called, r=256 v=256
    Thu May  3 16:32:55 2018 IFCONFIG POOL: base=10.0.0.4 size=62, ipv6=0
    Thu May  3 16:32:55 2018 IFCONFIG POOL LIST
    Thu May  3 16:32:55 2018 Initialization Sequence Completed

使用 `ifconfig` 命令，应该可以看到多出来了一块 `tun0` 的网卡。

#### 制作客户端ovpn文件

为了方便客户端的连接，可以在服务端制作好客户端的配置文件，只需将文件下发给客户端，就可以直接使用了。这个文件的拓展名是 ovpn 

```
cd /etc/openvpn/
mkdir make_clients
cp sample/sample-config-files/client.conf make_clients/
cd make_clients
```

然后编辑 `client.conf` 为以下内容，其中连接服务器的 IP 需要修改为自己的。

    client
    dev tun
    proto udp
    remote 47.xxx.xxx.155 2001
    resolv-retry infinite
    nobind
    user nobody
    group nogroup
    persist-key
    persist-tun
    remote-cert-tls server
    cipher AES-256-CBC
    auth SHA256
    key-direction 1
    verb 3
    explicit-exit-notify 1

还记得刚才颁发的客户端证书 `client1` 吧，先为这个证书生成一份配置文件。使用一个自动化脚本来完成配置文件的创建。新建 `make_config.sh` 脚本，然后写入如下内容

```bash
#!/bin/bash
# First argument: Client identifier

KEY_DIR=/etc/openvpn/keys
OUTPUT_DIR=./files
BASE_CONFIG=./client.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn
```

开始创建

```bash
chmod +x make_config.sh
mkdir files
./make_config.sh client1
```

这个 `client1` 就是用户证书的名字，也只有存在才可以创建成功。脚本正常执行后可以在 `files` 目录中看到 `client1.ovpn` 文件，这个文件中已经包含了客户端所需要的密钥以及连接信息，所以只需要将这个文件发给用户，然后在客户端上导入就可以直接连接了。不过要注意，基于密钥的认证方式，每个密钥只允许同时一台机器连接使用。

### 客户端连接

首先需要将生成的 ovpn 文件发送给用户的机器上，然后还需要安装适合当前平台的客户端。

#### 在 Linux 上登陆 OpenVPN

Linux上编译出的 `openvpn` 程序既可以是服务端，也可以是客户端，所以只需要再下载下来源码包编译一次就可以了。连接也非常方便，直接使用 `openvpn --config client1.ovpn` 即可。如果想后台运行，也只需要添加 `--daemon` 参数。

当连接成功后，可以看到多出来一块 `tun0` 的网卡

    tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
            inet 10.0.0.6  netmask 255.255.255.255  destination 10.0.0.5
            inet6 fe80::bf9f:2316:1d8c:83d1  prefixlen 64  scopeid 0x20<link>
            unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 100  (UNSPEC)
            RX packets 1  bytes 84 (84.0 B)
            RX errors 0  dropped 0  overruns 0  frame 0
            TX packets 5  bytes 276 (276.0 B)
            TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

服务端IP为 `10.0.0.1`，可以看看能不能PING通

    root@raspberrypi:~# ping 10.0.0.1 -c 4
    PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
    64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=62.2 ms
    64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=61.7 ms
    64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=68.1 ms
    64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=68.1 ms

    --- 10.0.0.1 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3005ms
    rtt min/avg/max/mdev = 61.782/65.097/68.185/3.103 ms

#### 在 Windows 上登陆 OpenVPN

Windows 客户端需要在官方下载，下载时可能需要自备梯子，下载地址：[点此打开](https://openvpn.net/index.php/open-source/downloads.html)

下载安装成功后，第一次打开会弹出一个窗口，说没有可以读取的配置文件，这时候只需右击系统状态栏里OpenVPN的小图标，然后选择 `Import file...` 打开刚才生成的 `client1.ovpn` 就可以了。然后再次右击小图标，点击 `Connect`，等弹出的窗口自动退出口，系统也会通知 OpenVPN 是否连接成功。

在 Windows 上也是可以PING通服务器的

    C:\Users\yunfwe\Desktop>ping 10.0.0.1

    正在 Ping 10.0.0.1 具有 32 字节的数据:
    来自 10.0.0.1 的回复: 字节=32 时间=68ms TTL=64
    来自 10.0.0.1 的回复: 字节=32 时间=71ms TTL=64
    来自 10.0.0.1 的回复: 字节=32 时间=62ms TTL=64
    来自 10.0.0.1 的回复: 字节=32 时间=60ms TTL=64

    10.0.0.1 的 Ping 统计信息:
        数据包: 已发送 = 4，已接收 = 4，丢失 = 0 (0% 丢失)，
    往返行程的估计时间(以毫秒为单位):
        最短 = 60ms，最长 = 71ms，平均 = 65ms

#### 在 Android 上登陆 OpenVPN

在谷歌应用商店里可以找到一款名为 `openvpn-connect` 的apk，使用这个软件也可以通过导入ovpn文件的方式连接到服务器。

## 附录


