---
title: Python3编译安装
date: 2017-12-21
categories: 
    - Python
tags:
    - Python
photos:
    - /uploads/photos/kd93hf8hae.jpg
---

## <font color='#5CACEE'>简介</font>
>Python是一种面向对象的解释型计算机程序设计语言，由荷兰人Guido van Rossum于1989年发明，第一个公开发行版发行于1991年。Python是纯粹的自由软件， 源代码和解释器CPython遵循GPL协议。
Python的用处如今已经非常强大，人工智能、数据处理、Web后端、爬虫、运维等都能见到Python的身影。

<!-- more -->


## <font color='#5CACEE'>环境</font>

### 系统环境
> 在 CentoOS 6.8 上编译的

### 软件环境
|源码包|版本|下载地址|
|-|-|-|
|Python|3.6.4|[点击下载](https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tar.xz)|

## 步骤

### 安装依赖
> Python的某些模块可以按需编译 比如tkinter sqlite3等 如果不安装它的devel包 Python编译过程中将忽略此模块

```
yum -y install make gcc gcc-c++ zlib-devel bzip2-devel gdbm-devel \
xz-devel tk-devel readline-devel sqlite-devel ncurses-devel openssl-devel
```

### 开始编译
> 解压源码包后进入源码目录


```
./configure --enable-optimizations --prefix=/usr/local/python3 --enable-shared
sed -i 's/test.regrtest/this/g' Makefile        # 此步骤屏蔽单元测试（耗时太长）
make -j4
```

在make的过程中 如果有标准库中的模块依赖没有找到 标准输出会有显示 内容可能如下

    Python build finished successfully!
    The necessary bits to build these optional modules were not found:
    _bz2                  _curses               _curses_panel      
    _dbm                  _gdbm                 _lzma              
    _sqlite3              _ssl                  _tkinter           
    readline              zlib                                     
    To find the necessary bits, look in setup.py in detect_modules() for the module's name.

安装好相应的模块的devel包后 不需要重新configure 重新make即可

### 安装使用
```
make install 
echo 'export PATH=$PATH:/usr/local/python3/bin' > /etc/profile.d/python3.sh
echo '/usr/local/python3/lib' > /etc/ld.so.conf.d/python3.conf
ldconfig
source /etc/profile.d/python3.sh
```

### 卸载
> 删除安装目录就可以了

```
rm -rf /usr/local/python3/
rm -rf /etc/profile.d/python3.sh
rm -rf /etc/ld.so.conf.d/python3.conf
```

## 附录
如果不提前把Python的依赖安装好 虽然可以编译成功 但是会缺少不少的模块