---
title: Python爬虫入门
date: 2016-07-25 15:11:41
categories: 
    - Python
tags:
    - 网络爬虫
    - Python
---
## <font color='#5CACEE'>简介</font>
> 网络爬虫是一个自动提取网页的程序，它为搜索引擎从万维网上下载网页，是搜索引擎的重要组成。比如百度 google等搜索引擎通过程序爬取你的个人网站，然后建立索引 这样别人就可以通过搜索关键字找到你的网站了。爬虫的意义不仅如此 还可以做更多好玩的事情。

<!-- more -->


## <font color='#5CACEE'>步骤</font>
> 用Python写网络爬虫是非常简单的 大致需要学习以下知识点

+ 了解HTTP协议 以及HTML标签等
+ 掌握Python的基本语法
+ 学习Python的urllib, urllib2等模块
+ 学习正则表达式 或者XPath
+ 使用Python爬虫框架帮助开发

## <font color='#5CACEE'>学习</font>
网络爬虫 也有人称之为网络蜘蛛 互联网是一张大网 每个人都可以在上面搭建网站 平常我们用的百度搜索的所有内容 都是百度曾经访问过的内容 然后保存下来 建立了索引 这样才能供用户查询 能快速的找到自己想要的资源 而百度去访问这些网站资源 肯定不可能人工手动去访问然后记录 背后都是一个一个的程序去抓取网页 然后根据这个网页继续往下抓取 直到收集到需要的信息 就像一个爬虫或蜘蛛 在这张大网上爬来爬去一样 来自互联网的流量 有不小的一部分并不是人为访问的 而是各大搜索引擎的爬虫程序 

可以写爬虫的语言非常多 但是因为python的简单 方便 越来越多的人使用python来写爬虫 也出现了各种优秀的爬虫框架 下面将由浅入深 一步一步的学习 如和使用python来写一个爬虫

### <font color='#CDAA7D'>了解HTTP协议</font>
> HTTP 全称 HyperText Transfer Protocol(超文本传输协议)，设计之初就是为了提供一种收发HTML页面的方法 下面详细看看一个URL是如何组成的

#### <font color='#DDA0DD'>URL的含义</font>
> URL是URI的子集 关于URI的相关内容 这里不再解释 具体可以问度娘。URL 全称Universal Resource Identifier(统一资源定位符) 结构组成如下

    比如我们看这样一个URL 
    http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz
    
    http://部分是协议部分还有类似的https, ftp, mailto, file等 作用是让程序知道如和处理要打开的资源
    dev.mysql.com 部分是主机名或者IP 还可以加端口号 用:隔开 比如dev.mysql.com:8080 默认的端口是80
    /get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz 就是服务器上的文件资源基于web根目录的绝对路径了

#### <font color='#DDA0DD'>一次完整的HTTP请求</font>
+ 浏览器输入URL 比如 http://www.baidu.com/
+ 向DNS服务器查询www.baidu.com的IP地址 然后连接这个IP地址的80端口 
+ 如果成功连接到了80端口 浏览器发起http请求(Request) 通过GET方法 访问服务器的/
+ 服务器收到请求 如果是静态资源 比如图片之类的 读取文件后相应(Response)给客户端
+ 如果请求的是.jsp或者.php等脚本 将由相应的后端程序处理 然后将生成的html页面返回给客户端
+ 一次请求完成 服务端主动关闭连接 客户端解析获取的html页面 然后继续发起其他资源的请求
+ 如果请求失败 服务器会有一个返回码 正常状态的返回码都是200 比如还有较为常见的404等

#### <font color='#DDA0DD'>HTTP协议</font>
> HTTP协议的重点就在客户机发送的Request 和服务端返回的Response上 他们是按照怎样的格式发送的呢

**Request：**

    GET /login.html HTTP/1.1
    Host: www.abc.com
    Connection: keep-alive
    Referer: www.abc.com
    User-Agent: Python-urllib/2.7
    
    GET 是HTTP方法 常用的还有POST方法 通过GET方法传递的参数直接编码为URL的一部分 
    比如/login.html?user=username&passwd=password 请求login.html的同时传递了user和passwd两个参数
    而POST方法则不会 所以POST适合于密码传输 而且POST传递的数据没有大小限制 适合传递较大的文件
    
    Referer字段标识这个请求时从哪个链接上发起的 服务端可以通过此字段设置防盗链 也是爬虫需要注意的
    User-Agent字段是客户机标识自己的身份 有时候服务端会限制一些User-Agent的访问 但是爬虫可以伪装


