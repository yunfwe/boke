---
title: WebSocket协议分析
date: 2018-06-22 20:12:00
categories: 
    - WebSocket
tags:
    - websocket
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
---

## 简介
> WebSocket协议是基于TCP的一种新的网络协议。它实现了浏览器与服务器全双工(full-duplex)通信——允许服务器主动发送信息给客户端。它弥补了 HTTP 协议只能只能由客户端，而无法实现服务器主动推送消息。在此之前，浏览器想了解服务端有没有更新数据只能每隔一段时间就发送一个HTTP请求去询问，这样的效率是非常低下的。而通过 WebSocket，服务器和客户端可以建立一条稳定的连接，并且可以双向通信。

## 协议分析

WebSocket 协议的规范可以翻阅 [RFC 6455](https://tools.ietf.org/html/rfc6455)

WebSocket协议有两部分：握手和数据传输。由客户端主动发送连接请求，握手信息是标准的HTTP协议，并通过 `Upgrade` 字段来表示升级为 `WebSocket` 协议，因此 WebSocket 的请求也很容易的可以穿过HTTP代理等服务。

### 握手阶段

客户端发起的握手请求：

    GET /chat HTTP/1.1
    Host: server.example.com
    Upgrade: WebSocket
    Connection: Upgrade
    Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
    Origin: http://example.com
    Sec-WebSocket-Protocol: chat, superchat
    Sec-WebSocket-Version: 13

来自服务端的响应：

    HTTP/1.1 101 Switching Protocols
    Upgrade: WebSocket
    Connection: Upgrade
    Sec-WebSocket-Accept:s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
    Sec-WebSocket-Protocol: chat

接下来看各字段具体作用

+ `Upgrade: WebSocket`：这是一个特殊的HTTP请求，目的是将客户端和服务端的通信协议从HTTP协议升级到 WebSocket 协议。
+ `Sec-WebSocket-Key`：这是一段Base64加密的密钥。
+ `Sec-WebSocket-Accept`：服务端收到客户端发来的密钥后追加一段魔法字符串，并将结果进行SHA-1散列签名后再经过Base64加密返回客户端。
+ `Sec-WebSocket-Protocol`：表示客户端提供的可供选择的自协议，及服务端选中的支持的子协议。
+ `Origin`：服务器端用于区分未授权的 websocket 浏览器。
+ `HTTP/1.1 101 Switching Protocols`：其中101为服务器返回的状态码，所有非101的状态码都表示握手并未完成。

在对 `Sec-WebSocket-Accept` 的解释中，有一个魔法字符串，这个魔法字符串是 WebSocket 标准中规定的一个常量：`258EAFA5-E914-47DA-95CA-C5AB0DC85B11`。这个常量只是定制标准时随机生成的一个标识符而已。


### 传输阶段

Websocket协议通过序列化的数据帧传输数据。数据封包协议中定义了opcode、payload length、Payload data等字段。其中要求：**客户端向服务器传输的数据帧必须进行掩码处理，服务器若接收到未经过掩码处理的数据帧，则必须主动关闭连接。服务器向客户端传输的数据帧一定不能进行掩码处理，客户端若接收到经过掩码处理的数据帧，则必须主动关闭连接。**

具体数据帧格式如下所示：

    0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
        +-+-+-+-+-------+-+-------------+-------------------------------+
        |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
        |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
        |N|V|V|V|       |S|             |   (if payload len==126/127)   |
        | |1|2|3|       |K|             |                               |
        +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
        |     Extended payload length continued, if payload len == 127  |
        + - - - - - - - - - - - - - - - +-------------------------------+
        |                               |Masking-key, if MASK set to 1  |
        +-------------------------------+-------------------------------+
        | Masking-key (continued)       |          Payload Data         |
        +-------------------------------- - - - - - - - - - - - - - - - +
        :                     Payload Data continued ...                :
        + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
        |                     Payload Data continued ...                |
        +---------------------------------------------------------------+

**FIN：**标识是否为此消息的最后一个数据包，占 1 bit
**RSV1, RSV2, RSV3：** 用于扩展协议，一般为0，各占1bit
**Opcode：**数据包类型（frame type），占4bits
+ `0x0`：标识一个中间数据包
+ `0x1`：标识一个text类型数据包
+ `0x2`：标识一个binary类型数据包
+ `0x3-7`：保留
+ `0x8`：标识一个断开连接类型数据包
+ `0x9`：标识一个ping类型数据包
+ `0xA`：表示一个pong类型数据包
+ `0xB-F`：保留

**MASK：**占1bits 用于标识PayloadData是否经过掩码处理。如果是1，Masking-key域的数据即是掩码密钥，用于解码PayloadData。客户端发出的数据帧需要进行掩码处理，所以此位是1。
**Payload length：**Payload data的长度，占7bits，7+16bits，7+64bits。如果其值在0-125，则是payload的真实长度。如果值是126，则后面2个字节形成的16bits无符号整型数的值是payload的真实长度。注意，网络字节序，需要转换。如果值是127，则后面8个字节形成的64bits无符号整型数的值是payload的真实长度。注意，网络字节序，需要转换。这里的长度表示遵循一个原则，用最少的字节表示长度（尽量减少不必要的传输）。举例说，payload真实长度是124，在0-125之间，必须用前7位表示；不允许长度1是126或127，然后长度2是124，这样违反原则。

**Payload data：**应用层数据

服务端解析客户端的数据规则如下：

客户端发来的数据包的第一位(FIN)几乎一定是1，


## 服务端的简单实现

## 客户端的简单实现

## 附录