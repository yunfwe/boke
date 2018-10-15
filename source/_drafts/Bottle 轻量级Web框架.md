---
title: Bottle 轻量级Web框架
date: 2018-07-12 12:50:00
updated: 2018-07-15
categories: 
    - Python
tags:
    - bottle
    - python
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
---


## 简介
> Bottle 是一个快速、简单、轻量级的 Python Web 框架，Bottle 作为一个单独的文件模块分发，而且除了标准库没有任何第三方依赖，但是麻雀虽小五脏俱全，所以非常适合第一次接触 Python Web 开发的新手入门学习使用。Bottle 支持URL映射、模板引擎、访问表单、文件上传等功能。内建 HTTP 开发服务器，而且还支持 Paste, Gevent, gunicorn 等高性能 WSGI 服务器。本文通过阅读[官方文档](http://bottlepy.org/docs/0.12/) 并结合自己的实际测试编写而成。
<!-- more -->

## 使用

### 快速安装体验

Bottle 的安装非常简单，可以通过 `easy_install bottle` 或者使用 `pip install bottle` 来安装，甚至可以直接下载 [Bottle.py](https://github.com/defnull/bottle/raw/master/bottle.py) (最新版，非稳定版) 放到程序目录下来使用。Bottle 可以运行在 **Python2.5+** 和 **Python3.x** 上。

目前 Bottle 稳定版为 `0.12.13`，开发版为 `0.13-dev`。[点此打开Github地址](https://github.com/bottlepy/bottle)

**看一个简单的例子：**
```python
import bottle

app = bottle.Bottle()

@app.route('/hello/<name>')
def index(name):
    return bottle.template('<b>Hello {{name}}</b>!', name=name)

app.run(host="localhost", port=8080)
```

**启动脚本：**

    (python3) root@ubuntu:~# python demo.py
    Bottle v0.12.13 server starting up (using WSGIRefServer())...
    Listening on http://localhost:8080/
    Hit Ctrl-C to quit.

**使用浏览器或者 curl 测试：**

    root@ubuntu:~# curl http://127.0.0.1:8080/hello/yunfwe        
    <b>Hello yunfwe</b>!

如果学过 Flask 框架，可以发现它们的语法非常相似。

### 教程

#### 安装

Bottle 不依赖任何第三方库，所以可以直接将 `bottle.py` 下载到项目目录中使用，但这通常下载的是最新开发版。

    $ wget https://github.com/defnull/bottle/raw/master/bottle.py

如果更喜欢稳定版，可以在 PyPi 上获取，推荐使用 pip 包管理器来安装，或者使用 easy_install 也可以。

    $ sudo pip install bottle
    $ sudo easy_install bottle

Bottle 支持 Python2.5 或者更高版本才能正常运行，如果你没有权限在系统范围内安装，可以使用 Python虚拟环境 `virtualenv`。

#### Hello World

安装成功后，从最简单的 "Hello World" 示例开始吧！

```python
import bottle

app = bottle.Bottle()

@app.route('/hello')
def hello():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True, reloader=True)
```

运行此代码，访问 `http://localhost:8080/hello`，将在浏览器中看到 "Hello World!"，下面是它的工作原理：

使用 `app.route()` 装饰器装饰的函数 `hello()`，与 `app.route()` 传入的路径参数 `/hello` 做绑定，当浏览器请求 URL 时，如果匹配了这个路径，将调用这个路径所绑定的函数，并将函数的返回值发送回浏览器，就是这么简单。路由是这个框架最重要的概念，你可以根据需求定义任何数量的路由。

最后一行的 `app.run()` 会启动一个内置的开发服务器，它根据传递的参数在 `localhost` 上的 `8080` 端口启动服务，直到你通过 `Ctrl-C` 停止这个服务。`debug=True` 会以调试模式启动服务，在开发过程中是非常有用，但是在程序发布后应该是关闭的。`reloader=True` 也是在开发时非常有用的一个小技巧，Bottle 会自动检测当前脚本是否更新，如果有更新会自动帮你重新运行程序，这样就免去每次改了代码，需要手动停止程序再重新启动程序的过程，这个配置在生产环境也应该是关闭的。

#### 请求路由

上一章中，我们只构建了一个只有一条路由，而且非常简单的 Web 应用程序。多个 `app.route()` 都可以绑定到通一个回调函数上，看下面的例子：

```python
@app.route('/')
@app.route('/hello/<name>')
def hello(name='yunfwe'):
    return bottle.template('Hello {{name}}!\n', name=name)
```

浏览器访问：

    root@ubuntu:~# curl http://127.0.0.1:8080/
    Hello yunfwe!
    root@ubuntu:~# curl http://127.0.0.1:8080/hello/bottle
    Hello bottle!

这个示例告诉我们两件事：可以将多个路由绑定到同一个函数上，并且可以向URL添加通配符，并通过关键字参数访问它们。

##### 动态路由

包含通配符的路由称为动态路由，并且可以匹配满足条件的所有URL。简单的通配符由尖括号中的名称组成，例如：`<name>`。
路由 `/hello/<name>` 会匹配 `/hello/alice` 以及 `/hello/bob` 等，如果遇到了下一个斜杆 `/` 则不会匹配，例如：`/hello/mr/smith`。

每个通配符都将匹配到的部分作为关键字参数传递给路由绑定的回调函数，所以回调函数应该提供参数接收它们，否则将会抛出异常。通过动态路由，可以设计出漂亮而且有意义的URL，下面是一些示例：

```python
@app.route('/wiki/<pagename>')
def show_wiki_page(pagename):
    pass

@app.route('/<action>/<user>')
def user_api(action, user):
    pass
```

##### 过滤器

还可以使用过滤器来定义更具体的通配符，在将URL匹配到的部分传递给回调函数前通过过滤器来转换它们。

当前内置的几个过滤器：
+ `:int` 仅匹配正整数，并将值转为整数后传递给回调
+ `:float` 类似于 `:int`，将值转为浮点数后传递给回调
+ `:path` 以非贪婪的方式匹配包含斜杠字符在内的所有字符，并且可以用于匹配多个路径段
+ `:re[:exp]` 允许使用自定义的正则表达式匹配，匹配的值不会被修改或者转换。

**示例：**
```python
@app.route('/int/<val:int>')
def test_int(val):
    return str(val) + '\n'

@app.route('/float/<val:float>')
def test_float(val):
    return str(val) + '\n'

@app.route('/path/<val:path>')
def test_path(val):
    return str(val) + '\n'

@app.route('/re/<val:re:[a-z]+>')
def test_re(val):
    return str(val) + '\n'
```

**结果：**

    root@ubuntu:~# curl http://127.0.0.1:8080/int/123
    123
    root@ubuntu:~# curl http://127.0.0.1:8080/float/1.1
    1.1
    root@ubuntu:~# curl http://127.0.0.1:8080/path/usr/local/
    usr/local/
    root@ubuntu:~# curl http://127.0.0.1:8080/re/abcdef
    abcdef


##### HTTP请求方法

HTTP协议为不同的任务定义了几种请求方法，`GET` 方法是 Bottle 路由的默认方法，如果需要处理其他方法，比如 `POST`, `PUT`, `DELETE` 等方法，需要添加一个 `method` 参数到 `app.route()` 装饰器上，或者使用 `app.get()`, `app.post()`, `app.put()`, `app.delete()` 这四个备选装饰器。

`POST` 方法常用于 HTML 表单提交，下面示例演示如何使用 `POST` 处理登陆表单。

```python
import bottle

app = bottle.Bottle()

# 或者使用 @app.route('/login')
@app.get('/login')  
def login():
    return '''
        <form action="/login" method="post">
            Username: <input name="username" type="text" />
            Password: <input name="password" type="password" />
            <input value="Login" type="submit" />
        </form>
'''

# 或者使用 @app.route('/login', method='POST')
@app.post('/login') 
def do_login():
    username = bottle.request.forms.get('username')
    password = bottle.request.forms.get('password')
    if username == 'root' and password == '123456':
        return "<p>Your login information was correct.</p>\n"
    else:
        return "<p>Login failed.</p>\n"

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True, reloader=True)
```

**使用浏览器或者 curl 验证结果：**

    root@ubuntu:~# curl http://127.0.0.1:8080/login -X GET
            <form action="/login" method="post">
                Username: <input name="username" type="text" />
                Password: <input name="password" type="password" />
                <input value="Login" type="submit" />
            </form>
    root@ubuntu:~# curl http://127.0.0.1:8080/login -X POST --data 'username=root&password=654321'
    <p>Login failed.</p>
    root@ubuntu:~# curl http://127.0.0.1:8080/login -X POST --data 'username=root&password=123456'
    <p>Your login information was correct.</p>

或者还可以在一个回调函数里同时处理 `GET` 和 `POST` 请求，需要传给 `method` 参数一个列表，将需要的 HTTP 方法加入到列表中 例如：`method=['GET', 'POST']`，然后在回调函数中通过 `bottle.request.method` 来判断当前请求的方法：

```python
import bottle

app = bottle.Bottle()

@app.route('/login', method=['GET', 'POST'])
def login():
    if bottle.request.method == 'GET':
        return '''
        <form action="/login" method="post">
            Username: <input name="username" type="text" />
            Password: <input name="password" type="password" />
            <input value="Login" type="submit" />
        </form>
'''
    if bottle.request.method == 'POST':
        username = bottle.request.forms.get('username')
        password = bottle.request.forms.get('password')
        if username == 'root' and password == '123456':
            return "<p>Your login information was correct.</p>\n"
        else:
            return "<p>Login failed.</p>\n"

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True, reloader=True)
```

**特殊方法：HEAD 和 ANY**

`HEAD` 方法和 `GET` 方法类似，但是 `HEAD` 方法并不返回消息体，只返回 HTTP 协议头部信息。`HEAD` 方法常用来测试链接的有效性。当对 Bottle 的 `GET` 路由使用 `HEAD` 方法访问时，Bottle 会正常按照 `GET` 请求处理，但是并不会返回消息体（回调函数的返回结果）。

`ANY` 方法会匹配所有请求方法，但也只会在没有定义其他更具体的路由时。这对于将请求重定向到更具体的子应用程序的代理路由很有用。

##### 显式路由配置

如果不想使用装饰器的方式来定义路由，可以显式的将某个函数传递给某个路由，下面看一个简单的例子：

```python
import bottle

app = bottle.Bottle()

def hello():
    return 'Hello World!'

app.route('/', 'GET', hello)
```

或者使用一个工厂函数：

```python
import bottle

def hello():
    return 'Hello World!'

def setup_routing(app, urls):
    for u in urls:
        app.route(*u)

urls = [
    ('/', 'GET', hello),
]

app = bottle.Bottle()
setup_routing(app, urls)
```

##### 错误页面

如果出现任何问题，Bottle 会显示一个包含错误信息但非常简单的错误页面，可以通过 `app.error()` 装饰器来覆盖特定 HTTP 状态码的默认页面：

```python
@app.error(404)
def error404(error):
    return 'Nothing here, Sorry!\nError Message: %s\n' % str(error) 
```

当访问一个未定义的页面时：

    root@ubuntu:~# curl http://127.0.0.1:8080/abc
    Nothing here, Sorry!
    Error Message: (404, "Not found: '/abc'")

还可以捕捉 `abort()` 主动抛出的错误：

```python
@app.route('/abort')
def test_abort():
    bottle.abort(500, ' Server error')

@app.error(500)
def error500(error):
    return 'Error Message: %s\n' % str(error)
```

    root@ubuntu:~# curl http://127.0.0.1:8080/abort
    Error Message: (500, ' Server error')

#### 生成响应

在存 WSGI 中，一个标准的 WSGI 应用必须返回可迭代的字符串。而 Bottle 更灵活，支持多种类型，并且会自动添加一个合适的 `Content-Type` 头部。下面是路由绑定的回调函数允许返回的类型列表：

+ **dict**：返回字典类型的数据会自动转换为 JSON 字符串，并设置 `Content-Type` 类型为 `application/json`。
+ **空字符串，False，None或其他非真值**：会产生一个空输出，并将 `Content-Length` 设置为 0。
+ **Unicode**：会使用 `Content-Type` 中指定的编码（默认UTF-8）自动编码，然后将其视为普通字符串。
+ **Byte**：字节类型，Bottle 将整个字节串作为一个整体返回，并且根据长度设置 `Content-Length`。
+ **HTTPError或HTTPResponse**：返回一个 HTTPError 或 HTTPResponse 的实例，如果是 HTTPError，则会运行错误处理程序
+ **文件对象**：具有 `.read()` 方法的所有内容都被视为文件对象，并传递给定义在 WSGI 服务框架中的 `wsgi.file_wrapper` 可调用对象。一些 WSGI 服务器可以利用更优的系统调用(`sendfile`) 来高效的传输文件。`Content-Length` 或 `Content-Type` 都不会自动设置。
+ **迭代器和生成器**：只要是可以产生或迭代 Unicode, Byte, HTTPError, HTTPResponse 类型，就可以在回调函数中使用。

下面看一些示例：

```python
@app.route('/dict')
def test_dict():
    return {'msg':'hello bottle'}

@app.route('/false')
def test_false():
    return False

@app.route('/unicode')
def test_unicode():
    return u'喵喵喵'

@app.route('/byte')
def test_byte():
    return b'abcabc'

@app.route('/response')
def test_response():
    return bottle.HTTPResponse(body='hello bottle', status=200)

@app.route('/file')
def test_file():
    return open('/etc/issue','rb')

@app.route('/generators')
def test_generators():
    for i in range(10):
        yield str(i)
```

结果：

    root@ubuntu:~# curl http://127.0.0.1:8080/dict
    {"msg": "hello bottle"}
    root@ubuntu:~# curl http://127.0.0.1:8080/false
    root@ubuntu:~# curl http://127.0.0.1:8080/unicode
    喵喵喵
    root@ubuntu:~# curl http://127.0.0.1:8080/byte
    abcabc
    abcabcroot@ubuntu:~# curl http://127.0.0.1:8080/response
    hello bottle
    root@ubuntu:~# curl http://127.0.0.1:8080/file
    Ubuntu 16.04.5 LTS \n \l
    root@ubuntu:~# curl http://127.0.0.1:8080/generators
    0123456789



##### 更改默认编码

Bottle 使用 `Content-Type` 标头的字符集参数来决定如何对 Unicode 字符串进行编码。此标头默认为 `text/html;charset=UTF8`，并且可以使用 `bottle.response.content_type` 来进行修改。
例如：

```python
@app.route('/gbk')
def get_latin():
    bottle.response.content_type = 'text/html; charset=gbk'
    return u'这些文字将使用gbk编码'
```

##### 处理静态文件

Bottle 没有像 Flask 一样默认提供了静态文件路由，必须手动添加路由和回调来控制要提供的文件。虽然你可以直接返回一个文件对象，Bottle 提供的 `static_file()` 以一种安全和方便的方式提供文件访问，默认会自动检测文件拓展类型，并提供合适的 `mimetype`。浏览器对于文本文件，图像文件等可能会直接浏览而不是下载，这时可以使用 `download=True` 来使浏览器强制下载文件。如果想指定客户端拿到的文件名，可以使用 `download=filename`，客户端将自动将文件保存为传给 `download` 的文件名。

```python
@app.route('/static/filepath:path')
def server_static(filepath):
    return bottle.static_file(filepath, root='/your/static/files/path')
```

指定静态文件的根目录时一定要小心，如果使用了相对路径，很有可能并不是你想象得那样。可以试试使用 `os.path.dirname(os.path.abspath(__file__))` 巧妙的获取脚本所在目录。

##### HTTP错误和重定向

调用 `bottle.abort()` 函数是生成 HTTP 错误页面的快捷方法。

```python
@app.route('/restricted')
def restricted():
    bottle.abort(401, "Sorry, access denied.")
```

如果将客户端重定向到其他URL，可以使用 `bottle.redirect()`，它会发送 `303 See Other`，并且添加 `Location` 头部来告诉客户端新的地址在哪。你还可以提供不同的 HTTP 状态码作为重定向函数的第二个参数。

```python
@app.route('/old')
def old():
    bottle.redirect("/new")

@app.route('/new')
def new():
    return 'New page.'
```

    root@ubuntu:~# curl http://127.0.0.1:8080/old -L
    New page.

##### response 对象

响应的元数据，比如 HTTP 状态码、响应标头 还有 Cookie 存储在 `bottle.response` 对象中。你可以直接或使用预定义的方法操作这些元数据，直到它们被传输到浏览器。这里介绍最常见的用例和功能。

**状态码**
HTTP 状态码控制浏览器的行为，默认值为 `200 OK`。可以通过设置 `bottle.response.status` 来更改状态吗，在大多数情况下不需要手动设置，但使用 `abort()` 或者返回 `HTTPResponse` 实例时需要提供状态码。

**响应头**

修改响应头，比如添加 `Cache-Control` 或者修改 `Content-Type` 可以通过 `bottle.response.set_header()` 和 `bottle.response.add_header()` 来修改。它们接受两个参数，一个标头名，一个值。这两个方法的区别是，`set_header()` 会覆盖已有的标头名，而 `add_header()` 则会继续添加一个即使已存在的标头。

##### Cookie 

Cookie 是一种用户客户端跟踪技术，Bottle 中可以通过 `bottle.request.get_cookie()` 和 `bottle.response.set_cookie()` 获取和设置 Cookie。

```python
@app.route('/cookie')
def test_cookie():
    if bottle.request.get_cookie("visited"):
        return "Welcome back! Nice to see you again\n"
    else:
        bottle.response.set_cookie("visited", "yes")
        return "Hello there! Nice to meet you\n"
```

使用 curl 测试访问，第一次将 Cookie 保存到文件，第二次带上 Cookie 去访问：

    root@ubuntu:~# curl http://127.0.0.1:8080/cookie -c cookie.txt
    Hello there! Nice to meet you
    root@ubuntu:~# curl http://127.0.0.1:8080/cookie -b cookie.txt
    Welcome back! Nice to see you again

`set_cookie()` 方法接受许多其他关键字参数来控制 Cookie 的生存期和行为，这里介绍一些常用的设置：

+ **max_age**：表示 Cookie 创建后多久过期，单位为秒。如果为 0，表示立即过期，为 -1 表示关闭窗口后 Cookie 就过期。
+ **expires**：指定一个 Cookie 的过期时间点，值是 UNIX 时间戳，现在已被 max_age 取代。
+ **domain**：允许读取 Cookie 的域，可以使多个web服务器共享 Cookie。
+ **path**：指定与 Cookie 关联在一起的网页。默认情况下 Cookie 会与创建它的页面，以及该页面下的子页面关联。
+ **secure**：限制 Cookie 使用 HTTPS 连接，默认不限制。
+ **httponly**：限制客户端 JavaScript 读取 Cookie。

如果没有设置 Cookie 有效期，则默认在页面会话结束后立即过期，在使用 Cookie 时应该考虑下面这些问题：

+ 在大多数浏览器中，Cookie 的大小限制为 4K 的文本
+ 有些用户将浏览器设置为不接受 Cookie。
+ Cookie 存储在客户端，不以任何方式加密，攻击者可能通过 XSS 漏洞窃取用户的 Cookie。
+ Cookie 很容易伪造，不要过于相信 Cookie。

**Cookie 签名**

如上所述，恶意客户很容易伪造 Cookie，Bottle 可以对 Cookie 进行签名加密，以防止这种伪造。你只需在 `set_cookie()` 和 `get_cookie()` 时通过 `secret` 参数提供密钥签名。如果 cookie 未签名，或者签名不匹配，`get_cookie()` 将返回 `None`：

```python
@app.route('/cookie')
def test_cookie():
    if bottle.request.get_cookie("visited", secret='qweasd'):
        return "Welcome back! Nice to see you again\n"
    else:
        bottle.response.set_cookie("visited", "yes", secret='qweasd')
        return "Hello there! Nice to meet you\n"
```

接下来用 curl 验证结果

    root@ubuntu:~# cat cookie.txt 
    # Netscape HTTP Cookie File
    # http://curl.haxx.se/docs/http-cookies.html
    # This file was generated by libcurl! Edit at your own risk.

    127.0.0.1	FALSE	/	FALSE	0	visited	yes
    root@ubuntu:~# curl http://127.0.0.1:8080/cookie -b cookie.txt
    Hello there! Nice to meet you
    root@ubuntu:~# curl http://127.0.0.1:8080/cookie -c cookie.txt
    Hello there! Nice to meet you
    root@ubuntu:~# curl http://127.0.0.1:8080/cookie -b cookie.txt
    Welcome back! Nice to see you again
    root@ubuntu:~# cat cookie.txt 
    # Netscape HTTP Cookie File
    # http://curl.haxx.se/docs/http-cookies.html
    # This file was generated by libcurl! Edit at your own risk.

    127.0.0.1	FALSE	/	FALSE	0	visited	"!7Bk4nXY6kRKp8QWKVN4ZWQ==?gASVEwAAAAAAAACMB3Zpc2l0ZWSUjAN5ZXOUhpQu"


可以看到，之前的 `cookie.txt` 文件里，`visited` 字段的值是明文的，带着旧的 Cookie 访问服务，服务已经不承认旧的 Cookie 了。之后重新保存新的 Cookie，才可以继续使用。而新的 `cookie.txt` 文件里，`visited` 字段的值已经是加密后的。

Cookie 将所有信息都保存到了客户端，这样是极不安全的，对应的有比较安全的 Session 技术，将用户信息保存在服务端，通过在 Cookie 中保存一个 SessionID，然后使用 SessionID 来获取用户信息。可惜 Bottle 并没有实现 Session，想在 Bottle 中使用 Session 技术，还需要利用第三方实现。

#### 请求数据

Cookie, HTTP 标头, HTML `<form>` 字段和其他请求数据可以通过全局的 `request` 对象获取。即使在多线程多客户端连接的环境，这个特殊的对象也始终引用当前请求。

该对象是 `BaseRequest` 的子类，它有丰富的访问数据的 API，我们这里介绍最常用的。

##### FormsDict

Bottle 使用一种特殊类型的字典来存储表单数据和 Cookie。`FormsDict` 的行为就像一个普通字典，但是有一些额外的功能，使你使用的更方便。

**属性访问**：字典中的所有值都可以作为属性访问，这些虚拟属性返回 Unicode 字符串，即使该值丢失或者 Unicode 解码失败。这种情况下，字符串为空，但仍存在：

```python
name = bottle.request.cookies.name
name = bottle.request.cookies.getunicode('name') # encoding='utf-8' (default)
try:
    name = bottle.request.cookies.get('name', '').decode('utf-8')
except UnicodeError:
    name = u''
```

**每个键多个值**：`FormsDict` 是 `MultiDict` 的子类，可以为每个键存储多个值。标准字典访问方法只能返回单个值，但 `getall()` 方法返回指定键的所有值的列表。

```python
for choice in request.forms.getall('multiple_choice'):
    do_something(choice)
```

**WTForms支持**：一些库（例如`WTForms`）希望将 Unicode 字典作为输入，`FormsDict.decode()` 会自动解码所有值并返回自身的副本，同时保留每个键的所有值和功能。

##### Cookie

前面已经讲到使用 `set_cookie()` 和 `get_cookie()` 来设置和获取 Cookie，客户端发送的所有 Cookie 还可以通过 `FormsDict` 获取，下面看一个简单的例子：

```python
@app.route('/count')
def counter():
    count = int(bottle.request.cookies.get('counter','0'))
    count += 1
    bottle.response.set_cookie('counter', str(count))
    return 'Count: %d\n' % count
```

使用 curl 或者浏览器不停的刷新页面，可以看到计数器一直在增加：

    root@ubuntu:~# curl http://127.0.0.1:8080/count -b cookie.txt -c cookie.txt
    Count: 1
    root@ubuntu:~# curl http://127.0.0.1:8080/count -b cookie.txt -c cookie.txt
    Count: 2
    root@ubuntu:~# curl http://127.0.0.1:8080/count -b cookie.txt -c cookie.txt
    Count: 3
    root@ubuntu:~# curl http://127.0.0.1:8080/count -b cookie.txt -c cookie.txt
    Count: 4
    root@ubuntu:~# curl http://127.0.0.1:8080/count -b cookie.txt -c cookie.txt
    Count: 5

##### HTTP 标头

客户端发送的所有 HTTP 标头都存储在 `WSGIHeaderDict` 中，可以通过 `BaseRequest.headers` 属性访问。`WSGIHeaderDict` 的键基本上都是不区分大小写的。

```python
@app.route('/headers')
def headers():
    return bottle.request.headers.get('User-Agent') + '\n'
```

打印出客户端标识：

    root@ubuntu:~# curl http://127.0.0.1:8080/headers
    curl/7.47.0

##### HTML 表单处理

在 HTML 中，典型的 `<form>` 看起来像这样：

```html
<form action="/login" method="post">
    Username: <input name="username" type="text" />
    Password: <input name="password" type="password" />
    <input value="Login" type="submit" />
</form>
```

`action` 属性指定将接收表单数据的 URL，`method` 定义要使用的 HTTP 方法。用 `method="get"` 返回的表单，可以使用 `BaseRequest.query` 来接收，但 GET 请求并不是安全的，所以在返回用户名和密码用 POST 方法。通过 POST 返回的表单存储在 `BaseRequest.forms`。服务端代码可能如下所示：

```python
@app.post('/login') 
def do_login():
    username = bottle.request.forms.get('username')
    password = bottle.request.forms.get('password')
    if username == 'root' and password == '123456':
        return "<p>Your login information was correct.</p>\n"
    else:
        return "<p>Login failed.</p>\n"
```

还有其他几个属性可以用于访问表单数据，下面给出一个整体概述：

|属性| GET 表单字段| POST 表单字段 | 文件上传|
|-|-|-|-|
|BaseRequest.query|	yes|	no|	no|
|BaseRequest.forms|	no|	yes	|no|
|BaseRequest.files|	no|	no|	yes|
|BaseRequest.params|	yes|	yes|	no|
|BaseRequest.GET|	yes	|no|	no|
|BaseRequest.POST|	no|	yes	|yes|

##### 文件上传

为了支持文件上传，我们需要修改 `<form>` 标签。首先需要添加标签 `enctype="multipart/form-data"` 来告诉浏览器如何编码，然后添加 `<input type="file" />` 来让用户选择文件：

```python
<form action="/upload" method="post" enctype="multipart/form-data">
  Select a file: <input type="file" name="upload" />
  <input type="submit" value="Start upload" />
</form>
```

Bottle 使用 `BaseRequest.files` 存储上传的文件以及一些有关上传的元数据，它是 `FileUpload` 的实例。下面是个服务端保存上传的文件的示例：

```python
@app.route('/upload', method='POST')
def do_upload():
    upload = bottle.request.files.get('upload')
    filename = upload.filename
    upload_root = "/tmp"
    upload.save(upload_root)
    return filename + '\n'
```

使用 curl 测试上传文件

    root@ubuntu:~# curl http://127.0.0.1:8080/upload -F "upload=@/etc/issue"
    issue
    root@ubuntu:~# cat /tmp/issue 
    Ubuntu 16.04.5 LTS \n \l

`FileUpload.filename` 会对文件名清理和规范化，以防止文件名中出现不支持的字符或路径导致错误。如果想访问未经修改的文件名，可以通过访问 `FileUpload.raw_filename`。

`FileUpload.save` 将文件安全高效的存储到硬盘，如果想手动操作文件数据流，可以访问 `FileUpload.file`：

```python
@app.route('/upload', method='POST')
def do_upload():
    upload = bottle.request.files.get('upload')
    return upload.file.read()
```

    root@ubuntu:~# curl http://127.0.0.1:8080/upload -F "upload=@/etc/issue"
    Ubuntu 16.04.5 LTS \n \l

这里使用了最危险的读取文件的方法，如果文件非常大，可能系统内存会耗尽，所以最好不要这样做。

##### JSON 内容

如果客户端将 `Content-Type: application/json` 的内容发送到服务器，`BaseRequest.json` 属性会包含已解析的数据（数据结构正常的情况下）。

```python
@app.route('/json', method='POST')
def test_json():
    return bottle.request.json
```

    root@ubuntu:~# curl http://127.0.0.1:8080/json -X POST -H 'content-type: application/json' -d '{"msg":"hello world"}'
    {"msg": "hello world"}

##### 原始请求体

你可以通过原始数据作为类文件对象访问 `BaseRequest.body`。这是 `BytesIO` 缓冲区或临时文件，具体取决于内容长度和 `BaseRequest.MEMFILE_MAX` 的设置（默认1M大小）。可以通过 `bottle.request['wsgi.input']` 来访问它。

上传的内容非常大的情况下（比如上传一个巨大的JSON内容），可以在程序开始提供给 `bottle.BaseRequest.MEMFILE_MAX` 一个合适的值。否则将抛出 `413 Request Entity Too Large`。

##### WSGI 环境
每个 `BaseRequest` 实例都包含一个 WSGI 环境字典，如果想直接访问它，可以通过 `BaseRequest.environ` 来直接访问：

```python
@app.route('/getip')
def getip():
    return bottle.request.environ.get('REMOTE_ADDR')
```

    root@ubuntu:~# curl http://127.0.0.1:8080/getip
    127.0.0.1

#### 模板引擎

Bottle 附带了一个快速而强大的内置模板引擎，名为 `Simple Template Engine`，要渲染模板，可以使用 `template()` 函数或者 `view()` 装饰器。需要做的就是将模板名称和关键字参数传递给模板：

```python
@app.route('/hello')
@app.route('/hello/<name>')
def test_template(name='World'):
    return bottle.template('hello', name=name)
```

这里传递的模板名为 `hello`，Bottle 会在脚本所在目录和所在目录中的 `views` 目录下寻找模板文件，可以通过将路径添加到 `bottle.TEMPLATE_PATH`列表中来增加 Bottle 的搜索路径。模板文件的拓展名为 `tpl`，接着在脚本目录下创建 `views` 目录，然后在这个目录下新建 `hello.tpl` 文件，写入如下内容：

```tpl
%if name == 'World':
    <h1>Hello {{name}}!</h1>
    <p>This is a test.</p>
%else:
    <h1>Hello {{name.title()}}!</h1>
    <p>How are you?</p>
%end
```

测试访问，可以看到模板中根据 `name` 的值进行了逻辑处理

    root@ubuntu:~# curl http://127.0.0.1:8080/hello
        <h1>Hello World!</h1>
        <p>This is a test.</p>
    root@ubuntu:~# curl http://127.0.0.1:8080/hello/abc
        <h1>Hello Abc!</h1>
        <p>How are you?</p>

也可以直接将模板字符串传递给 `template()` 函数，但是并不推荐这样做 例如：

```python
@app.route('/hello')
@app.route('/hello/<name>')
def test_template(name='World'):
    hello = """%if name == 'World':
    <h1>Hello {{name}}!</h1>
    <p>This is a test.</p>
%else:
    <h1>Hello {{name.title()}}!</h1>
    <p>How are you?</p>
%end"""
    return bottle.template(hello, name=name)
```

模板使用 `%` 开始编写 Python 的代码，使用 `%end` 结束代码块，更详细的语法规则 下面会讲到。
模板在编译后，将缓存在内存中，在清楚缓存之前，对模板的任何改动都不会立即生效，可以通过调用 `bottle.TEMPLATES.clear()` 来清理缓存，如果在调试模式下将禁用缓存。

#### 插件

Bottle 的核心功能涵盖了最常见的用例，但作为一个微框架，它有其局限性，插件为框架添加缺少的功能，这就是插件发挥作用的地方。

##### 体验插件

这里看看 `SQLitePlugin` 插件的简单用法，首先通过pip安装这个插件：`pip install bottle-sqlite`，然后看下面示例：

```python
import bottle
from bottle_sqlite import SQLitePlugin

app = bottle.Bottle()
sqlite_plugin = SQLitePlugin(dbfile='/tmp/test.db')
app.install(sqlite_plugin)

@app.route('/createdb')
def create(db):
    db.execute('create table data (key varchar, value varchar)')
    db.commit()
    return 'True\n'

@app.route('/set')
def db_set(db):
    key = bottle.request.params.get('k')
    value = bottle.request.params.get('v')
    db.execute('insert into data values (?,?)', (key, value))
    db.commit()
    return 'True\n'

@app.route('/get')
def db_get(db):
    key = bottle.request.params.get('k')
    c = db.execute('select value from data where key=?', (key,))
    row = c.fetchone()
    print(row)
    return row[0] + '\n'

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True, reloader=True)
```

对接口进行测试：

    root@ubuntu:~# curl http://127.0.0.1:8080/createdb
    True
    root@ubuntu:~# curl "http://127.0.0.1:8080/set?k=a&v=qwe"
    True
    root@ubuntu:~# curl "http://127.0.0.1:8080/get?k=a"
    qwe

对 `app` 对象安装 `SQLitePlugin` 插件，接着在需要使用数据库的地方，给回调函数添加 `db` 关键字即可，关键字的位置无所谓。插件检测到添加了 `db` 的关键字后，会将一个打开的 `sqlite3.Connection` 对象传递给 `db` 关键字，这样就可以在回掉函数中操作数据库了。

##### 卸载插件

卸载插件非常简单，调用 `app.uninstall()` 函数即可：

```python
app.uninstall(sqlite_plugin)    # 卸载指定的插件
app.uninstall(SQLitePlugin)     # 卸载这个类型的所有插件
app.uninstall('sqlite')         # 卸载以这个名称开头的所有插件
app.uninstall(True)             # 一次性卸载所有插件
```

##### 将插件安装到指定的路由

有时候并不想全局安装某个插件，可以单独将这个插件安装到某个路由上：

```python
sqlite_plugin = SQLitePlugin(dbfile='/tmp/test.db')
@app.route('/create', apply=[sqlite_plugin])
def create(db):
    pass
```
将需要应用到这个路由的插件添加到 `apply` 参数的列表中就可以了。

##### 黑名单插件

有时候不想让某个函数应用某个插件，可以使用 `skip` 来跳过这些插件：

```python
sqlite_plugin = SQLitePlugin(dbfile='/tmp/test.db')
app.install(sqlite_plugin)
@app.route('/create', skip=[sqlite_plugin])
def create():
    pass
```

如果设置 `skip=True` 将跳过所有插件。

##### 插件与子程序

将一个 Bottle 程序挂挂载到另一个 Bottle 程序上，相当于在主程序上创建一个代理路由，访问该代理路由的请求都转发到相应的子程序。此类代理路由是禁用插件的，安装在主程序上的插件并不会影响到子程序 例如：

```python
import bottle
from bottle_sqlite import SQLitePlugin

app = bottle.Bottle()
blog = bottle.Bottle()

sqlite_plugin = SQLitePlugin(dbfile='/tmp/test.db')
app.install(sqlite_plugin)

@blog.route('/db')
def blog_db(db='Not sqlite db\n'):
    return str(db)

@app.route('/db')
def app_db(db='Not sqlite db\n'):
    return str(db)

app.mount('/blog', blog)

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True, reloader=True)
```

访问这几个路由：

    root@ubuntu:~# curl http://127.0.0.1:8080/db
    <sqlite3.Connection object at 0x7fad044429d0>
    root@ubuntu:~# curl http://127.0.0.1:8080/blog/db
    Not sqlite db


使用 `app.mount()` 函数将 `blog` 的所有路由挂载到 `app` 的 `/blog` 路由下。

#### 实际开发

现在已经可以使用Bottle开发简单的应用了，下面这些知识可以帮助你提高工作效率。

##### 默认应用

Bottle 维护一个全局堆栈的 Bottle 实例，并使用堆栈顶部作为某些模块级函数和装饰器的默认值，例如 `bottle.route()` 装饰器，是调用默认应用程序的快捷方式：

```python
from bottle import route

@route('/')
def hello():
    return 'hello world'
```

对于小型应用程序会非常方便，但是只要导入模块，就会将路由安装到全局应用程序中。为了避免这种导入，Bottle 提供了更明确的方法：

```python
from bottle import Bottle

app = Bottle()
@app.route('/')
def hello():
    return 'hello world'
```

分离应用程序对象可以大大提高可重用性，其他开发人员也可以安全的从你的模块中导入对象并使用 `Bottle.mount()` 将应用程序合并在一起。另外还可以使用应用程序堆栈来隔离路由：

```python
from bottle import route, default_app
default_app.push()

@route('/')
def hello():
    return 'Hello World'

app = default_app.pop()
```

##### 调试模式

在开发早期，调试模式非常有用，可以在有错误发生时显示更详细的错误信息，并且模板不会缓存，插件也会立即应用。

可以通过调用 `bottle.debug(True)` 或者在 `app.run()` 中设置 `debug` 参数为 `True`。

##### 自动加载运行

在开发过程中，修改了代码必须手动重启服务才可以测试更改，自动重新加载器可以帮你完成这些工作：

```python
import bottle
app = bottle.Bottle()
app.run(reloader=True)
```

##### 命令行界面

从版本 `0.10` 开始，就可以使用 Bottle 作为命令行工具：

    root@ubuntu:~# python -m bottle
    Usage: bottle.py [options] package.module:app

    Options:
    -h, --help            show this help message and exit
    --version             show version number.
    -b ADDRESS, --bind=ADDRESS
                            bind socket to ADDRESS.
    -s SERVER, --server=SERVER
                            use SERVER as backend.
    -p PLUGIN, --plugin=PLUGIN
                            install additional plugin/s.
    --debug               start server in debug mode.
    --reload              auto-reload on file changes.

    Error: No application specified.

只用指定应用模块启动即可：

```python
import bottle

app = bottle.Bottle()

@app.route('/')
def hello():
    return 'Hello World'

```

将代码保存为 `hello.py`，然后通过命令行启动：`python -m bottle --debug --reload hello:app`，`hello` 是模块名，`app` 是应用对象。


### 配置

Bottle 应用程序的配置存储在 `Bottle.config` 这个类似于字典的对象里，可以用与通过配置告诉插件需要做什么，也可以存储自己的配置。

#### 基础配置

`Bottle.config` 的行为看起来很想普通字典，所有常见的字典方法都能按照预期工作，让我们看看一些例子：

```python
import bottle
app = bottle.Bottle()

app.config['autojson']    = False      # 关闭JSON自动转换的特性
app.config['sqlite.db']   = ':memory:' # 告诉SQLite插件使用哪个数据库
app.config['myapp.param'] = 'value'    # 自定义配置值

# 一次性配置多个值
app.config.update({
    'autojson': False,
    'sqlite.db': ':memory:',
    'myapp.param': 'value'
})

# 添加默认值
app.config.setdefault('myapp.param2', 'some default')

# 获取值
param  = app.config['myapp.param']
param2 = app.config.get('myapp.param2', 'fallback value')

# 在路由中从配置获取数据的例子
@app.route('/about', view='about.rst')
def about():
    email = app.config.get('my.email', 'nomail@example.com')
    return {'email': email}
```

`app` 对象并不是总是可用的，但是你可以在请求上下文中，使用 `request` 对象获取当前应用程序对象和它的配置

```python
from bottle import request
def is_admin(user):
    return user == request.app.config['myapp.admin_user']
```

#### 命名约定

为了更好的开发，插件和应用程序应遵守一些简单的命名规则：

+ 所有的键名都应该是小写字符串，不能有特殊字符，但下划线除外。
+ 命名空间由 "." 分隔，比如 `namespace.field`。
+ Bottle 使用根命名空间进行自己的配置，插件应将所有变量存储在自己的命名空间中，例如 `sqlite.db`。
+ 自定义的配置也应该有单独的命名空间，比如 `myapp.*`
  
#### 从文件加载配置

如果想使非程序员也能够配置程序，或想给程序带来高的可配置性，那么配置文件很有用。这里提供了配置文件的一种非常常见的语法：

```ini
[bottle]
debug = True

[sqlite]
db = /tmp/test.db
commit = auto

[myapp]
admin_user = defnull
```
现在可以通过 `load_config()` 方法加载这些配置文件：

```python
app.config.load_config('/etc/myapp.conf')
```

#### 从嵌套的字典加载配置

另一个常用的方法使 `load_dict()`。这个方法将嵌套的字典转换为具有命名空间键和值的平面字典。

```python
# 从字典中加载配置
app.config.load_dict({
    'autojson': False,
    'sqlite': { 'db': ':memory:' },
    'myapp': {
        'param': 'value',
        'param2': 'value2'
    }
})

assert app.config['myapp.param'] == 'value'

# 从json文件中加载配置
with open('/etc/myapp.json') as fp:
    app.config.load_dict(json.load(fp))
```

#### 监听配置更改

每次更改 Bottle 中的值时，都将触发应用程序对象上的 `config` 钩子。此钩子可用于在运行时对配置更改做出反应，例如重新连接到新数据库、更改后端服务上的调试设置 或者调整工作线程池的大小。钩子的回调函数接收两个参数(键, 新值)，并在字典中实际值更改之前调用，如果回调函数引发异常将取消更改，并保留原值。

```python
@app.hook('config')
def on_config_change(key, value):
    if key == 'debug':
        switch_own_debug_mode_to(value)
```
钩子的回调函数不能改变要存储到字典中的值，只能有过滤器的用处。

#### 过滤器和其他元数据

`ConfigDict` 允许你存储元数据和配置键，目前定义了两个源字段：

+ **help**: 帮助或说明字符串，可由调试、内省或管理工具去帮助站点管理员配置应用程序。
+ **filter**: 接收和返回单个值的可调用对象，如果你为键定义了过滤器，那么存储到该键的所有值都先通过过滤器。过滤器可以对值进行检查和修改，或者抛出异常。下面看个例子：

```python
class SomePlugin(object):
    def setup(app):
        app.config.meta_set('some.int', 'filter', int)
        app.config.meta_set('some.list', 'filter',
            lambda val: str(val).split(';'))
        app.config.meta_set('some.list', 'help',
            'A semicolon separated list.')

    def apply(self, callback, route):
        ...

import bottle
app = bottle.default_app()
app.install(SomePlugin())

app.config['some.list'] = 'a;b;c'     # 自动转为列表
app.config['some.int'] = 'not an int' # 抛出异常
```

### 简单模板引擎

Bottle 附带一个快速、功能强大且易学的内置模板引擎，简称 `SimpleTemplate`。 `view()` 和 `template()` 函数帮助用户使用这个引擎。这里解释模板语法，并提供几个常用的示例。

**基本 API 使用**

```python
from bottle import SimpleTemplate
tpl = SimpleTemplate('Hello {{name}}!')
tpl.render(name='World')
# 结果：u'Hello World!'
```

使用 `template()` 函数可以简化这个过程

```python
from bottle import template
template('Hello {{name}}!', name='World')
```

#### SimpleTemplate 语法

Python 是一种非常强大的语言，但它严格的缩进使它很难用于模板语言。`SimpleTemplate` 取消了这些限制，允许你编写干净，可读和可维护的模板，同时保留 Python 语言的功能。

##### 内联表达式

上面已经学习了 `{{...}}` 这样的语法，实际上可以在大括号中使用任何 Python 表达式：

    >>> template('Hello {{name}}!', name='World')
    'Hello World!'
    >>> template('Hello {{name.title() if name else "stranger"}}!', name=None)
    'Hello stranger!'
    >>> template('Hello {{name.title() if name else "stranger"}}!', name='mArC')
    'Hello Marc!'

如果传入的字符串包含 HTML 字符，则会自动转义来防止 XSS 攻击，但是你可以使用 `!` 来表示禁止转义：

    >>> template('Hello {{name}}', name='<b>World</b>')
    'Hello &lt;b&gt;World&lt;/b&gt;'
    >>> template('Hello {{!name}}', name='<b>World</b>')
    'Hello <b>World</b>'

##### 嵌入 Python 代码

模板引擎允许你在模板中嵌入 Python 代码行或块。代码行以 `%` 开头，代码快由 `<%` 和 `%>` 包围：

```tpl
% name = "Bob"  # 行级别的 Python 代码
<p>Some plain text in between</p>
<%
  # 块级别的 Python 代码
  name = name.title().strip()
%>
<p>More plain text</p>
```

嵌入的 Python 代码遵循常规 Python 语法，但有两个额外的语法规则：

+ 缩进被忽略，你可以根据需要在语句前尽可能多的放置空格，这样可以与周围的代码对其，提高可读性。
+ 缩进的块现在必须用 `%end` 显式关闭，比如：

```tpl
<ul>
  % for item in basket:
    <li>{{item}}</li>
  % end
</ul>
```
##### 空白符控制


### API参考
### 可用插件列表

## 部署

## 附录