**Response：**

    HTTP/1.1 200 OK
    Date: Mon, 25 Jul 2016 12:59:31 GMT
    Content-Length: 10901
    Content-Type: text/html
    
    200的返回的状态码 OK是简单的描述 常见的400以上的错误为客户端请求的错误 500以上为服务端错误
    Content-Length字段告诉客户端响应内容主体的大小
    Content-Type字段告诉客户端返回内容的类型 比如图片的就是image/png 还有非常多的类型
    
    Request和Response的还有非常多的字段 暂时先简单了解下即可 下面开始进入正题


### <font color='#CDAA7D'>urllib库的基本使用</font>
> 用爬虫挖掘数据的三个步骤: **获取网页数据** -\-> **从数据中检索需要的数据** -\-> **将数据保存入库**
先来研究爬虫的第一步 获取网页数据。python获取网页数据的标准库有urllib2 还有一些非常好用的第三方库 比如requests库 python的urllib库有两个 一个是urllib 另一个是urllib2 这两个库并不是可以互相替代的关系 反而是互补的关系 下面看一个最简单的爬虫

#### <font color='#DDA0DD'>第一个简单的爬虫</font>

```python
import urllib2
response = urllib2.urlopen("http://www.baidu.com/")
print response.code
print response.read()
```

    200
    <!DOCTYPE html><!--STATUS OK--><html><head><meta http-equiv="content-type" ......
    
    urllib2.urlopen类可以发起一个request的请求 用它打开链接就相当于浏览器请求一样
    response.code是响应的状态码 response.read()则读取了访问baidu后获取的网页源代码
    下面看看urlopen()类的常用参数
    
```
urllib2.urlopen(url, data=None, timeout=socket)
```

    url参数 顾名思义 就是要访问的地址 这个参数还可以是一个urllib2.Request的对象 下面会讲到
    默认urlopen使用了GET方法 如果给urlopen提供了data参数 则urlopen将使用POST方法提交数据
    timeout则是访问超时时间 超过多长时间后如果还没有等到服务器响应数据 则抛出URLError异常

#### <font color='#DDA0DD'>手动构造Request</font>
> 手动构造Request的好处就是自己可以添加或修改Request的字段 比如修改User-Agent把自己伪装为浏览器去访问页面 urllib2访问网页的默认User-Agent是Python-urllib/2.7

```python
import urllib2
request = urllib2.Request("http://www.baidu.com/")
response = urllib2.urlopen(request)
print response.read()
```
    
Request类允许用户自定义请求头部(header), 同样Request默认使用的也是GET方法 下面看看Request用法 
    
```python
urllib2.Request(url, data=None, headers={})
```

    如果给Request提供了data的值 那么请求将变成POST
    

#### <font color='#DDA0DD'>Headers信息修改</font>
> 为了直观的看到headers的变化 我们先用socket模块 模拟一个web服务器出来

```python
#!/usr/bin/env python
import socket
s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.bind(('0.0.0.0',8080))
s.listen(5)
print 'Listen on 0.0.0.0:8080...'
try:
    while True:
        conn,addr = s.accept()
        print conn.recv(99999)
        conn.send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<h1>Hello!</h1>')
        conn.close()
except:
    s.close()
```
    
    将这个脚本启动 先确定8080端口未被占用 或者自行修改端口 接着尝试用urllib2打开这个地址
    
    GET / HTTP/1.1
    Accept-Encoding: identity
    Host: 192.168.4.233:8080
    Connection: close
    User-Agent: Python-urllib/2.7
    
    可以看到脚本输出了这样的信息 这个就是服务接受到urlopen发送的数据 可以看到是GET请求
    有很多web网站为了防止爬虫的访问 做了User-Agent检查 如果发现不是正规浏览器访问的就会拒绝掉
    那么现在尝试着修改下User-Agent的值
    
```python
import urllib2
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 BIDUBrowser/8.5 Safari/537.36'
    }
request = urllib2.Request('http://192.168.4.233:8080',headers=headers)
response = urllib2.urlopen(request)
```
    
可以将创立好的headers字典传递给Request的headers参数 也可以创建完Request对象后 手动将headers字典赋值给request.headers属性 或者通过request对象的add_header方法添加
    
```python
request.headers = headers       # 或者
request.add_header('User-Agent','Mozilla/5.0 (Windows NT 10.0; WOW64)......')
```
    
以上两种方法是等效的 但是不同的是 add_header只能一次添加一个头部字段 而通过传递字典可以添加多个
比如我们可以针对做了防盗链处理的网站服务器 在request中添加Referer字段 表明示从那个页面发起访问的
    
