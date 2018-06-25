---
title: WebSocket 协议分析
date: 2018-06-22 20:12:00
categories: 
    - WebSocket
tags:
    - websocket
photos:
    - /uploads/photos/asdasdaefaeda.jpg
---

## 简介
> WebSocket协议是基于TCP的一种新的网络协议。它实现了浏览器与服务器全双工(full-duplex)通信——允许服务器主动发送信息给客户端。它弥补了 HTTP 协议只能只能由客户端，而无法实现服务器主动推送消息。在此之前，浏览器想了解服务端有没有更新数据只能每隔一段时间就发送一个HTTP请求去询问，这样的效率是非常低下的。而通过 WebSocket，服务器和客户端可以建立一条稳定的连接，并且可以双向通信。

<!-- more -->

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

00010001

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
**Payload length：**Payload data的长度，占7bits，7+16bits，7+64bits。如果其值在0-125，则是payload的真实长度。如果值是126，则后面2个字节形成的16bits无符号整型数的值是payload的真实长度。如果值是127，则后面8个字节形成的64bits无符号整型数的值是payload的真实长度。
**Masking-key：**如果是客户端发送的数据，长度信息之后的4个字节是掩码，
**Payload data：**应用层数据，客户端发往服务端需要将数据的每一位和掩码的第 N%4 位进行异或运算。

而服务端返回的数据则不需要掩码和加密数据。


## 实现服务端

接下来使用 Python3 来实现一个简单的 WebSocket 回声服务器，并每个比特的分析 WebSocket 协议的头部。

### 编写代码

```python
import struct
import socket
import base64
import hashlib

HOST = '0.0.0.0'
PORT = 2000
MAGIC_STRING = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

HTTP_RESPONSE = (
    'HTTP/1.1 101 Switching Protocols\r\n'
    "Upgrade: websocket\r\n"
    "Connection: Upgrade\r\n"
    "Sec-WebSocket-Accept: {KEY}\r\n"
    "WebSocket-Location: ws://{HOST}/echo\r\n\r\n"
)
```

这里定义监听在 TCP 2000 端口，还有 WebSocket 标准定义的魔法字符串，以及通过 HTTP 协议建立 WebSocket 连接的响应模板字符串。

```python
def handshake(conn):
    headers = {}
    raw_headers = conn.recv(4096)
    if not len(raw_headers): return False
    header, data = raw_headers.split(b'\r\n\r\n', 1)
    for line in header.split(b'\r\n')[1:]:
        key, val = line.split(b': ', 1)
        headers[key] = val
    try:
        sec_key = headers[b'Sec-WebSocket-Key']
    except: return False
    res_key = base64.b64encode(hashlib.sha1(sec_key + MAGIC_STRING.encode()).digest())
    http_response = HTTP_RESPONSE.format(KEY=res_key.decode(), HOST=HOST)
    conn.send(http_response.encode())
    return True
```
解析客户端发来的 WebSocket 握手请求，请求头中的 `Sec-WebSocket-Key` 和魔法字符串拼接后的SHA1的值经过Base64编码返回客户端，这一步握手就成功了，接下来的数据传输就是通过 WebSocket 协议进行了。

```python
def parseData(package):
    fin = package[0] >> 7              # 第一个字节(8 bit)右移7位获得FIN的比特位。
    opcode = package[0] & 0b1111       # 与运算获取最后四个比特位(opcode)的值
    mask_flag = package[1] >> 7        # 客户端必须将MASK设置为1（必须将数据进行掩码处理）
    data_length = package[1] & 0b1111111   # 计算数据长度
    if data_length == 126:             # 如果数据长度126，则之后的2个字节也是长度信息
        masks = package[4:8]           # 所以掩码值就在第 4,5,6,7 这四个字节
        raw_data = package[8:]         # 实际的数据所在字节
    elif data_length == 127:           # 如果数据长度127，则之后的8个字节也是长度信息
        masks = package[10:14]         # 所以掩码值就在第 10,11,12,13 这四个字节
        raw_data = package[14:]
    else:
        masks = package[2:6]           # 如果长度在0-125，则 2,3,4,5 就是掩码的值
        raw_data = package[6:]
    data = b""
    i = 0
    for B in raw_data:
        tmp = B ^ masks[i % 4]         # 将数据的每个字节与掩码进行异或运算
        data += struct.pack('B', tmp)  # 然后将值打包为二进制
        i += 1
    return data
```
解析接收到的 WebSocket 数据帧，并返回解密后的数据部分。

```python
def packData(data):
    finAndOpcode = struct.pack('B', 0b10000001)
    maskAndLength = struct.pack('B', len(data))
    return finAndOpcode+maskAndLength+data

```
构建服务端返回客户端的数据帧，因为不需要对数据按字节异或加密，所以代码比较简单。

```python
def startServer():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((HOST, PORT))
    sock.listen(5)
    print('Server listen on %s:%s ...' % (HOST,PORT))
    while True:
        conn, addr = sock.accept()
        if not handshake(conn): 
            print("Client %s:%s handshake failed!" % addr)
        print("Client %s:%s handshake success!" % addr)
        data = conn.recv(4096)
        print('Raw data: ', data, sep='')
        print('Fact data: '+parseData(data).decode())
        conn.send(packData(parseData(data)))
        conn.close()

if __name__ == '__main__':
    try:
        startServer()
    except KeyboardInterrupt:
        print("Server exit...")
```

创建套接字监听，并启动服务，当有客户端握手成功后，将客户端发来的数据原样返回并关闭连接。运行脚本，然后看看效果吧！

### 浏览器测试

这里在 Chrome 浏览器中做演示，`F12` 进入开发者模式，然后点击 `Console`，现在就打开 JavaScript 的交互界面了。然后输入如下代码：

```javascript
var ws = new WebSocket("ws://127.0.0.1:2000/echo")
ws.onmessage = data => {console.log("Recv: "+data.data)}
ws.send("Hi! 喵喵喵")
```

可以看到，发送给服务端的字符串又被原样返回了。

![](/uploads/2018/websocket/20180624225605.png)

服务端也可以看到终端上的输出：

    yunfwe@zhzz:/mnt/c/Users/yunfwe/Desktop$ python3 server.py
    Server listen on 0.0.0.0:2000 ...
    Client 127.0.0.1:53117 handshake success!
    Raw data: b'\x81\x8d7\x91\xc6\x8b\x7f\xf8\xe7\xab\xd2\x07sn\xa1$#\x1d\x82'
    Fact data: Hi! 喵喵喵

## 附录

客户端一般都是浏览器等程序，如果感兴趣的话也可以试试用 Python 实现一个简单的 WebSocket 客户端。