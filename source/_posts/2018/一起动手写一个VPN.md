---
title: 一起动手写一个VPN
date: 2018-05-24 23:21:00
categories: 
    - Python
tags:
    - vpn
    - udp
    - python
photos:
    - /uploads/photos/7a09d50b4.jpg
---


## 简介
> 了解了OpenVPN之后，发现通过一个UDP隧道来打通NAT网络非常有意思，于是就萌发出使用Python来实现一个类似于OpenVPN的隧道，OpenVPN不仅支持UDP协议还支持TCP协议，但是这里并不会像OpenVPN设计的这么复杂完善，只使用简单的UDP协议和密码认证。也通过这个小程序来更深入的学习下Linux网络相关的知识。

<!-- more -->


## 环境

VPN隧道的实现依赖于Linux内核提供的 `tun/tap` 虚拟网络接口，只要不是太古董级别的Linux系统，或者其他类Unix系统就都可以支持。可以查看是否存在设备文件 `/dev/net/tun`，如果存在则表示支持 `tun/tap` 功能，对于早些的Linux内核，设备文件还可能是 `/dev/tun`。

其中 `tun` 是模拟的三层网络设备，只支持三层以上的协议，只能做到点对点隧道，而 `tap` 则可以模拟二层网络设备，`arp` 协议等二层协议也是支持的，可以实现多机组成的虚拟局域网。`tun` 也可以通过数据转发的方式实现互通。

服务端代码为了更高的性能和不依赖第三方库使用Python3完成，客户端就尽量兼容更多版本的Python。网络使用常用的 `tun` 虚拟网卡。

## 编程

先来理解一下使用 `tun` 的VPN是如何实现的呢？简单来说 就是 `/dev/net/tun` 设备实现了应用层直接处理网络数据包的能力。当使用 `/dev/net/tun` 创建了虚拟网卡设备后，发到这个网卡的数据包会被 `/dev/net/tun` 拦截并返回给打开它上上层程序，上层程序可以通过 `udp`、`tcp` 甚至 `icmp` 协议将原始的数据包发送到目标主机。当目标主机通过网络接受到数据包后再写入到 `/dev/net/tun` 设备中，`/dev/net/tun` 再将数据包注入到内核的网络协议栈按照正常到达的数据包来处理。VPN大部分采用的是通过 `udp` 协议发送到对端的，如果是通过 `tcp` 协议传输，`tcp` 包内部包裹着另一个 `tcp` 包，如果发生了丢包重传现象，内部的 `tcp` 包和外部的 `tcp` 包可能发生混乱。

### 服务端程序
> 服务端程序使用 Python3 开发，只使用了标准库

#### 导入需要的模块

```python
import os
import sys
import time
import struct
import socket
from fcntl import ioctl
from select import select
from threading import Thread
from ipaddress import ip_network
```

可能大多数人都熟悉 `os`, `sys`, `time` 这些模块，而对其他的就不太了解了。其中 `struct` 是一个将Python的数据类型转换为C语言中的数据类型的字节流的模块。`fnctl.ioctl` 用来对设备的一些特性进行控制，比如这里来设定要启用的虚拟网卡的类型和网卡名称。`select` 是 `I/O多路复用` 的一个实现，用来在单线程中高效的利用网络I/O。`ipaddress` 模块是Python3新增的模块，用来解析IP地址的。

#### 定义一些常量

```python
DEBUG = True
PASSWORD = b'4fb88ca224e'

BIND_ADDRESS = '0.0.0.0',2003
NETWORK = '10.0.0.0/24'
BUFFER_SIZE = 4096
MTU = 1400

IPRANGE = list(map(str,ip_network(NETWORK)))[1:]
LOCAL_IP = IPRANGE.pop(0)

TUNSETIFF = 0x400454ca
IFF_TUN   = 0x0001
IFF_TAP   = 0x0002
```

在这里定义了一些常量，比如认证的密码，服务监听的地址，以及整个网络段。其中不太好理解的可能是 `TUNSETIFF`, `IFF_TUN` 和 `IFF_TAP` 这三个常量。这三个常量实际上是定义在 `linux/if_tun.h` 这个头文件中，因为用Python来实现 `tun` 隧道 所以也需要使用这三个常量。`TUNSETIFF` 这个常量是告诉 `ioctl` 要完成虚拟网卡的注册，而`IFF_TUN` 和 `IFF_TAP` 则表示是要使用 `tun` 类型还是 `tap` 类型的虚拟网卡。