```python
import urllib2
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64)......',
    'Referer': '192.168.4.233:8080'
    }
request = urllib2.Request('http://192.168.4.233:8080',headers=headers)
response = urllib2.urlopen(request)
```
    
    接下来可以看到打印的headers中的User-Agent已经改变了 而且多了Referer字段
    
    GET / HTTP/1.1
    Accept-Encoding: identity
    Host: 192.168.4.233:8080
    Referer: 192.168.4.233:8080
    Connection: close
    User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64)......
    
    各大浏览器的User-Agent的值可以通过百度查询得到 也可以在浏览器中 通过开发者模式的network里查到
    
#### <font color='#DDA0DD'>GET和POST方法传递数据</font>
> 如果仅仅访问静态页面 简单的GET请求数据就可以了 但是现在大多的网站都是动态网站 需要向服务器传递一些数据才能获取想要的页面 比如有些页面必须登陆才可以浏览等 下面就看看如何使用urllib发送GET和POST请求
    
    接下来就需要使用urllib模块中的urlencode方法对数据进行编码为适合在HTTP上传输的类型了
    
**GET方法：**
    
```python
import urllib, urllib2
values = {'user':'myusername','passwd':'11223344'}
data = urllib.urlencode(values)
url = 'http://192.168.4.233:8080/login?'
request = urllib2.Request(url+data)
response = urllib2.urlopen(request)
print response.read()
```
    
    GET /login?passwd=11223344&user=myusername HTTP/1.1
    Accept-Encoding: identity
    Host: 192.168.4.233:8080
    Connection: close
    User-Agent: Python-urllib/2.7
    
    最后我们实际请求的URL是 http://192.168.4.233:8080/login?passwd=11223344&user=myusername
    用?分隔服务器资源和向资源传递的参数 参数中用key=value的方式 两个key之间用&隔开
    如果value中有特殊字符了 比如空格 = 等特殊字符怎么处理 详细资料可以看urlencode和urldecode
    
    GET方法直接将需要传递的数据构造为URL的一部分 如果传送密码这样敏感的数据当然是不可以的
    接下来就用到POST方法了
    
**POST方法：**
    
```python
import urllib, urllib2
values = {'user':'myusername','passwd':'11223344'}
data = urllib.urlencode(values)
url = 'http://192.168.4.233:8080/login'     # 因为不是GET方法 所以不需要?号分隔了
request = urllib2.Request(url,data)         # 注意是逗号隔开的 实际上是将data传递给了参数data
response = urllib2.urlopen(request)
print response.read()
```
    
    可以看到这回构造的request和GET方法构造的有很大不同
    
    POST /login HTTP/1.1
    Accept-Encoding: identity
    Content-Length: 31
    Host: 192.168.4.233:8080
    Content-Type: application/x-www-form-urlencoded
    Connection: close
    User-Agent: Python-urllib/2.7

    passwd=11223344&user=myusername
    
    可以看到 多了Content-Length和Content-Type两个字段 一个说明内容的长度 一个说明内容类型
    而且数据内容并不是直接显示在URL中的 这样就适合传送比较大的数据或者比较敏感的数据
    
    还有一点需要注意 POST请求传递的数据可以是任意格式的 并不一定非要是通过urlencode编码后的数据
    比如直接传输一个二进制文件 request = urllib2.Request(url,data=open('/bin/bash','rb').read())
    
    还有一个比较重要的地方就是Content-Type 这个字段决定了服务器或者客户端如和处理接收到的内容
    如果传送的二进制数据 不确定类型的话 可以将Content-Type更改为application/octet-stream
    具体其他类型的数据的Content-Type可以查阅 "HTTP Content-type 对照表"
    
#### <font color='#DDA0DD'>使用Proxy访问网页</font>
> 有些网站为了防止被爬虫程序 或者被Ddos攻击等 限定了单位时间内对服务器的请求次数 但是道高一尺魔高一丈 爬虫程序还是有方式绕过限制的 那就是使用代理
    
