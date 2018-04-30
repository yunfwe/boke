---
title: 构建基于Busybox的Nginx服务容器
date: 2016-04-22 10:12:00
categories: 
    - Docker
tags:
    - docker
    - nginx
    - busybox
    - overlay
---
## <font color='#5CACEE'>简介</font>
> 用docker容器进行打包服务非常方便 不需要考虑依赖的问题 只要把容器复制到其他有docker daemon的服务器就可以直接启动 并能很方便的利用Cgroup, Namespace技术实现资源控制和资源隔离
这篇文档以Nginx为例 其他的像redis mysql php等服务也是可以使用这个方法进行打包为最精简的 只包含必须依赖的服务容器

<!-- more -->


## <font color='#5CACEE'>环境</font>
> 系统是ubuntu server 15.10版 用ubuntu系统作为docker服务的载体 如果非ubuntu15.10发行版 尽量保证内核版本在3.18以上 Nginx是在CentOS 6.7的容器中编译的 之后在ubuntu上完成打包
在容器中编译Nginx只是我的个人习惯 不喜欢将主机环境乱安装一些不必要的包 保持清洁就好 编译什么的就交给容器去做吧

### <font color='#CDAA7D'>主机环境</font>

|      身份      |      系统     |       IP       |
| -------------  |:-------------:| --------------:|
| Docker服务   |   ubuntu 15.10  |   172.17.0.1   |
| Docker容器 |   CentOS 6.7  |   172.17.0.3   | 

### <font color='#CDAA7D'>软件环境</font>

