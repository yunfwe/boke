---
title: ESP8266 WiFi开发板
date: 2018-04-29 10:12:00
categories: 
    - IoT
tags:
    - esp8266
photos:
    - /uploads/photos/88547ef3bc9cf39581ab10d911e32bcd.jpg
---

## 简介
> ESP8266串口WIFI模块，超低成本（只需10RMB左右）的物联网开发板，而且有非常丰富的引脚，超低的功耗。ESP8266内部有一个完整的 32bit MCU 核心，主频支持80Mz和160Mz。这个模块支持 IEEE802.11 b/g/n 协议，完整的 TCP/IP 协议栈，可以为现有的设备添加联网功能。而且除了C语言，还可以使用 Python, JavaScript, Lua脚本语言来为ESP8266写程序，极大降低了学习ESP8266的门槛。

<!-- more -->

## 环境

在 Win10 下进行开发，因为更熟悉 Python 所以使用 MicroPython 来进行开发。

### 硬件

+ **ESP8266开发板** 这里使用基于 ESP8266-12F 的 D1 WiFi UNO R3 开发板。
+ **数据线** 普通安卓的数据线就可以，D1 开发板集成了 CH340 USB转TTL芯片。

如果是其他系统的话，需要确保 CH340 的驱动有安装。

**D1 WiFi UNO R3** 开发板：
![](/uploads/2018/esp8266/kl8hd3a.jpg)

### 软件