#### 创建和启动虚拟网卡

```python
def createTunnel(tunName='tun%d',tunMode=IFF_TUN):
    tunfd = os.open("/dev/net/tun", os.O_RDWR)
    ifn = ioctl(tunfd, TUNSETIFF, struct.pack(b"16sH", tunName.encode(), tunMode))
    tunName = ifn[:16].decode().strip("\x00")
    return tunfd,tunName
    
def startTunnel(tunName,peerIP):
    os.popen('ifconfig %s %s dstaddr %s mtu %s up' % 
                (tunName, LOCAL_IP, peerIP, MTU)).read()
    
now = lambda :time.strftime('[%Y/%m/%d %H:%M:%S] ')
```

先看 `createTunnel` 函数，默认是使用 `tun` 类型的虚拟网卡，`os.open` 是更底层的文件读写方式，事实上，常用的 `open('filename')` 方法就是对 `os.open` 的高级封装，`os.O_RDWR` 标志以读写模式打开 `tun` 的设备文件。然后使用 `ioctl` 来创建一个虚拟网卡，并返回创建成功后的网卡名称，默认是按照 `tun0`，`tun1` 依次增加的。

`startTunnel` 就是用 `ifconfig` 命令为这个虚拟网卡配置IP地址。`MTU` 之所以设置为 1400 因为Linux默认网卡的 `MTU` 是 1500，但是隧道来的数据包还要包裹一层 `udp` 封装发往对端，如果隧道的 `MTU` 也设置为 1500 的话，那最终通过 `udp` 封装后肯定会超出物理网卡的界限，最终会被拆分为两个数据包发送二照成不必要的浪费。 `now` 是一个 `lambda` 表达式，给下面的打印调试信息使用。

#### VPN的核心实现

```python
class Server():
    def __init__(self):
        self.sessions = []
        self.readables = []
        self.udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.udp.bind(BIND_ADDRESS)
        self.readables.append(self.udp)
        self.tunInfo = {
            'tunName':None, 'tunfd':None, 
            'addr':None, 'tunAddr':None, 'lastTime':None
            }
        print('Server listen on %s:%s...' % BIND_ADDRESS)

    def getTunByAddr(self, addr):
        for i in self.sessions:
            if i['addr'] == addr: return i['tunfd']
        return -1
    
    def getAddrByTun(self,tunfd):
        for i in self.sessions:
            if i['tunfd'] == tunfd: return i['addr']
        return -1

    def createSession(self, addr):
        tunfd,tunName = createTunnel()
        tunAddr = IPRANGE.pop(0)
        startTunnel(tunName,tunAddr)
        self.sessions.append(
            {
                'tunName':tunName, 'tunfd':tunfd, 'addr':addr, 
                'tunAddr':tunAddr, 'lastTime':time.time()
            }
        )
        self.readables.append(tunfd)
        reply = '%s;%s' % (tunAddr,LOCAL_IP)
        self.udp.sendto(reply.encode(), addr)

    def delSessionByTun(self, tunfd):
        if tunfd == -1: return False
        for i in self.sessions:
            if i['tunfd'] == tunfd:
                self.sessions.remove(i)
                IPRANGE.append(i['tunAddr'])
        self.readables.remove(tunfd)
        os.close(tunfd)
        return True

    def updateLastTime(self, tunfd):
        for i in self.sessions:
            if i['tunfd'] == tunfd:
                i['lastTime'] = time.time()

    def cleanExpireTun(self):
        while True:
            for i in self.sessions:
                if (time.time() - i['lastTime']) > 60:
                    self.delSessionByTun(i['tunfd'])
                    if DEBUG: print('Session: %s:%s expired!' % i['addr'])
            time.sleep(1)

    def auth(self,addr,data,tunfd):
        if data == b'\x00':
            if tunfd == -1:
                self.udp.sendto(b'r', addr)
            else:
                self.updateLastTime(tunfd)
            return False
        if data == b'e':
            if self.delSessionByTun(tunfd):
                if DEBUG: print("Client %s:%s is disconnect" % addr)
            return False
        if data == PASSWORD:
            return True
        else:
            if DEBUG: print('Clinet %s:%s connect failed' % addr)
            return False

    def run_forever(self):
        cleanThread = Thread(target=self.cleanExpireTun)
        cleanThread.setDaemon(True)
        cleanThread.start()
        while True:
            readab = select(self.readables, [], [], 1)[0]
            for r in readab:
                if r == self.udp:
                    data, addr = self.udp.recvfrom(BUFFER_SIZE)
                    if DEBUG: print(now()+'from    (%s:%s)' % addr, data[:10])
                    try:
                        tunfd = self.getTunByAddr(addr)
                        try:
                            os.write(tunfd,data)
                        except OSError:
                            if not self.auth(addr,data,tunfd):continue
                            self.createSession(addr)
                            if DEBUG: print('Clinet %s:%s connect successful' % addr)
                    except OSError: continue
                else:
                    try:
                        addr = self.getAddrByTun(r)
                        data = os.read(r, BUFFER_SIZE)
                        self.udp.sendto(data,addr)
                        if DEBUG: print(now()+'to      (%s:%s)' % addr, data[:10])
                    except Exception:
                        continue
```