|软件名称|版本号|下载地址|
|-|:-:|-:|
|Nginx|1.9.15|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.15.tar.gz)|
|Docker|1.9.1|[<font color='#AAAAAA'>点击下载</font>](http://mirrors.aliyun.com/docker-engine/apt/pool/main/d/docker-engine/docker-engine_1.9.1-0~wily_amd64.deb)|
|kernel|4.2.0|<font color='#AAAAAA'>系统自带</font>|

## <font color='#5CACEE'>步骤</font>
以下是打包Nginx服务容器的基本思路
+ 选用Busybox环境作为基础
+ 在CentOS 容器中编译Nginx
+ 将Nginx的运行依赖库和Nginx程序复制到主机环境
+ 部署到Busybox构建的rootfs中
+ 导入Docker 查看是否正常运行

### <font color='#CDAA7D'>构建Busybox最小容器</font>
> Busybox构建文档：[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/21/docker/Busybox构建最小容器)
构建完毕之后 busybox-1.24.2/_install 就是我们需要当作容器基础的rootfs了 将它复制到随便一个目录 留用

```bash
cp -rf busybox-1.24.2/_install/ rootfs
```

### <font color='#CDAA7D'>编译安装Nginx</font>
> Nginx的编译文档：[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/03/31/nginx/nginx编译安装)
只需要做到文档中make -j4 也就是编译完成就可以了 之后的安装步骤就不按照文档的走了

#### <font color='#DDA0DD'>安装nginx到非默认根</font>
```bash
make DESTDIR=/nginx install
```

通过DESTDIR更改安装Nginx的根位置 以/nginx目录作为nginx安装的根

    [root@localhost nginx-1.9.15]# ls /nginx/
    usr  var
    [root@localhost nginx-1.9.15]# tree /nginx/
    /nginx/
    ├── usr
    │   └── local
    │       └── nginx
    │           ├── conf
    │           │   ├── fastcgi.conf
    │           │   ├── fastcgi.conf.default
    │           │   ├── fastcgi_params
    │           │   ├── fastcgi_params.default
    │           │   ├── koi-utf
    │           │   ├── koi-win
    │           │   ├── mime.types

```bash
cd /nginx/
mkdir lib lib64                     # 创建两个依赖库文件夹
strip usr/local/nginx/sbin/nginx    # 裁剪nginx二进制的编译跟踪信息 缩减nginx体积
```

#### <font color='#DDA0DD'>复制Nginx运行依赖库</font>
>接下来查看nginx程序的所有依赖

    [root@localhost nginx]# ldd usr/local/nginx/sbin/nginx 
        linux-vdso.so.1 =>  (0x00007fff3caa3000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00007f9bc2ff8000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f9bc2ddb000)
        libcrypt.so.1 => /lib64/libcrypt.so.1 (0x00007f9bc2ba3000)
        libz.so.1 => /lib64/libz.so.1 (0x00007f9bc298d000)
        libc.so.6 => /lib64/libc.so.6 (0x00007f9bc25f9000)
        /lib64/ld-linux-x86-64.so.2 (0x0000561c3968f000)
        libfreebl3.so => /lib64/libfreebl3.so (0x00007f9bc23f5000)
将依赖复制到刚才创建的lib或者lib64目录中 如果这个依赖库在系统的lib目录下 那么就复制到lib目录中
```bash
cp /lib64/libdl.so.2 lib64/
cp /lib64/libpthread.so.0 lib64/
cp /lib64/libcrypt.so.1 lib64/
cp /lib64/libz.so.1 lib64/
cp /lib64/libc.so.6 lib64/
cp /lib64/ld-linux-x86-64.so.2 lib64/
cp /lib64/libfreebl3.so lib64/
```
 由于Nginx运行需要使用普通用户 所以需要读取passwd文件 读取解析passwd文件需要用到libnss_files.so.2这个库 所以也需要复制这个库到lib64中

```bash
cp /lib64/libnss_files.so.2 lib64/
```
如果在ubuntu上编译的话libnss_files.so.2位置在/lib/x86_64-linux-gnu/libnss_files.so.2
复制完成后lib64目录的内容应该如下所示：
        
    [root@localhost nginx]# ls lib64/
    ld-linux-x86-64.so.2  libc.so.6   libfreebl3.so      libpthread.so.0
    libcrypt.so.1         libdl.so.2  libnss_files.so.2  libz.so.1
        
### <font color='#CDAA7D'>打包Nginx服务容器</font>
> Nginx以及Nginx的运行依赖都已经放到/nginx目录中了 将这个目录移动到和刚才的rootfs同一目录下 然后再创建两个目录 留用

```bash
mkdir build target
```

#### <font color='#DDA0DD'>认识overlayFS</font>
> overlay是一种联合挂载的文件系统 可以将几个不同的目录挂载到一个目录中 然后将所有的文件展示出来 而且在挂载的目录中对文件的操作并不会影响到其他目录中实际的文件
同时 在新版本的docker中 overlay便是docker容器默认使用的存储驱动 但是overlay在内核大于3.18的版本中才被支持 所以尽量用使用较新内核版本的发行版来玩Docker
因为overlay的这些特性 用来辅助制作Nginx服务容器岂不是很方便 因为在挂载的目录中的操作并不会影响基层目录的文件 这样就算误删了文件 也是可以恢复的

现在看起来 应该是这个效果

    root@ubuntu:~# ls -lh
    total 16K
    drwxr-xr-x  9 root root 4.0K Apr 22 12:50 build     # overlay的工作目录
    drwxr-xr-x  6 root root 4.0K Apr 22 15:34 nginx     # 刚才安装的Nginx目录
    drwxr-xr-x 18 root root 4.0K Apr 22 11:52 rootfs    # busybox的目录
    drwxr-xr-x  1 root root 4.0K Apr 22 12:50 target    # 这个就是联合挂载到的目标目录
    
检查overlay驱动是否已经加载 否则加载overlay驱动
```bash
lsmod |grep overlay
modprobe overlay
```
如下所示 那么就可以使用overlay文件系统了 

    root@ubuntu:~# lsmod |grep overlay
    overlay                49152  1
    root@ubuntu:~# cat /proc/filesystems |grep overlay
    nodev	overlayfs
    nodev	overlay

用rootfs和nginx做基层 其中rootfs是第一层 如果还有其他目录 依次用冒号隔开 build做为overlay工作目录  /tmp是overlay必须的一个空目录 将lowerdir中的目录都挂载到target目录上
```bash
mount -t overlay overlay -o lowerdir=rootfs:nginx,upperdir=build,workdir=/tmp target/
```

接下来可以看到target目录中 rootfs和nginx目录中的内容同时出现在target目录中

    root@ubuntu:~# ls target/
    bin  etc   lib    linuxrc  mnt   root  sbin  tmp  var
    dev  home  lib64  media    proc  run   sys   usr
    root@ubuntu:~# ls target/bin/busybox 
    target/bin/busybox
    root@ubuntu:~# ls target/usr/local/nginx/sbin/nginx 
    target/usr/local/nginx/sbin/nginx
    
如果系统刚好不支持overlay文件系统的话 思想原理是相同的 直接将rootfs和nginx目录中的文件都复制到target中吧

#### <font color='#DDA0DD'>Chroot进行根切换</font>
> 接下来就是配置Nginx的运行环境了 这样才能保证Nginx打包为容器后能正常的运行
通过chroot工具切换当前根到target目录中 这也算文件系统隔离一种的方式

```bash
chroot target sh
```
可以看到 进入到了一个不同的shell中 ls / 竟然发现了linuxrc文件 现在已经将根切换到target目录中了

    / # ls /
    bin      etc      lib      linuxrc  mnt      root     sbin     tmp      var
    dev      home     lib64    media    proc     run      sys      usr

#### <font color='#DDA0DD'>根据执行Nginx的报错进行配置</font>
接下来的操作在这个根中进行 配置Nginx的运行环境 这些操作都是通过不断的执行nginx程序 查看nginx的报错总结的

```bash
adduser nginx                       # 添加nginx用户 
mkdir -p /var/tmp/nginx/client/     # 创建nginx运行需要的目录
mkdir -p /var/www/html              # 以后将使用这个路径作为Nginx网页根目录
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/            # 添加nginx软链接到环境变量中
ln -s /usr/local/nginx/conf/nginx.conf /etc/nginx.conf  # 添加配置文件软连接到/etc目录
echo '<h1>hello nginx</h1>' > /var/www/html/index.html  # 创建一个索引文件
```

再次运行nginx程序 这时候遇到了ginx: [emerg] open("/dev/null") failed的错误 原因是打不开这个设备文件 这个只能通过启动为一个Docker容器来解决了

    / # /usr/local/nginx/sbin/nginx 
    nginx: [emerg] open("/dev/null") failed (2: No such file or directory)

#### <font color='#DDA0DD'>修改Nginx配置文件</font>
剩下的就是修改nginx的配置文件了
    
```bash
vi /etc/nginx.conf
```

    第一行添加 daemon off; 让nginx前台运行 这个必须添加
    http{}中添加 autoindex on; 运行目录索引 可以根据实际情况添加
    http{
      server{
        location / {
            root   /var/www/html;           # root改为/var/www/html 可以根据实际情况更改
            index  index.html index.htm;
        }
      }
    }

#### <font color='#DDA0DD'>将目录打包为Docker容器</font>
输入exit或者键入 Ctrl+d 就可以退出chroot 回到正常的根中了 接下来 将数据打包为Docker容器 可以看到 大小仅仅8M
```bash
cd target/
tar -cf /dev/stdout *|docker import - nginx:1.9.15
```

    root@ubuntu:~/target# docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    nginx               1.9.15              99089cedcc48        3 seconds ago       8.071 MB

#### <font color='#DDA0DD'>启动容器 检查是否成功</font>
然后后台启动这个容器 并且查看容器IP 通过curl命令检查nginx是否正常运行 可以看到 成功返回 hello nginx
```bash
docker run -d --name nginx nginx:1.9.15 nginx
docker inspect --format '{{.NetworkSettings.IPAddress}}' nginx
```
    root@ubuntu:~/target# docker run -d --name nginx nginx:1.9.15 nginx
    0db0d45152948339fb0c9a23e8dfba6798c650e24075d725ba2d3021eb3b801b
    root@ubuntu:~/target# docker inspect --format '{{.NetworkSettings.IPAddress}}' nginx
    172.17.0.8
    root@ubuntu:~/target# curl 172.17.0.8
    <h1>hello nginx</h1>
    root@ubuntu:~/target#

这样 一个非常小 但是可以提供完整功能的Nginx服务容器就打包完成了 
#### <font color='#DDA0DD'>overlayFS文件误删的恢复</font>
如果在制作这个容器的过程中 不幸误删了target目录中的文件 还记的build这个文件吗
```bash
rm -rf linuxrc
```
    root@ubuntu:~/target# ls -l ../build/linuxrc 
    c--------- 1 root root 0, 0 Apr 22 17:28 ../build/linuxrc

可以看到 build目录中出现了一个主次设备号都为0的字符设备 只要删除了这个字符设备 文件就恢复了
```bash
rm -rf ../build/linuxrc
```
    root@ubuntu:~/target# ls
    bin  etc   lib    linuxrc  mnt   root  sbin  tmp  var
    dev  home  lib64  media    proc  run   sys   usr

    
## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>将Nginx容器镜像保存为文件</font>
> 如果想把这个容器共享给其他人使用 除了使用push到仓库中 还可以直接通过文件的方式共享

#### <font color='#DDA0DD'>配置一个默认启动命令</font>
> 导入这个Nginx服务容器之后 每次启动都需要手动输入nginx命令 这样显的比较麻烦 可以通过Dockerfile的方式给这个容器配置一个默认的启动命令

```bash
vim Dockerfile
```

    键入以下内容：
    root@ubuntu:~# cat Dockerfile 
    FROM nginx:1.9.15
    CMD nginx
    
    nginx就是启动的命令 如果命令还带有参数 可以直接写出 例如 CMD nginx -s reload
 
```bash
docker build -t nginx .         # 给新镜像配置一个标签 记得不要忘记了最后的 . 
```

    root@ubuntu:~# docker build -t nginx .
    Sending build context to Docker daemon 25.09 MB
    Step 1 : FROM nginx:1.9.15
     ---> 99089cedcc48
    Step 2 : CMD nginx
     ---> Running in 12b1a81d553c
     ---> 114ba21e8f1c
    Removing intermediate container 12b1a81d553c
    Successfully built 114ba21e8f1c
    root@ubuntu:~# docker run -d nginx:latest
    0f3f39dd3aea5a16b10a470ffecca716b31d0deab5420b07ee86bd1180bc2256

可以看到 启动这个新容器已经不需要输入nginx命令了 其实还有一个方法可以更改默认启动命令 通过直接修改镜像的配置文件
可以看到 nginx:1.9.15镜像的ID是99089cedcc48 这只是完整ID的一部分 配置信息保存在/var/lib/docker/graph中

    root@ubuntu:~# docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    nginx               1.9.15              99089cedcc48        48 minutes ago      8.071 MB

```bash
cd /var/lib/docker/graph
cd 99089cedcc48*
vim json
```
    
这时就打开了这个镜像的配置文件 Cmd字段就是默认命令 还可以顺便改下comment信息

    "comment":"nginx 1.9.15",       # comment字段改为你想表达的信息
    "Cmd":["yunfwe"],               # Cmd字段有两个 第一个是作者信息
    "Cmd":["nginx"],                # 第二个才是启动命令
    
    如果运行命令有其他参数的话 用逗号隔开 例如 "Cmd":["nginx","-s","reload"],
    这样就相当于 nginx -s reload 了
    
接下来使用docker history nginx:1.9.11 查看信息

    可以看到 CREATED BY 还有 COMMENT 是自己写的信息了
    root@ubuntu:~# docker history 99089cedcc48
    IMAGE               CREATED             CREATED BY          SIZE                COMMENT
    99089cedcc48        58 minutes ago      yunfwe              8.071 MB           nginx 1.9.15
    
    顺便可以看到运行命令也已经是nginx了
    root@ubuntu:~# docker inspect --format {{.Config.Cmd}} nginx:1.9.15
    {[nginx]}

这两种修改默认启动命令方法的一个重要区别是 第二种在原本的镜像上修改 是不会产生新的层的 而用Dockerfile修改 相当于新建了一个层 这个层提供了默认启动命令 不信可以使用docker history验证一下

#### <font color='#DDA0DD'>保存为文件</font>
> 默认docker导出的是个tar归档 这里直接将归档压缩为gz包 文件命名规则是 
REPOSITORY_TAG-Type.tar.gz 
其中的Type是标识这个文件是由镜像保存的还是已经生成的容器导出的

```bash
docker save nginx:1.9.15 |gzip > nginx_1.9.15-image.tar.gz
```

要恢复的话也很简单 docker支持直接从gz压缩包中恢复 
导入新的镜像 这个镜像的标签可能会丢失 但是id号还在 给这个id好重新打个标签

```bash
docker load < nginx_1.9.15-image.tar.gz
docker tag 99089cedcc48 nginx:1.9.15
```