```python
import urllib2
def setProxy(addr):
    proxy_handler = urllib2.ProxyHandler({"http" : addr})
    opener = urllib2.build_opener(proxy_handler)
    urllib2.install_opener(opener)

request = urllib2.Request('http://cip.cc/')
request.add_header('User-Agent','curl')
print urllib2.urlopen(request).read()
print '-------------proxy-------------'
setProxy('122.96.xx.xxx:8080')
print urllib2.urlopen(request).read()
```


    IP	: 124.65.xxx.xx
    地址	: 中国  北京市
    运营商	: 联通
    数据二	: 北京市 | 联通
    URL	: http://www.cip.cc/124.65.xx.xx
    
    -------------proxy-------------
    IP	: 122.96.xx.xxx
    地址	: 中国  江苏省  南京市
    运营商	: 联通
    数据二	: 江苏省南京市 | 联通
    URL	: http://www.cip.cc/122.96.xx.xxx

    cip.cc是个可以查询出口公网IP地址的网站 并且对curl工具的访问做了优化 所以模拟为curl工具访问
    proxy_handler是使用代理的处理器 build_opener添加配置好的proxy_handler代理器 返回一个对象
    这个对象也有个open方法 这个方法可以像urllib2.urlopen一样使用 不同的是只有open才会使用代理
    install_opener则会创建一个全局使用的opener 也就是说 urllib2.urlopen的默认行为也会使用代理
    
    来看下面的例子
    
```python
import urllib2
proxy_handler = urllib2.ProxyHandler({"http" : '122.96.xx.xxx:8080'})
opener = urllib2.build_opener(proxy_handler)
request = urllib2.Request('http://cip.cc/')
request.add_header('User-Agent','curl')
print urllib2.urlopen(request).read()
print '-------------opener-------------'
print opener.open(request).read()
```

    IP	: 124.65.xxx.xx
    地址	: 中国  北京市
    运营商	: 联通
    数据二	: 北京市 | 联通
    URL	: http://www.cip.cc/124.65.xx.xx
    
    -------------opener-------------
    IP	: 122.96.xx.xxx
    地址	: 中国  江苏省  南京市
    运营商	: 联通
    数据二	: 江苏省南京市 | 联通
    URL	: http://www.cip.cc/122.96.xx.xxx
    
    可以看到效果是完全相同的 只不过opener.open是局部的 而urllib2.urlopen是全局的
    通过install_opener则可以把opener.open安装为全局的 build_opener还可以安装多个不同的Handler
    
#### <font color='#DDA0DD'>开启Debug日志</font>
> 开启urllib的Debug日志后 每次完成一次与服务器交互 都会将打印出request和response信息 这样更方便调试错误

```python
import urllib2
proxy_handler = urllib2.ProxyHandler({"http" : '122.96.xx.xxx:8080'})
http_handler = urllib2.HTTPHandler(debuglevel=1)
opener = urllib2.build_opener(proxy_handler, http_handler)
request = urllib2.Request('http://cip.cc/')
request.add_header('User-Agent','curl')
print opener.open(request).read()
```
    
    同时给build_opener传入了两个处理器 执行opener.open的时候 可以发现两个处理器都生效了 以下是返回数据
    
    send: 'GET http://cip.cc/ HTTP/1.1\r\nAccept-Encoding: identity\r\nHost: cip.cc\r\nConnection: close\r\nUser-Agent: curl\r\n\r\n'
    reply: 'HTTP/1.1 200 OK\r\n'
    header: Server: nginx
    header: Date: Tue, 26 Jul 2016 04:57:13 GMT
    header: Content-Type: text/html; charset=UTF-8
    header: Transfer-Encoding: chunked
    header: Connection: close
    header: Vary: Accept-Encoding
    IP	: 122.96.xx.xxx
    地址	: 中国  江苏省  南京市
    运营商	: 联通
    数据二	: 江苏省南京市 | 联通
    URL	: http://www.cip.cc/122.96.xx.xxx
    
    send就是发送的request 而reply就是服务器的response了 如果是https页面 则需要设置HTTPSHandler
    urllib2.build_opener(proxy_handler, http_handler, urllib2.HTTPSHandler(debuglevel=1))
    
    
#### <font color='#DDA0DD'>使用cookie模拟登陆</font>
> HTTP协议是无状态的 也就是说你这次的请求 和下次的请求并没有联系 那么这样子 服务器怎么区分用户的身份呢 那么就是cookie的作用了
可以这样理解 当用户登录网站成功了 网站就给这个用户下发一个令牌 也就是cookie 下次用户再访问网站的其他页面的时候 就顺便带上令牌 那么服务器端只要区分不同的令牌就知道用户的身份了
所以 cookie是一个非常方便 又同时非常危险的东西 比如我在局域网中 抓取到某人登陆某网站的cookie 然后我就可以直接使用该cookie访问这个网站 那么就实现了免密码登陆了 这也是为什么很多敏感的网站cookie的有效期这么短 下次访问就有可能需要重新登陆的原因了 下面就看看urllib如和处理cookie和cookie模拟登陆的吧
    