一步一步的来看，首先定义了一个 `Server` 的类。在初始化方法 `__init__` 中，`self.sessions = []` 用来保存连接的用户会话，`self.readables = []` 用来保存为每个会话创建的隧道的文件描述符，接着创建了一个 `udp` 的网络套接字，并将这个套接字加入到 `self.readables` 中。`self.tunInfo` 定义了每个会话保存的隧道信息。

接下来的 `getTunByAddr` 是通过接受到的 `udp` 数据包的来源信息找到需要注入到哪条隧道中，`getAddrByTun` 正好相反，根据从隧道来的数据找到是要通过 `udp` 发往哪个主机。

`createSession` 则是客户端连接成功后为它创建一个会话和相应的虚拟网卡，并且将客户端的网卡配置信息通过 `udp` 发送过去。 `delSessionByTun` 是用来清理用户会话和虚拟网卡。

`updateLastTime` 用来在客户端发送来心跳包后更新用户最后一次发送心跳包的时间戳，`cleanExpireTun` 用来清理已经超过一分钟没有发来心跳包的客户端，认为这个客户端已经失去了连接，但是可能因为网络故障等原因没有正常关闭隧道。

`auth` 则是对客户端发来的数据进行处理，如何客户端发来 `b'\x00'` 则表明这是一个心跳包，但是如果并不存在这个心跳包源主机的会话，可能因为网络原因服务端清理了这个客户端的会话，就发送 `b'r'` 告诉客户端重新认证。否则就更新这个会话的最后心跳包的时间戳。客户端在退出的时候会发送 `b'e'` 到服务端，然后服务端会主动清理这个客户端的会话。最后会匹配数据包是否是认证密码，如果认证成功了就返回 `True` 程序会继续处理。

`run_forever` 是整个服务运转的核心了，首先使用一个新线程启动会话清理方法，然后进入事件循环，使用 `select` 监听 `udp` 网络套接字和隧道套接字的可读事件，一旦某个套接字有数据过来了 `select` 则会返回这个套接字对象，然后判断这个套接字是网络套接字还是隧道套接字，如果是网络套接字则首先尝试将数据写入到客户端所在的隧道中，如果数据内容不是一个正确的网络数据包格式或者没有找到这个客户端地址相关联的隧道，就进入异常处理模式，因为新客户端的连接和心跳包导致进入异常处理的频率是比较小的 所以并不会对整体性能照成很大的影响，如果在一开始就进行数据内容判断的话 就非常影响程序的性能了，因为毕竟接收到的大多都是合法的能写入到隧道的数据包。

接着如果可读对象是一个隧道文件描述符的话，就找到客户端的网络地址，通过 `udp` 将读取到的数据包发送给客户端，并且如果出现了任何异常的话 就跳过。

#### 程序执行入口

