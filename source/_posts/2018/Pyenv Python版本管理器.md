---
title: Pyenv Python版本管理器
date: 2018-10-08 12:50:00
categories: 
    - Python
tags:
    - python
photos:
    - /uploads/photos/k07fw96w4pylhjge.jpg
---

<!-- created: 2018-10-20 12:50:00 -->

## 简介
> Node.js 有一个非常好用的版本管理器叫 `nvm`，可以很方便的安装和管理多种 node.js 的版本，于是开始寻找 Python 是否也存在类似的工具，这样可以方便的切换 Python2 和 Python3 的环境，以及 Python 发布新版本后可以迅速的体验一番，而且还不会对当前系统环境照成影响。所幸 遇到了 pyenv 这个工具。
> 项目主页：https://github.com/pyenv/pyenv
<!-- more -->

## 安装

这里在 ubuntu 16.04 上安装 pyenv，其他发行版上安装方法也都大同小异。

### 安装 pyenv

pyenv 默认会安装在 `~/.pyenv`，可以通过设置环境变量 `PYENV_ROOT` 来改变这个目录。如果是普通用户，就最好将 pyenv 安装到自己家目录了。

**安装依赖**
```bash
apt-get update
apt-get install curl git
```

**使用自动化脚本安装pyenv**
```bash
export PYENV_ROOT="/usr/local/pyenv"
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
```

**修改 .bashrc 使其自动加载 pyenv**

```bash
echo 'export PYENV_ROOT="/usr/local/pyenv"' >> ~/.bashrc
echo 'export PATH="/usr/local/pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
exec bash
```

这时可以检查 `pyenv` 命令是否可用了。

    root@localhost:~# pyenv
    pyenv 1.2.7
    Usage: pyenv <command> [<args>]

    Some useful pyenv commands are:
        commands    List all available pyenv commands
        local       Set or show the local application-specific Python version
        global      Set or show the global Python version
        shell       Set or show the shell-specific Python version
        install     Install a Python version using python-build
        uninstall   Uninstall a specific Python version
        rehash      Rehash pyenv shims (run this after installing executables)
        version     Show the current Python version and its origin
        versions    List all Python versions available to pyenv
        which       Display the full path to an executable
        whence      List all Python versions that contain the given executable

    See `pyenv help <command>' for information on a specific command.
    For full documentation, see: https://github.com/pyenv/pyenv#readme

## 使用

### 查看可以安装的 Python 环境

**命令：** `pyenv install --list`

这条命令会列出当前可用的所有Python环境，可以看到可选的环境官方的加上第三方的是非常多的

### 安装目标 Python 环境

**命令：** `pyenv install ${version}`

只需要将 `${version}` 写成上面列出的所有可选的 Python 环境即可，Python 的源码包会存放到 `${PYENV_ROOT}` 目录下的 `cache` 目录下(如果没有需要手动创建)，默认从官方镜像站下载，如果速度比较慢，可以选择手动从国内镜像站下载，手动将源码包放入这个目录，然后再执行安装命令。

```bash
# 首先安装编译Python需要的开发包和开发工具
apt-get install zlib1g-dev libbz2-dev libssl-dev libncurses5-dev  \
libsqlite3-dev libreadline-dev tk-dev libgdbm-dev libdb-dev \
libpcap-dev xz-utils libexpat-dev gcc make

# 手动放置源码包的方式
# mkdir ${PYENV_ROOT}/cache
# cd ${PYENV_ROOT}/cache
# wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tar.xz

# 执行编译安装
pyenv install 3.6.6
```

如果需要将 Python 编译为动态共享库的方式，则需要将编译参数通过环境变量传给 pyenv

```bash
env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.6
```

**安装完成**

    root@localhost:~# env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.6
    Installing Python-3.6.6...
    Installed Python-3.6.6 to /usr/local/pyenv/versions/3.6.6


### 列出当前版本

**命令：** `pyenv version` 查看当前版本

    root@localhost:~# pyenv version
    system (set by /usr/local/pyenv/version)


**命令：** `pyenv versions` 查看当前可用版本

    root@localhost:~# pyenv versions
    * system (set by /usr/local/pyenv/version)
      3.6.6

### 切换当前 shell 会话的 Python 版本

**命令：** `pyenv shell 3.6.6`

    root@localhost:~# python -V
    Python 2.7.12
    root@localhost:~# pyenv shell 3.6.6
    root@localhost:~# python -V
    Python 3.6.6

这个命令并不会影响其他会话里的 Python 版本，而且在关闭这个 shell 会话后，设置就消失了，所以只是临时的。

### 指定全局的 Python 版本

**命令：** `pyenv global 3.6.6`

这时全局的 Python 版本都变成了指定的 `3.6.6`，如果想设置回系统默认的版本可以使用 `pyenv global system`

### 设置某个目录使用的 Python 版本

**命令：** `pyenv local 3.6.6`

这个目录就比较有意思了，当进入某个目录后，然后在这个目录下执行这个命令，那么以后只要切换到这个目录，那么使用的 Python 版本就是指定的这个版本了。

如果想取消这个设置，可以删除这个目录下的 `.python-version` 文件

### 卸载已安装的 Python 版本

**命令：** `pyenv uninstall 3.6.6`

辛辛苦苦安装上，我就不测试执行了。

## 附录

再配合上 Python 的虚拟环境，简直强无敌啊，更重要的是，非 root 用户也可以随意的安装配置不同的 Python 版本了。