**使用已有的cookie登陆百度：**


    已登录网站的cookie可以通过开发者模式获取 这里以Chrome内核的浏览器为例 360浏览器等都相同
    一般F12都可以直接打开开发者模式 然后点击 Network 刷新下你已经登陆了的百度的首页 
    然后看到Network -> Name块出现了一堆请求的资源 找到www.baidu.com 打开后就可以看到Headers了
    找到Request Headers中的Cookie字段 可以看到一大堆的字符串 这个字符串是经过加密的 复制下来

```python
import urllib2
request = urllib2.Request('http://www.baidu.com/')
request.add_header('Cookie','BD_CK_SAM=1; H_PS_645EC=0c53pNyqSabVK%2BP......')
result = urllib2.urlopen(request).read()
open('baidu.html','w').write(result)
```
    
    可以将url换成tieba.baidu.com 然后去访问百度贴吧 看看保存到本地的网页是不是已经登陆状态呢
    这就是最简单的用cookie模拟登陆的方法了 但是我们不可能每次都通过这种方式获取cookie吧
    这就需要用程序实现如和使用账号密码登陆 然后保存cookie 然后用cookie访问其他页面
    
**使用账号密码登陆：**

    这个环节其实是非常复杂的 因为现在的大多网站 为了避免爬虫等工具 登陆需要短信验证 验证码验证等
    而且密码可能被先经过算法加密后才上传的 甚至登陆的步骤还有非常多的坑 开发者模式以后将经常用到
    这里的例子使用了公司内部的网站实现数据自动提交
    
```python
import urllib
import urllib2
import cookielib
cookie = cookielib.CookieJar()
cookie_handler = urllib2.HTTPCookieProcessor(cookie)
opener = urllib2.build_opener(cookie_handler)
login_info = urllib.urlencode({'sysName':'aabbcc','sysPsw':'112233'})
resp = opener.open('http://16.190.x.xxx/sysLoginAction.jsp',data=login_info,timeout=20)
post_data = 'city1=%C8%FD%D1%C7&zt1=%B9%CA%D5%CF%A3%ACrds%C8%EB%BF%E2%CD%A3%D6%B9'
post_url = 'http://16.190.1.207/thesisFlatRoot/save_info1.jsp?ls=0'
resp = opener.open(post_url,data=post_data,timeout=20)
```
    
    代码没有任何的异常捕捉 就假设可以正常的执行完毕 这里引入了新库 cookielib
    这个库是专门处理cookie的库 同样也是安装给opener 然后模拟登陆后带着获取的cookie去提交数据
    这个login_info是通过开发者模式中 手动登录一次网站 然后分析想后端服务器POST的什么数据
    而post_data则是每天的任务中点击提交按钮实际上POST上去的数据 通过脚本就不用每天登陆提交了
    CookieJar是将cookie保存到一个变量中的 还可以将Cookie保存到文件中 这样就不用每次都登陆了
    
**将cookie保存到文件**

    保存cookie到文件的对象是FileCookieJar 我们使用它的子类MozillaCookieJar来实现
    
```python
import urllib2,cookielib
cookie_file = 'cookie.txt'
cookie = cookielib.MozillaCookieJar(cookie_file)
cookie_handler = urllib2.HTTPCookieProcessor(cookie)
opener = urllib2.build_opener(cookie_handler)
response = opener.open("http://www.baidu.com/")
cookie.save(ignore_discard=True, ignore_expires=True)
```

    ignore_discard的意思是即使cookies将被丢弃也将它保存下来
    ignore_expires的意思是如果在该文件中cookies已经存在 则覆盖原文件写入
    可以看到当前目录出现了cookie.txt 接下来就是看看如何从文件中读取cookie了
    
**从文件中读取cookie**

    从文件中读取cookie可以免去每次执行脚本都重新登陆一次 除非cookie过期的情况下才需要重新登录

```python
import urllib2,cookielib
cookie = cookielib.MozillaCookieJar()
cookie.load('cookie.txt', ignore_discard=True, ignore_expires=True)
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookie))
response = opener.open("http://www.baidu.com/")
```

    这样如果cookie.txt中保存的是你登陆百度后的cookie 那么下次通过cookie.txt就可以直接登陆百度了
    现在数据获取方面的工作已经差不多了 数据获取还有一个比较优秀的requests库 可以自行研究下
    接下来就是如何从网页数据中提取我们需要的信息了

