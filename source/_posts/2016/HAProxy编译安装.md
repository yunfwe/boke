---
title: HAProxy编译安装
date: 2016-07-18 14:55:05
categories: 
    - HAProxy
tags:
    - 代理服务器
    - 负载均衡
---
## <font color='#5CACEE'>简介</font>
> HAProxy提供高可用性、负载均衡以及基于TCP和HTTP应用的代理，支持虚拟主机，它是免费、快速并且可靠的一种解决方案。HAProxy特别适用于那些负载特大的web站点，这些站点通常又需要会话保持或七层处理。HAProxy运行在当前的硬件上，完全可以支持数以万计的并发连接。并且它的运行模式使得它可以很简单安全的整合进您当前的架构中， 同时可以保护你的web服务器不被暴露到网络上。
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/view/2480120.htm)
<!-- more -->

	
## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|haproxy|1.6.7|[<font color='#AAAAAA'>点击下载</font>](http://www.haproxy.org/download/1.6/src/haproxy-1.6.7.tar.gz)|

## <font color='#5CACEE'>步骤</font>
> 需要系统先初始化开发环境

    yum install -y gcc gcc-c++ zlib-devel make

### <font color='#CDAA7D'>编译安装haproxy</font>

```bash
tar xf haproxy-1.6.7.tar.gz
cd haproxy-1.6.7
make -j4 TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1
make install PREFIX=/usr/local/haproxy
mkdir /etc/haproxy
cp examples/content-sw-sample.cfg /etc/haproxy/haproxy.conf
```
    需要注意的地方是 TARGET=linux2628 这个是根据内核版本来定的 具体如何使用看源码目录下的README文件
    简单来说 只要你的内核版本大于2.6.28的 都可以使用TARGET=linux2628
    
    编译安装是非常简单的 至此haproxy就编译安装完成了 剩下的就是看haproxy如何使用了 

   

## <font color='#5CACEE'>附录</font>
    
### <font color='#CDAA7D'>四层和七层负载均衡的区别</font>

    常见的负载均衡方式 除了硬件负载均衡设备 还有软件的负载均衡产品 比如Nginx, LVS, HAProxy等
    软件的方式又分为基于操作系统的和基于第三方软件的 比如LVS需要内核模块的支持 HAProxy则不需要
    
    HAProxy可以实现TCP(四层)和HTTP(七层)应用的负载均衡 而早期Nginx只支持HTTP应用的负载均衡
    不过Nginx在新版本1.9.0之后 也支持了TCP的代理和负载均衡 在1.9.13后支持了UDP代理和负载均衡
    
    四层负载均衡也被称为四层交换机 主要通过修改数据包中目标IP地址和端口改为后端服务器的IP地址和端口
    然后直接转发给该后端服务器 这样一个负载均衡的请求就完成了 并没有对数据包中的数据内容做修改
    而负载均衡器只不过完成了一个类似路由的转发动作 在某些负载均衡策略下 甚至会修改报文的源地址
    以保证数据包可以正确的传输
    
    而七层负载均衡器又被称为七层交换机 位于应用层 此时负载均衡器可以支持多种应用协议 
    常见的有HTTP, FTP, SMTP等 七层负载均衡器不仅可以根据IP+端口的方式负载均衡 还可以根据内容
    比如一个网站有为手机适配的页面和电脑适配的页面 可以分析HTTP的头部User-Agent信息 来智能跳转
    而这些能力是在四层是无法实现的
    
    
    
    