+ **esptool** 固件烧录工具
+ **PuTTY** 串口连接工具
+ **esp8266 MicroPython固件** [点此下载](http://micropython.org/resources/firmware/esp8266-20171101-v1.9.3.bin)


### 烧录固件

esptool 需要Python运行环境的支持，所以需要提前安装 Python 然后配置好环境变量，或者也可以下载其他的固件烧写工具。

```
pip install esptool
```

装好之后从设备管理器中查看端口，如果是linux环境，应该是 `/dev/ttyUSB*`，然后先使用 `esptool.py` 命令擦除固件数据。

```
esptool.py --port COM4 erase_flash
```

    esptool.py v2.3.1
    Connecting....
    Detecting chip type... ESP8266
    Chip is ESP8266EX
    Features: WiFi
    Uploading stub...
    Running stub...
    Stub running...
    Erasing flash (this may take a while)...
    Chip erase completed successfully in 9.7s
    Hard resetting via RTS pin...

接着就可以将下载好的固件文件烧录到板子里了，固件的bin文件要选择实际的文件。

```
esptool.py --port COM4 --baud 460800 write_flash --flash_size=detect 0 esp8266.bin
```

    esptool.py v2.3.1
    Connecting....
    Detecting chip type... ESP8266
    Chip is ESP8266EX
    Features: WiFi
    Uploading stub...
    Running stub...
    Stub running...
    Changing baud rate to 460800
    Changed.
    Configuring flash size...
    Auto-detected Flash size: 4MB
    Flash params set to 0x0040
    Compressed 600888 bytes to 392073...
    Wrote 600888 bytes (392073 compressed) at 0x00000000 in 8.8 seconds (effective 546.1 kbit/s)...
    Hash of data verified.

    Leaving...
    Hard resetting via RTS pin...

烧录成功后就可以打开PuTTY，设置好COM口，波特率 115200 然后连接了。

    [开头这里乱码正常]#4 ets_task(40100130, 3, 3fff837c, 4)
    OSError: [Errno 2] ENOENT

    MicroPython v1.9.3-8-g63826ac5c on 2017-11-01; ESP module with ESP8266
    Type "help()" for more information.
    >>>

## 使用

### MicroPython
> 通过 MicroPython 的使用一些代码来认识下 ESP8266 的硬件

#### MicroPython 简单认识

MicroPython 使用Python3的语法，使用 `help('modules')` 命令可以看到支持的所有模块，

    >>> help('modules')
    __main__          http_client_ssl   sys               urandom
    _boot             http_server       time              ure
    _onewire          http_server_ssl   uasyncio/__init__ urequests
    _webrepl          inisetup          uasyncio/core     urllib/urequest
    apa102            json              ubinascii         uselect
    array             lwip              ucollections      usocket
    btree             machine           uctypes           ussl
    builtins          math              uerrno            ustruct
    dht               micropython       uhashlib          utime
    ds18x20           neopixel          uheapq            utimeq
    errno             network           uio               uzlib
    esp               ntptime           ujson             webrepl
    example_pub_button                  onewire           umqtt/robust      webrepl_setup
    example_sub_led   os                umqtt/simple      websocket
    flashbdev         port_diag         uos               websocket_helper
    framebuf          select            upip
    gc                socket            upip_utarfile
    http_client       ssd1306           upysh
    Plus any modules on the filesystem
    >>>

其中跟板子硬件相关的模块主要是 `esp` 和 `machine`，其他大多就是与网络有关的模块了，可以看出来还是比较丰富的。
简单的测试了下，对Python3的语法支持还是比较完善的，除了基本的数据类型和语法甚至 lambda表达式、列表解析、装饰器、生成器也都支持。

具体使用查看 [MicroPython官方文档](http://docs.micropython.org/en/latest/pyboard/index.html)

#### 查看资源信息

内存信息可以使用 `micropython.mem_info()` 获取

    >>> import micropython
    >>> micropython.mem_info()
    stack: 2112 out of 8192
    GC: total: 35968, used: 9744, free: 26224
    No. of 1-blocks: 48, 2-blocks: 24, max blk sz: 264, max free sz: 1132

8K的栈，35K的堆。。。不过这资源对于它也是够了。

Flash大小可以使用 `esp.flash_size()` 获取

    >>> import esp
    >>> str(esp.flash_size()/1024/1024) + ' MB'
    '4.0 MB'

4MB的存储空间，除去系统占用的只是存放一些简单的程序脚本也完全够用了。

#### 测试MCU的速度

ESP8266内置的MCU主频支持80MHz和160MHz，那么测试下这样的速度到底有多快呢。

在终端使用 `Ctrl + e` 进入代码粘贴模式，然后 `Ctrl + d` 提交或者 `Ctrl + c` 取消，然后键入以下代码。

```python
import time
import machine
import micropython

def toTime(tus):
    ts = [' us', ' ms', ' s']
    for t in ts:
        if tus < 1000:return str(tus)+t
        tus = tus / 1000
    
@micropython.native
def loop(count):
    t1 = time.ticks_us()
    for i in range(count):
        pass
    t2 = time.ticks_us()-t1
    print('Loop %s times for %s'%(count, toTime(t2)))

def loop_start(count=10000):
    cur_freq = machine.freq()
    machine.freq(80000000)
    freq = lambda :str(int(machine.freq()/1000000))
    print('Present freq: %sMHz' % freq())
    loop(count)
    machine.freq(160000000)
    print('Present freq: %sMHz' % freq())
    loop(count)
    machine.freq(cur_freq)
```

    >>> loop_start()
    Present freq: 80MHz
    Loop 10000 times for 30.567 ms
    Present freq: 160MHz
    Loop 10000 times for 15.299 ms
    >>>


代码提交后调用 `loop_start()` 方法，可以看到在默认的 80MHz 下和调节到 160MHz 下的空循环10000次需要多长时间，差不多每次循环使用不到16微妙。其中 `micropython.native` 装饰器能让代码以机器码的速度运行，如果好奇的话可以试试没有这个装饰器的执行速度。

将板子重启后，修改代码去掉那个加速的装饰器，然后重新提交代码执行测试（重启后可能得退出PuTTY后重连才能操作），可以看到速度慢了十几倍。

    >>> loop_start()
    Present freq: 80MHz
    Loop 10000 times for 460.035 ms
    Present freq: 160MHz
    Loop 10000 times for 230.091 ms
    >>>


### 网络功能
> 既然它是WiFi开发板，那么最大的特点应该是可以接入WiFi网络，并且通过网络和其他设备交换数据。

#### 连接WiFi

终端执行 `help()` 函数会显示一个基础的连接WiFi的方法，现在就来连接到一个WiFi试试。这里为了测试方便，用笔记本开了个热点给开发板用。

ESP8266跟连接WiFi相关的库是 `network` 库，先来看看这个库的使用

```python
import network

wlan = network.WLAN(network.STA_IF) # 创建一个WiFi对象
wlan.active(True)       # 激活接口
wlan.scan()             # 扫描目标
wlan.isconnected()      # 检查是否已经连接
wlan.connect('zhzz', '12365470') # 连接到WiFi
wlan.config('mac')      # 获取接口的mac地址
wlan.ifconfig()         # 获取接口的IP/掩码/网关/DNS信息
```

ESP8266如果断线会自动重连，`ifconfig()` 方法不仅可以查看当前IP，还可以配置静态IP，只需要将 `IP/netmask/gw/DNS` 作为一个元组或列表传入即可。比如:

```
wlan.ifconfig(('192.168.137.2','255.255.255.0','192.168.137.1','119.29.29.29'))
```

修改后会立即生效，如果在 `wlan.connect()` 之前就配置好了静态IP，这样就不会再向路由器发起DHCP请求了。

    C:\Users\yunfwe\Desktop>ping 192.168.137.2

    正在 Ping 192.168.137.2 具有 32 字节的数据:
    来自 192.168.137.2 的回复: 字节=32 时间=1ms TTL=255
    来自 192.168.137.2 的回复: 字节=32 时间=3ms TTL=255
    来自 192.168.137.2 的回复: 字节=32 时间=1ms TTL=255
    来自 192.168.137.2 的回复: 字节=32 时间=1ms TTL=255

    192.168.137.2 的 Ping 统计信息:
        数据包: 已发送 = 4，已接收 = 4，丢失 = 0 (0% 丢失)，
    往返行程的估计时间(以毫秒为单位):
        最短 = 1ms，最长 = 3ms，平均 = 1ms

只要连接WiFi成功后，再次重启开发板也会自动连接，不过配置的静态IP就丢失了，需要重新配置。如果不想让开发板在启动的时候自动连接WiFi，可以在使用后执行 `wlan.active(False)`。但是开发板还是保存了WiFi的连接信息，想彻底清除这个连接信息可以执行 `wlan.connect('','')`。

如果想看到更多的连接细节，可以启用系统的调式功能

```python
import esp
esp.osdebug(0)      # 将调试信息重定向到UART(0)
esp.osdebug(None)   # 关闭调试信息
```

#### AP模式

ESP8266除了可以连接WiFi外，还可以作为一个AP来使用

```python
wlan.disconnect()   # 先断开先前的连接
wlan.active(False)  # 取消激活接口
ap = network.WLAN(network.AP_IF)    # 创建AP对象
ap.active(True)     # 激活AP
ap.config(essid='esp8266',password='12345678', 
    authmode=network.AUTH_WPA2_PSK)          # AP的SSID和密码，认证方式使用wpa2
# ap.config(essid='esp8266',authmode=network.AUTH_OPEN)   # 或者创建没有密码的WiFi
```

如果想更改AP模式分配的网段，也可以使用 `ap.ifconfig()` 来设置。这个时候用手机或者电脑就可以连接到此设备了。

同时，ESP8266还支持 AP+STA 模式，这样就可以充当一个无线中继器了。还有 `SmartConfig` 技术，可以实现不连接开发板的情况下自动配置开发板连接WiFi，可惜比较遗憾的是，MicroPython 上并没有实现或者找到如何实现这样的功能。。。

#### WebREPL

ESP8266 还提供了一个在浏览器上远程打开 MicroPython 提示符的功能就是 WebREPL，而且在这个页面上还可以实现上传文件等功能，把自己写好的代码上传到开发板，然后让它开机运行。

打开这个功能非常简单，首先配置这个服务

```python
import webrepl_setup
```
执行后会询问你是否开机自启，输入 E 允许开机自启后需要配置一个连接密码来提高安全性，之后问你是否重启，输入 y 重启后可以看到提示符多了一行信息

    WebREPL daemon started on ws://0.0.0.0:8266
    Started webrepl in normal mode
    OSError: [Errno 2] ENOENT

    MicroPython v1.9.3-8-g63826ac5c on 2017-11-01; ESP module with ESP8266
    Type "help()" for more information.
    >>>

这个时候 可以打开官方提供的连接页面：[点此打开](http://micropython.org/webrepl/)，输入IP和端口，连接成功后如下
![](/uploads/2018/esp8266/hcn0xg6d537fqkzv.jpg)

还记得刚才写的测试MCU速度的脚本吗，现在把这个脚本也加入到系统里吧，这样每次开机后都可以使用这个测试的功能了。

把刚才的程序代码写入到一个名叫 `mcu.py` 的文件，在终端执行如下代码
```python
import os
os.listdir('/')
```
可以看到，一共有两个文件，一个是 `boot.py`，一个是 `webrepl.cfg.py`，其中 `boot.py` 会在开机的时候自动运行，`webrepl.cfg.py` 里面记录的就是Web上连接的时候需要的密码了。现在将 `boot.py` 下载下来，然后修改这个文件，在最后一行添加 `from mcu import loop_start`，然后将 `mcu.py` 和 `boot.py` 上传回去，然后重启板子。

    >>> os.listdir('/')
    ['boot.py', 'webrepl_cfg.py', 'mcu.py']
    >>> loop_start()
    Present freq: 80MHz
    Loop 10000 times for 30.56 ms
    Present freq: 160MHz
    Loop 10000 times for 15.296 ms
    >>>

可以看到，`loop_start()` 函数在启动的时候就会自动导入了，也就是说 `mcu.py` 被自动运行了，利用 `boot.py` 这样就可以实现开机的时候自动为WiFi配置静态IP了。

#### UDP/TCP

能使用UDP/TCP进行通讯，这才是物联网的第一步，MicroPython 上的 `socket` 模块提供了对网络套接字的支持。下面用几个例子来看看如何使用。

##### 广播自己的IP地址

开发板连接上WiFi了，但是你并不知道板子的IP怎么办，除了登陆路由器来查看它的IP，还可以让它主动告诉你啊。

下面看代码：
```python
import time
import socket
import network

def broadcast_ip():
    wlan = network.WLAN(network.STA_IF)
    while not wlan.isconnected():
        time.sleep(1)
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    for i in range(3):
        s.sendto(b'Hi! i am ESP8266!', ('255.255.255.255',2001))
        time.sleep(1)
```

将此代码保存为 `ip.py` 然后修改 `boot.py` 文件末尾添加：
```python
from ip import broadcast_ip
broadcast_ip()
```

这里选择了向整个局域网内的2001端口发送UDP广播，也可以定点向某台主机发送，但是如果自己的IP也是DHCP获取的，那么可能下一次就又得该代码了。

然后编写接收端的代码，接收端的代码在自己的电脑上运行。

```python
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('',2001))
print('Start listen on: 0.0.0.0:2001')
while True:
    d, a = s.recvfrom(1024)
    print("From: %s:%s\tMessage: %s" % (a[0], a[1], d.decode()))
```

然后保存为 `find_esp8266.py` 并启动脚本，接着重启开发板，几秒钟后可以看到收到开发板发来的消息了。

    C:\Users\yunfwe\Desktop>python find_esp8266.py
    Start listen on: 0.0.0.0:2001
    From: 192.168.137.197:4097      Message: Hi! i am ESP8266!
    From: 192.168.137.197:4097      Message: Hi! i am ESP8266!
    From: 192.168.137.197:4097      Message: Hi! i am ESP8266!


##### 获取NAT出口的公网IP

局域网内的主机都是通过NAT方式共享一个公网IP来访问互联网的，那么怎么获取自己出口的这个IP呢？如果自己有台公网上的服务器，让ESP8266向它发个包就知道了，可是大多数人都是没有公网上的服务器的，这样还可以利用第三方提供的查询服务。

这里使用搜狐的查询接口: [点此打开](http://pv.sohu.com/cityjson?ie=utf-8)，通过原始TCP套接字手动构建一个 HTTP 请求来访问数据

```python
import json
import socket

def get_nat_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ip = socket.getaddrinfo('pv.sohu.com',0)[0][-1][0]
    s.connect((ip,80))
    request  = b'GET /cityjson?ie=utf-8 HTTP/1.1\r\n'
    request += b'Host: pv.sohu.com\r\n\r\n'
    size = s.send(request)
    header, data = s.recv(1024).decode().split('\r\n\r\n')
    data = data.split('=')[1][1:-1]
    data = json.loads(data)
    s.close()
    print('NAT IP: %s' % data['cip'])

get_nat_ip()
```

在板子上执行看看吧！

### 硬件IO

通过网络来控制硬件，这样才能构建出各种智能硬件，先看看这块板子的引脚说明

<table><thead><tr><th width="25%">引脚</th><th>说明</th><th width="25%">IC 内部引脚</th></tr></thead><tbody><tr><td>D0(RX)</td><td>串口接收</td><td>GPIO3</td></tr><tr><td>D1(TX)</td><td>串口发送</td><td>GPIO1</td></tr><tr><td>D2</td><td>I/O，不支持中断、PWM、I2C、以及1-wire</td><td>GPIO16</td></tr><tr><td>D3/SCL/D15</td><td>I/O，默认模式下I2C的SCL</td><td>GPIO5</td></tr><tr><td>D4/SDA/D14</td><td>I/O，默认模式下I2C的SDA</td><td>GPIO4</td></tr><tr><td>D5/SCK/D13</td><td>I/O，SPI的时钟</td><td>GPIO14</td></tr><tr><td>D6/MISO/D11</td><td>I/O，SPI的MISO</td><td>GPIO12</td></tr><tr><td>D7/MOSI/D11</td><td>I/O，SPI的MOSI</td><td>GPIO13</td></tr><tr><td>D8</td><td>I/O，上拉，低电平时进入FLASH模式</td><td>GPIO0</td></tr><tr><td>D9/TX1</td><td>I/O，上拉</td><td>GPIO2</td></tr><tr><td>D10/SS</td><td>I/O，下拉，SPI时默认的片选(SS)</td><td>GPIO15</td></tr><tr><td>A0</td><td>AD输入，0-3.3V</td><td>ADC</td></tr></tbody></table>

+ 所有的IO工作电平为 **3.3V**，可瞬间承受 5V
+ 除D2外，所有 I/O 都支持中断，PWM，I2C，和 1-wire

#### GPIO

ESP8266-12F 板载了一颗蓝光的LED灯，就试试用代码控制这个灯吧。这颗灯会在 GPIO2 输出为高电平的时候灭掉，输出为低电平的时候亮起来，这样通过控制 GPIO2 口的电平高低就可以控制这颗LED的亮灭了。

ESP8266 跟硬件控制相关的库是 `machine`，下面看看用 MicroPython 如何控制 GPIO

```python
from machine import Pin

led = Pin(2, Pin.OUT)   # 将GPIO的2号引脚设置为输出
led.value(1)            # 将这个引脚设置为输出高电平
led.value(0)            # 将这个引脚设置为输出低电平
led.on()                # 相当于led.value(1)
led.off()               # 相当于led.value(0)
led.value()             # 获取当前的电平值
```

可以看到，执行 `led = Pin(2, Pin.OUT)` 的时候，本来灭着的LED灯突然亮了，接着执行 `led.value(1)` 的时候，LED灯灭了，这个时候 GPIO2 引脚输出的是高电平，如果在这个引脚上接一个LED灯或者其他设备，这个设备就开始工作了。

**D1 WiFi UNO R3** 这块板子上还板载了一颗接在 GPIO 14号引脚的LED灯，也可以通过 GPIO 直接控制这颗灯的亮灭，利用这个灯做一个 Blink LED 吧。

```python
import time
from machine import Pin

led = Pin(14,Pin.OUT, value=1)  # 创建时初始值为1
while True:
    led.on()
    time.sleep(0.5)
    led.off()
    time.sleep(1)
```
这颗LED灯已经开始以亮 0.5 秒，灭 1 秒的频率无限的闪下去了。

#### PWM

通过设置 GPIO 口的输出电平，只能控制灯的亮灭，那有没有什么办法可以调节灯的亮度呢，那就是 PWM。
那什么是 PWM 呢？还记得刚才让 LED 灯闪烁的例子吗，亮 0.5 秒，灭 1 秒，这样的频率肉眼很容易就观察出来了。那么如果减少这个休眠的时间，亮 1 毫秒，灭 2 毫秒，这样的频率，人的肉眼几乎就观察不出来了，而且看到的就是LED只有原来的 1/3 的亮度了。这里就引出了一个概念：占空比 通电时间占总时间的比例。而 PWM 就是调节这个的。

下面使用PWM测试下 GPIO14 上的这颗LED灯

```python
from machine import Pin, PWM

led = PWM(Pin(14))      # 对 GPIO14 进行PWM控制
led.freq()              # 获取当前的频率
led.freq(1000)          # 调整当前的频率
led.duty()              # 获取当前的占空比
led.duty(1000)          # 现在LED应该是满亮
led.duty(500)           # 现在LED应该是半亮
led.duty(10)            # 现在LED应该是微亮
led.deinit()            # 关闭对 GPIO14 的PWM控制
```

利用这个性质可以做出一个好看的呼吸灯特效，下面看代码

```python
from time import sleep_ms
from machine import Pin, PWM

led = PWM(Pin(2), freq=1000, duty=0)
while True:
    for i in range(0,1001,10):
        led.duty(i)
        sleep_ms(20)
    for i in range(1000,0,-10):
        led.duty(i)
        sleep_ms(10)
led.deinit()
```

#### Timer

ESP8266的内存实在太小了，因此 MicroPython 并没有为ESP8266实现多线程的功能，那么如果想通过网络来控制呼吸灯应该怎么做到呢？可以试试用定时器。

定时器类似于 JavaScript 的 `setTimeout` 和 `setInterval`，因为它们实现的功能是一摸一样的。MicroPython 的 `machine.Timer()` 会在给定的时间段执行一次或者周期性的执行这个回掉函数，下面看看具体是如何使用的。

```python
from machine import Timer
t1 = Timer(-1)      # 传给构造器一个ID，如果这个ID是-1，会初始化一个虚拟定时器
t1.init(period=5000, mode=Timer.ONE_SHOT, callback=lambda t:print(1))
t2 = Timer(0)
t2.init(period=2000, mode=Timer.PERIODIC, callback=lambda t:print(2))
t2.deinit()         # 取消定时器。
```

参数 `period` 是每个周期的时间，单位是毫秒。`mode` 是运行模式，是只运行一次还是周期性运行。`callback` 则是到了这个时间周期然后执行的函数。如果这个 `period` 时间非常短的话，而且周期性的运行一个函数，这个函数将自己的数据保存在全局环境中，等到下个运行周期到了再继续处理数据，如果存在多个不同回掉函数的定时器，切换速度非常快的情况下，不就相当于多个函数在同时运行了吗。定时器每次调用回掉函数的时候，还会将自己本身作为参数传给回掉函数。

下面看代码，运用上面所学的网络套接字，呼吸灯，还有定时器的知识来完成一个可以在局域网甚至公网来控制的呼吸灯。

```python
import time
import socket
import machine
import network

wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.ifconfig(('192.168.1.10', '255.255.255.0', '192.168.1.1', '119.29.29.29'))
wlan.connect('SSID', 'PASSWORD')

ap = network.WLAN(network.AP_IF)
ap.active(False)

led_timer = machine.Timer(1)
keep_alive_timer = machine.Timer(2)
net_control_timer = machine.Timer(3)
led = machine.PWM(machine.Pin(2), freq=1000, duty=0)

up = 1
count = 0

def breathing_light(t):
    global led, up, count
    if up == 1:
        count += 3
        led.duty(count)
        if count > 1000:
            up = 0
    if up == 0:
        count -= 3
        led.duty(count)
        if count == 3:
            up = 1

def keep_alive(t):
    global s
    s.sendto(b'ESP8266-msg: live',('1.1.1.1',2002))

def net_control(t):
    global s,led_timer,led
    try:
        data,addr = s.recvfrom(5)
    except:
        return
    print('From: %s:%s\tRecv: %s' % (addr[0],addr[1],data.decode()))
    if data in [b'on',b'start']:
        led_timer.init(period=10, mode=machine.Timer.PERIODIC, callback=breathing_light)
    elif data == b'stop':
        led_timer.deinit()
    elif data == b'off':
        led_timer.deinit()
        led.duty(0)

while wlan.isconnected():
    time.sleep_ms(200)

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setblocking(0)
s.bind(('0.0.0.0',2002))
keep_alive_timer.init(period=10000, mode=machine.Timer.PERIODIC, callback=keep_alive)
net_control_timer.init(period=10, mode=machine.Timer.PERIODIC, callback=net_control)
print('Running...')
```

将代码中的连接 WiFi 的`SSID`和`PASSWORD`换成实际的，`keep_alive` 函数主要是保持一条与公网主机的UDP通道，如果没有公网主机可以注释掉下面 `keep_alive_timer` 定时器的语句。程序启动了一个UDP端口，接受来自局域网主机的控制，如果存在公网主机，也可以在公网主机上向开发板发送数据。UDP套接字设置为了非阻塞模式，然后定时器每10毫秒会询问一次是否收到UDP数据，如果收到了 `on` 或者 `start` 数据，就启动呼吸灯的定时器，呼吸灯定时器的回掉函数将当前的状态保存在了全局变量中，执行一次更改亮度的操作后就退出了，等待下个10毫秒继续执行。这样多个定时器如果存在互相调用，就不会因为发生阻塞而影响其他定时器的运行了。

当ESP8266和公网建立通信后，那么可以玩的地方更多了，比如接收温湿度传感器的数据，然后监控环境温度并定期将温度上传到服务器，或者接入微信公众平台用微信来控制单片机，这些就又是一个很大的话题了。

## 附录

板子还在继续折腾中。。。等折腾出其他好玩的了继续更新

<!-- ### 参考资料

1. http://www.cnblogs.com/yafengabc/p/8680938.html
2. https://blog.csdn.net/qq_28877125/article/category/6792283/1
3. https://blog.csdn.net/xh870189248/article/details/77985541 -->