### <font color='#CDAA7D'>正则表达式</font>
> 在编写处理字符串的程序或网页时 经常会有查找符合某些复杂规则的字符串的需要 正则表达式就是用于描述这些规则的工具 换句话说 正则表达式就是记录文本规则的代码 下面看看正则表达式的常用项

#### <font color='#DDA0DD'>常用元字符</font>

|      代码      |      说明     |
| -------------  |:------------- |
| .         |   匹配除换行符以外的任意字符  |
| \w        |   匹配字母或数字或下划线或汉字  |
| \s        |   匹配任意的空白符  |
| \d        |   匹配数字  |
| ^         |   匹配字符串的开始  |
| $         |   匹配字符串的结束     |


#### <font color='#DDA0DD'>常用限定符</font>

|      代码      |      说明     |
| -------------  |:------------- |
| *         |   重复零次或更多次  |
| +         |   重复一次或更多次  |
| ?         |   重复零次或一次  |
| {n}       |   重复n次  |
| {n,}      |   重复n次或更多次  |
| {n,m}     |   重复n到m次     |

#### <font color='#DDA0DD'>常用的反义代码</font>

|      代码      |      说明     |
| -------------  |:------------- |
| \W         |   匹配任意不是字母，数字，下划线，汉字的字符  |
| \S         |   匹配任意不是空白符的字符  |
| \D         |   匹配任意非数字的字符  |
| \B       |   匹配不是单词开头或结束的位置  |
| [^x]      |   匹配除了x以外的任意字符  |
| [^aeiou]     |   匹配除了aeiou这几个字母以外的任意字符     |

#### <font color='#DDA0DD'>常用分组语法</font>