```python
if __name__ == '__main__':
    try:
        Server().run_forever()
    except KeyboardInterrupt:
        print('Closing vpn server ...')
```

创建一个匿名对象并且启动 `run_forever` 方法。

### 客户端程序
> 客户端就比较简单了，只需要将网络来的数据写入隧道，隧道来的数据通过网络发送出去

#### 导入需要的模块

```python
from __future__ import print_function
from __future__ import unicode_literals

import os
import sys
import time
import struct
import socket
from fcntl import ioctl
from select import select
from threading import Thread
```

因为需要尽可能的支持更多的Python版本，所以需要使用一些兼容性相关的小技巧。

#### 定义一些常量 

```python
PASSWORD = b'4fb88ca224e'

MTU = 1400
BUFFER_SIZE = 4096
KEEPALIVE = 10

TUNSETIFF = 0x400454ca
IFF_TUN   = 0x0001
IFF_TAP   = 0x0002
```

同服务端，客户端也需要配置隧道，客户端多了一个 `KEEPALIVE` 的常量，用来定义多久向服务端发送心跳包。

#### 创建和启动虚拟网卡

```python
def createTunnel(tunName='tun%d',tunMode=IFF_TUN):
    tunfd = os.open("/dev/net/tun", os.O_RDWR)
    ifn = ioctl(tunfd, TUNSETIFF, struct.pack(b"16sH", tunName.encode(), tunMode))
    tunName = ifn[:16].decode().strip("\x00")
    return tunfd,tunName
    
def startTunnel(tunName, localIP, peerIP):
    os.popen('ifconfig %s %s dstaddr %s mtu %s up' % 
            (tunName, localIP, peerIP, MTU)).read()
```

`startTunnel` 有个不同的地方是还需要知道对端（服务端）的隧道IP。

#### VPN的核心实现

```python
class Client():
    def __init__(self):
        self.udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.udp.settimeout(5)
        self.to = SERVER_ADDRESS

    def keepalive(self):
        def _keepalive(udp, to):
            while True:
                time.sleep(KEEPALIVE)
                udp.sendto(b'\x00', to)
        k = Thread(target=_keepalive, args=(self.udp, self.to), name='keepalive')
        k.setDaemon(True)
        k.start()

    def login(self):
        self.udp.sendto(PASSWORD,self.to)
        try:
            data,addr = self.udp.recvfrom(BUFFER_SIZE)
            tunfd,tunName = createTunnel()
            localIP,peerIP = data.decode().split(';')
            print('Local ip: %s\tPeer ip: %s' % (localIP,peerIP))
            startTunnel(tunName,localIP,peerIP)
            return tunfd
        except socket.timeout:
            return False

    def run_forever(self):
        print('Start connect to server...')
        tunfd = self.login()
        if not tunfd:
            print("Connect failed!")
            sys.exit(0)
        print('Connect to server successful')
        self.keepalive()
        readables = [self.udp, tunfd]
        while True:
            try:
                readab = select(readables, [], [], 10)[0]
            except KeyboardInterrupt:
                self.udp.sendto(b'e', self.to)
                raise KeyboardInterrupt
            for r in readab:
                if r == self.udp:
                    data, addr = self.udp.recvfrom(BUFFER_SIZE)
                    try:
                        os.write(tunfd, data)
                    except OSError:
                        if data == b'r':
                            os.close(tunfd)
                            readables.remove(tunfd)
                            print('Reconnecting...')
                            tunfd = self.login()
                            readables.append(tunfd)
                        continue
                else:
                    data = os.read(tunfd, BUFFER_SIZE)
                    self.udp.sendto(data, self.to)
```

和服务端的比较类似，不同的是客户端需要处理的是登陆、从服务端接收到隧道配置信息然后创建和启动隧道和处理服务端发来的 `b'r'` 重连命令。还会启动一个定期发送心跳包的线程，这个主要是因为在传统的 NAT 模型中，UDP会话可能在短短的几分钟甚至几十秒钟就会被网关设备清理掉，导致VPN隧道断开。而不断地发送心跳包则可以保持网关设备上客户端和服务端的UDP会话。

