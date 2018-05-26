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

VPN隧道的实现依赖于Linux内核提供的 `tun/tap` 虚拟网络接口，只要不是太古董级别的Linux系统，或者其他类Unix系统就都可以支持。可以查看是否存在设备文件 `/dev/net/tun`，如果存在则表示支持 `tun/tap` 功能，对于更早的Linux内核，设备文件还可能是 `/dev/tun`。

其中 `tun` 是模拟的三层网络设备，只支持三层以上的协议，只能做到点对点隧道，而 `tap` 则可以模拟二层网络设备，`arp` 协议等二层协议也是支持的，可以实现多机组成的虚拟局域网。`tun` 也可以通过数据转发的方式实现互通。

服务端代码为了更高的性能和不依赖第三方库使用Python3完成，客户端就尽量兼容更多版本的Python。

## 编程



## 附录