|      代码      |      说明     |    
| -------------  |:------------- |:----------|
|  (exp) | 匹配exp,并捕获文本到自动命名的组里|
|   (?"name"exp)    |匹配exp,并捕获文本到名称为name的组里|
|(?:exp)|匹配exp,不捕获匹配的文本，也不给此分组分配组号|
|(?=exp)|匹配exp前面的位置|
|(?<=exp)< span="">|匹配exp后面的位置|
|(?!exp)|匹配后面跟的不是exp的位置|
|(?|匹配前面不是exp的位置|
|(?#comment)|提供注释让人阅读|

#### <font color='#DDA0DD'>懒惰限定符</font>

|      代码      |      说明     |
| -------------  |:------------- |
| *?         |   重复任意次，但尽可能少重复  |
| +?         |   重复1次或更多次，但尽可能少重复  |
| ??         |   重复0次或1次，但尽可能少重复  |
| {n,m}?       |   重复n到m次，但尽可能少重复  |
| {n,}?      |   重复n次以上，但尽可能少重复  |

#### <font color='#DDA0DD'>简单用法</font>
> 用最简单的例子 看看正则表达式在网页中如何匹配需要的信息

```html
<html lang="cn">
    <head>
        <title>regex</title>
        <meta charset="utf-8"></meta>
    </head>
    <body alink="red" bgcolor="black" vlink="yellow" text="blue">
        <h1>subject</h1>
        <hr size="10px" width="50%" />
        <a href="http://127.0.0.1:5000/a.html">
            <img src="img/123.jpg" width="140" height="100" alt="image"/>
        </a>
        <a href="http://127.0.0.1/b.html">page1</a><br />
        <a href="http://127.0.0.1/c.html">page2</a>
    </body>
</html>
```

    在python中 正则表达式的库是re库 现在只需要简单掌握re.findall的用法
    
    
```python
import re
print re.findall(r'<title>(.*?)</title>',html)
```
    re.findall的用法是 re.findall(pattern, string, flags)
    
    匹配的结果是 ['regex'] 这是一个列表 如果有多个符合条件的字符串 都会出现在列表内
    html就是上面的那段html代码 r'<title>(.*?)</title>' 就是用来匹配网页title的正则表达式
    这里用到了()分组匹配 匹配被<title>和</title>包裹的内容 .*?则是非贪婪模式匹配
    如果需要匹配的字符有元字符等特殊字符 就需要用 \ 进行转义 比如匹配baidu.com就需要 baidu\.com
    
    因为\是转义字符 如果要匹配\字符或者\b(数字) 就需要写成 \\ 和 \\b 这样带来了非常多的不便
    所以在字符串的前面加入 r'' 表示原生字符串 就可以写成 r'\' 和 r'\b' 这样就完美的解决了问题 
    
```python
import re
re.findall('<a href=".*?">.*?</a>',html)
re.findall('<a href="(.*?)">(.*?)</a>',html)
```

    匹配的结果是
    ['<a href="http://127.0.0.1/b.html">page1</a>', '<a href="http://127.0.0.1/c.html">page2</a>']
    [('http://127.0.0.1/b.html', 'page1'), ('http://127.0.0.1/c.html', 'page2')]
    
    现在能深深的体会到()的重要性了吧 会对()内的字符串自动分组 但是有个奇怪的地方 好像有个链接丢失了
    html中一共有三个<a>标签 但是只匹配到两个 仔细观察发现 第一个<a>标签和闭合标签</a>不在同一行
    
    因为 . 这个元字符匹配除换行符以外的任意字符  因为第一个<a>和</a>被换行符隔断了 所以匹配不到
    这时就需要用到flags这个参数了 比如re.I 忽略大小写 re.S 使 . 元字符完全匹配任何字符

```python
import re
re.findall('<a href="(.*?)">(.*?)</a>',html,re.S)
```

    [('http://127.0.0.1:5000/a.html', '\n            <img src="img/123.jpg" ......
    
    可以看到 所有的<a>标签都被匹配到了
    re还有许多的匹配方法 比如re.finditer  re.sub  re.search  re.match等 可以自行学习


### <font color='#CDAA7D'>实战爬取数据</font>
> 现在获取网页数据的方式和正则表达式都已经有了一定的了解 那就开始实际的爬取些有意思的东西

#### <font color='#DDA0DD'>千趣网专题爬取</font>
> 千趣网是个分享有意思新闻的网站 不需要登陆就可以浏览内容 也没有什么防爬措施 所以先拿它练手

```python
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import re
import urllib2

HOST = 'http://www.qianqu.cc'       # 要爬的网站

def getHTML(url):                   # 获取网页源码
    request = urllib2.urlopen(url,timeout=5)
    return request.read()

def makeUrl(baseUrl):               # 用来构造每一页的URL地址
    def getPageNum():               # 获取每个专栏有多少页
        html = getHTML(baseUrl.format(1))
        return int(re.findall(r'pages: (.*?),',html,re.S)[0])
    for i in range(1,getPageNum()+1):
        yield baseUrl.format(i)     # 返回一个可迭代的对象来节省内存

def getTitle(url):                  # 获取一页有多少文章 返回文章的标题和URL
    request = urllib2.urlopen(url)
    html = request.read()
    div = re.findall(r'<div class="article">(.*?)</div>',html,re.S)
    for i in div:
        try:
            result = re.findall(r'<a href="(.*?)".*</a>.*<p>(.*?)</p>.*',i,re.S)[0]
        except:
            raise StopIteration
        yield (HOST+result[0],result[1])

def getContext(url):                # 根据获取到的文章URL检索出内容
    request = urllib2.urlopen(url)
    html = request.read()
    div = re.findall(r'<div class="contentText">(.*?)</div>',html,re.S)[0]
    div = div.replace('&nbsp;','')
    text = ''
    for i in re.split('<.*?>',div):
        text += i+'\n' if i else ''
    return text.replace('点击阅读全文','')

def main():                     # 将函数组合起来进行工作 最后返回一个包含URL,标题,文章的字典
    urlPool = makeUrl('http://www.qianqu.cc/tech/page/{}')
    for i in urlPool:
        for x in getTitle(i):
            news = {
                'url':x[0].decode('utf-8'),             # 由于网页源码是utf-8编码 所以需要先解码
                'title':x[1].decode('utf-8'),
                'text':getContext(x[0]).decode('utf-8')
            }
            yield news

if __name__ == '__main__':      # 这个里面看你想如和处理收集到的数据了 
    for i in main():            # 可以打印出来 也可以存数据库
        raw_input('Enter key continue ...')
        print i['title']
        print i['text']
```
    
    千趣有许多专题 比如生活啊 科技啊之类的 这里以科技为例 现在分析下爬取内容的思路
    
    def getHTML(url):
    定义一个获取网页源码的函数 因为千趣网没有反爬措施 所以就非常简单的发送请求 然后返回内容
    如果爬取其他网站发现失败 可以试着修改User-Agent等必要的字段试试

    def makeUrl(baseUrl):
    先进行分析千趣科技模块的URL 发现URL是http://www.qianqu.cc/tech 往下翻还有许多页数
    所以就需要一个函数能自动生成这些页数的URL 想获取一共有多少页 还需要对网页内容进行分析
    发现在页面的一段javascript脚本中 pages: 208, 而这个刚好就是这个科技专题的页码数
    定义一个getPageNum()的函数 用正则表达式检索出这个数字 然后提供makeUrl去生成URL
    
    def getTitle(url):
    接下来就是请求makeUrl生成的URL 获取每一个URL中有多少个文章的标题和文章的URL
    在chrome内核的浏览器 Ctrl + U 打开页面的源代码 通过分析发现 每个文字标题都是通过<div>布局的 
    这样就可以先捕获每个标题所在的div 然后再进行二次匹配出需要的标题和文字的URL
    
    def getContext(url):
    接下来就是获取标题内容页的数据了
    对内容中的数据重新处理 去掉多余的HTML标签 并且去掉空格 和没有用处的字符串
    
    def main():
    将需要的函数组合起来 开始工作 并最后返回一个字典
    字典有三个字段 分别是url title 和text 对应着文章url 文章标题还有文章内容
    
    可以发现 这个爬虫脚本还是有非常多可以改进的地方 比如没有异常处理等等 
    最后就是考虑如何处理这些数据了这里只是简单的打印了出来 最好的方法当然是保存到数据库
    
### <font color='#CDAA7D'>将数据保存入数据库</font>
> 从千趣网抓取的数据可以选择存放到Nosql 比如mongodb redis等数据库中 也可以存放到普通的数据库 比如mysql sqlite3中 下面以python自带的标准库sqlite3为例

```python
if __name__ == '__main__':
    import sqlite3,time
    with sqlite3.connect('qianqu.sqlite3') as conn:
        db = conn.cursor()
        create_table = 'create table if not exists qianqu (id integer primary key autoincrement,title varchar(128),url varchar(128),text text)'
        db.execute(create_table)
        insert_sql = u'insert into qianqu (url,title,text) values (?,?,?)'
        for i in main():
            db.execute(insert_sql,(i['url'],i['title'],i['text']))
            conn.commit()
            print i['url']+' OK!'
            time.sleep(1)
```

    只需要将if __name__ 的部分改为这样就可以了 
    这里导入sqlite3的库 然后用with管理一个sqlite3数据库的连接 然后按照字典key去建表
    为了防止爬取速度太快 导致对方服务器可能封锁IP 所以就每1秒爬取一次 然后将数据写入数据库中
    
    到这里 对python写爬虫已经有一个大致的学习了 这里没有用到任何的第三方库 都是用标准库实现的
    程序还有很多不完善的地方 比如如果中途断开了 那么脚本往数据库插入数据又得重新开始
    
## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>Python爬虫进阶</font>
>如果想进一步的提高自己的爬虫水平 就需要学习一些第三方库和一些优秀的爬虫框架了 下面做了一个总结

#### <font color='#DDA0DD'>数据获取类</font>

|      模块     |      说明     |
| -------------  |:------------- |
| requests     |   一个非常好用的网络库  |
| pycurl         |   libcurl的绑定 非常强大  |
| urllib3       |   HTTP库 安全连接池 支持文件post 可用性高  |
| tornado      |   高效的非阻塞web框架 可以做HTTP Client  |
|aiohttp|asyncio的HTTP客户端/服务器|

#### <font color='#DDA0DD'>数据解析工具</font>

|      模块     |      说明     |
| -------------  |:------------- |
| lxml|C语言编写高效HTML/XML处理库 支持XPath|
|cssselect|解析DOM树和CSS选择器|
|pyquery |解析DOM树和jQuery选择器|
|BeautifulSoup|低效但方便的HTML/XML处理库|
|html5lib|根据WHATWG规范生成HTML/ XML文档的DOM|
|xmltodict|一个可以让你在处理XML时感觉像在处理JSON一样的模块|


#### <font color='#DDA0DD'>爬虫框架</font>

|      模块     |      说明     |
| -------------  |:------------- |
| grad | 网络爬虫框架(基于pycurl/multicur)|
|scrapy|网络爬虫框架(基于twisted)|
|pyspider|一个强大的爬虫系统|
|cola|一个分布式爬虫框架|

#### <font color='#DDA0DD'>数据库驱动</font>

|      模块     |      说明     |
| -------------  |:------------- |
| mysqlclient | python的mysql驱动 |
| psycopg2 | python的postgresql驱动|
| pymongo | python的mongodb驱动 |
| redis | python的redis驱动 |

#### <font color='#DDA0DD'>其他工具</font>

|      模块     |      说明     |
| -------------  |:------------- |
| PhantomJS| 无界面的,可脚本编程的WebKit浏览器引擎|
| Selenium | 自动化测试工具|


