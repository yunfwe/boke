---
title: Python实现日志备份压缩
date: 2016-04-13 10:12:00
categories: 
    - Python
tags:
    - 日志处理
    - bzip2压缩
---
## <font color='#5CACEE'>简介</font>
> 系统日志 Nginx访问日志等日志文件 在无人管理的情况下会越来越大 如果不对日志进行处理 会对以后的日志查看 磁盘管理等产生影响
这个脚本是用Python实现的对指定日志文件进行备份 压缩 并清空已经备份后的源文件

<!-- more -->




	
## <font color='#5CACEE'>代码：</font>
> 代码下载地址：[点击下载](\2016\04\13\python\Python实现日志备份压缩\logarch.py)

```python
#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
import time
from sys import argv
from bz2 import compress

def bz2_compress(filepath):
    filename = os.path.basename(filepath)           # 获取目标日志的文件名
    now = time.strftime('-%Y%m%d%H%M%S')            # 转换当前时间为一种时间格式
    dstdir = filepath+'_bak/'                       # 备份目标所在的目录
    dstfile = dstdir+filename+now+'.bz2'            # 备份目标的文件名
    
    if not os.path.exists(dstdir):                  # 如果是第一次备份文件 就创建文件夹
        os.mkdir(dstdir)
        
    if os.path.exists(dstfile):                     # 如果文件重名 更改文件名
        dstfile = dstdir+filename+now+'-1'+'.bz2'
        
    src = open(filepath,'r')                        # 打开日志文件
    dst = open(dstfile,'a')                         # 创建目标文件
    while True:                                     # 死循环读取日志 直到完毕为止
        data = src.read(3145728)                    # 每次读取3M大小的日志
        if src.tell() == os.path.getsize(filepath): # 判断文件是否读取完毕
            open(filepath,'w')                      # 清空文件操作
            src.close()                             # 关闭日志文件
            dst.write(compress(data))               # 将最后读取的数据压缩并写入备份文件
            break                                   # 循环终止
        dst.write(compress(data))                   # 将每次读取的数据压缩并写入备份文件

if __name__ == '__main__':
    bz2_compress(argv[1])                           # 调用处理函数
```

## <font color='#5CACEE'>附录</font>
> 注意：脚本会在备份完日志后将日志源文件清空！如果想实现每次都完整备份日志 将open(filepath,'w')语句注释或者删除即可

    只需要将要处理的日志作为脚本第一个参数即可 这样可以很方便的和crontab结合进行设定任务计划
    脚本执行后的效果应该如下所示：
    
    [root@centos ~]# ls
    dmesg  logarch.py
    [root@centos ~]# /root/logarch.py /root/dmesg 
    [root@centos ~]# /root/logarch.py /root/dmesg 
    [root@centos ~]# tree
    .
    ├── dmesg
    ├── dmesg_bak
    │   ├── dmesg-20160413111953.bz2
    │   └── dmesg-20160413111954.bz2
    └── logarch.py

    1 directory, 4 files