#### 程序执行入口
```python
if __name__ == '__main__':
    try:
        SERVER_ADDRESS = (sys.argv[1], int(sys.argv[2]))
        Client().run_forever()
    except IndexError:
        print('Usage: %s [remote_ip] [remote_port]' % sys.argv[0])
    except KeyboardInterrupt:
        print('Closing vpn client ...')
```

这里通过命令行获取客户端要连接的服务端IP和端口，如果参数出错并给出相应的提示信息。

### 运行结果

在服务端使用Python3运行服务端程序：

    root@ubuntu:~# python3 vpnserver.py 
    Server listen on 0.0.0.0:2003...

服务正常监听，然后客户端启动客户端程序：

    [root@localhost ~]# python vpnclient.py 192.168.4.233 2003
    Start connect to server...
    Local ip: 10.0.0.2	Peer ip: 10.0.0.1
    Connect to server successful

    [root@localhost ~]# ifconfig tun0
    tun0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
            inet addr:10.0.0.2  P-t-P:10.0.0.1  Mask:255.255.255.255
            UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1400  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:500 
            RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)


客户端连接成功后打印出连接信息，并且可以看到多出来一块 `tun0` 的虚拟网卡。


    root@ubuntu:~# python3 vpnserver.py 
    Server listen on 0.0.0.0:2003...
    [2018/05/26 13:47:13] from    (192.168.4.6:58502) b'4fb88ca224'
    Clinet 192.168.4.6:58502 connect successful
    [2018/05/26 13:47:23] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:47:33] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:47:43] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:47:53] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:48:03] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:48:13] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:48:23] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:48:33] from    (192.168.4.6:58502) b'\x00'
    [2018/05/26 13:48:43] from    (192.168.4.6:58502) b'\x00'

    root@ubuntu:~# ifconfig tun0
    tun0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
            inet addr:10.0.0.1  P-t-P:10.0.0.2  Mask:255.255.255.255
            UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1400  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:500 
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


可以看到服务端也打印出客户端连接成功的消息，以及打印出每次从客户端发来的数据包信息。同样也有一条到客户端的虚拟网卡。接着尝试服务端是否可以直接PING通客户端了。

    root@ubuntu:~# ping 10.0.0.2 -c 2 
    PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
    64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=0.814 ms
    64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=0.569 ms

    --- 10.0.0.2 ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 999ms
    rtt min/avg/max/mdev = 0.569/0.691/0.814/0.125 ms

    [2018/05/26 13:51:40] to      (192.168.4.6:58502) b'\x00\x00\x08\x00E\x00\x00T\x19\xdd'
    [2018/05/26 13:51:40] from    (192.168.4.6:58502) b'\x00\x00\x08\x00E\x00\x00T\x99V'
    [2018/05/26 13:51:41] to      (192.168.4.6:58502) b'\x00\x00\x08\x00E\x00\x00T\x19\xe4'
    [2018/05/26 13:51:41] from    (192.168.4.6:58502) b'\x00\x00\x08\x00E\x00\x00T\x99W'

可以看到隧道是正常的，并且服务端打印出了去的两个ICMP包和回来的两个ICMP包，接着关闭客户端程序。

    [2018/05/26 13:54:45] from    (192.168.4.6:58502) b'e'
    Client 192.168.4.6:58502 is disconnect

服务端接收到了 `b'e'` 后打印客户端断开连接的消息，接着发现 `tun0` 这块虚拟网卡也消失了。

## 附录

服务端程序就完成了，但是还是存在非常多的问题，比如用户认证的安全性，`select` 的性能和支持的最大客户端数量可以使用更好的 `epoll` 方式，但是 `select` 的平台兼容性比较强，如果考虑把程序移植到 Windows 的话可以继续使用（不考虑移植到Windows，但是Windows的tap驱动软件是否提供了这种可能？）。客户端断开后重连IP就会改变，如果能给客户端固定IP就好了，以及没法监控每个客户端的流量和控制客户端的速率。服务端应该采用配置文件的方式来更改运行的参数，并且应该能够使用守护进程的方式运行并处理 `kill` 命令发送的信号，这样这个程序就比较完善了。

注意：程序中多次出现的 `b'e'`, `b'r'` 这样的字符，这只是表示Python中 `Byte` 类型的数据。