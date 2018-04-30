---
title: Nginx服务控制
date: 2016-05-16 14:30:10
categories: 
    - Nginx
tags:
    - nginx
---
## <font color='#5CACEE'>简介</font>
> Nginx可以通过向主进程发送信号的方式进行控制 甚至可以完成在不停止服务的情况下 对程序进行重启 升级 甚至回滚操作
<!-- more -->


## <font color='#5CACEE'>环境</font>

|软件名称|版本号|下载地址|
|---------|:-----:|------:|
|nginx|1.9.13|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.13.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>启动Nginx</font>
> Nginx的启动很简单 如果配置了环境变量 可以直接通过nginx命令启动 也可以通过绝对路径启动

```bash
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
```

参数 "-c" 指定了配置文件的路径 如果不使用 "-c" 参数的话 nginx 会默认加载编译选项 **-\-conf-path=PATH** 中指定的路径

### <font color='#CDAA7D'>关闭Nginx</font>
>在早期 Nginx的关闭一般通过发送系统信号给Nginx主程序的方式来停止Nginx 之后的版本 Nginx添加了 "-s" 参数可以对Nginx主程序进行控制 通过信号的方式 需要先找到Nginx master进程的PID号 或者通过查看 nginx.pid文件来获取Nginx主进程的PID
Nginx能处理的停止信号有两种 一种是 QUIT  当Nginx接受到这个信号时 会处理完当前所有的请求 并有序的关闭服务 
另一种是 TERM 或 INT  Nginx收到这两种信号 会尽可能快的停止web服务 不保证处理完所有请求
当然 还有一种Nginx不可控的信号 KILL  会强制杀死Nginx的进程

```bash
PID=`ps aux |grep nginx |grep master |awk '{print $2}'`
PID=`cat /var/run/nginx/nginx.pid`
echo $PID
```

通过以上方法 即可获取Nginx主程序的PID号了 接下来就是通过kill命令向Nginx发送信号

```bash
kill -QUIT $PID             # 安全从容的退出
kill -INT $PID              # 尽可能快的退出 
kill $PID                   # 尽可能快的退出 因为默认kill发送的是TERM信号
kill -KILL $PID             # 强制杀死
```

较高版本的Nginx的 "-s" 参数也可以对Nginx进行控制 Nginx会读取nginx.pid文件来获取master进程的PID 然后向这个PID发送信号

```bash
/usr/local/nginx/sbin/nginx -s quit         # 安全从容的退出 实质上还是发送QUIT信号
/usr/local/nginx/sbin/nginx -s stop         # 尽可能快的退出 实质上发送TREM或INT信号
```

### <font color='#CDAA7D'>Nginx平滑重启</font>
> 在Nginx运行过程中 如果修改了配置文件 但是又不想停止Nginx再重启让配置文件生效 也可以通过发送信号的方式 通知Nginx重新读取配置文件

```bash
/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
```
修改nginx配置文件后 可以通过 -t 参数对配置文件进行检测 如果不通过 -c 指定配置文件 会检查默认的配置文件 当检查通过 就可以通知Nginx主进程重新读取了

```bash
kill -HUP $PID              # 通过HUP信号 可以通知Nginx主进程重新读取配置文件
/usr/local/nginx/sbin/nginx -s reload       # 同理 reload也是向Nginx主进程发送HUP信号
```

Nginx在收到HUP信号时 回先解析配置文件 如果解析成功 就应用新的配置文件 之后 Nginx运行新的工作进程 并从容关闭旧的工作进程 等所有的请求处理完毕后 旧的工作进程被关闭 

### <font color='#CDAA7D'>Nginx平滑升级</font>
> 如果想给正在运行中的Nginx升级版本 或者添加/删除服务模块 可以在服务不间断的情况下 对Nginx进行升级

1. 备份原本的nginx二进制 为了意外恢复 并使用新的二进制程序代替了以前的位置
2. 向Nginx主程序发送USR2信号
3. 旧版的Nginx主程序将nginx.pid重命名为nginx.pid.oldbin 然后执行新版本的Nginx可执行程序 将新的PID写入nginx.pid文件
4. 当前新旧两个Nginx进程会同时提供服务 还需要手动关闭旧Nginx主进程 仅保留新的Nginx主进程

```bash
mv /usr/local/nginx/sbin/{nginx,nginx.old}
cp objs/nginx /usr/local/nginx/sbin/nginx       
# 默认nginx编译后在源码包的objs目录中 也可以直接make install覆盖安装
kill -USR2 $PID             # 向Nginx主进程的PID号发送USR2信号
```

现在可以看到 新旧两个Nginx主进程在同时提供服务 发送 WINCH 信号 可以通知Nginx主进程从容的关闭工作进程(worker process) 这时将只剩下新的Nginx的工作进程提供服务
```bash
kill -WINCH $PID
```

如果一段时间 新Nginx工作正常 就可以向旧版Nginx发送退出信号 结束掉旧Nginx的主进程了 旧进程退出后还会移除nginx.pid.oldbin文件
```bash
kill $OLD_PID
```

如果运行一段时间 发现并不是理想中的那种工作状态 那么可以发送 HUP 信号向旧Nginx主进程 让其重新打开工作进程 接着向新Nginx主进程发送 QUIT 信号 从容关闭主进程 最后恢复旧nginx的二进制文件
```bash
kill -HUP $OLD_PID
kill -QUIT $PID
mv /usr/local/nginx/sbin/{nginx.old,nginx}      # 不要忘记恢复旧的二进制文件
```

### <font color='#CDAA7D'>Nginx日志控制</font>
> Nginx的访问日志会记录客户端的每次一请求 所以在用户量大的情况下 会很容易变得很大 也可以通过发送信号的方式进行控制日志 而不用关闭Nginx服务

Nginx主进程启动后 便会一直打开access.log日志文件 当服务器被长时间的访问 这个日志会越来越大 不利于日后的清理 由于这个日志文件被Nginx一直处于打开的状态 冒然删除这个日志文件并不是个很好的方法 而且删除后 Nginx还会向该文件的inode节点写入日志数据 因此 文件即使被删除 文件系统空间也不会释放 这样就只有重启Nginx才能释放空间并读写新的日志了

因此 管理access.log的方式不应该用直接删除文件的方式 如果对日志内容不在意 可以直接清空文件
```bash
echo > /usr/local/nginx/logs/access.log
```

还有一个更好的方式 就是让Nginx重新打开一个新的文件进行读取 先将原来的access.log重命名 因为重命名并不会更改文件的inode节点 所以不会影响Nginx程序的日志写入 接着发送 USR1 信号 Nginx主程序将打开一个新的access.log文件开始写入
```bash
kill -USR1 $PID
/usr/local/nginx/sbin/nginx -s reopen           # 重新打开日志文件 和 USR1 同理
```

## <font color='#5CACEE'>附录</font>
> Nginx支持的信号汇总

|信号类型|功能|
|--------|:-----|
|TREM 或 INT|快速关闭Nginx服务|
|QUIT|从容关闭Nginx服务|
|HUP|通知Nginx重新读取配置文件|
|USR1|重新打开日志文件 常用于日志分割|
|USR2|平滑升级可执行程序|
|WINCH|从容关闭工作进程|
    
