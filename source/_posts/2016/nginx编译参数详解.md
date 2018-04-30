---
title: Nginx编译参数详解
date: 2016-05-16 11:25:49
categories: 
    - Nginx
tags:
    - nginx
---
## <font color='#5CACEE'>简介</font>
> 主要介绍Nginx编译安装的可选项 以后对Nginx进行升级 或者功能拓展都可以查阅 查找合适的模块
<!-- more -->

## <font color='#5CACEE'>环境</font>

|软件名称|版本号|下载地址|
|-|:-:|-:|
|nginx|1.9.13|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.13.tar.gz)|

## <font color='#5CACEE'>步骤</font>

```bash
tar xf nginx-1.9.13.tar.gz
cd nginx-1.9.13
./configure --help
```

      --help                             打印帮助信息

      --prefix=PATH                      Nginx安装路径 默认 /usr/local/nginx
      --sbin-path=PATH                   Nginx可执行文件安装路径 默认 <prefix>/sbin/nginx
      --modules-path=PATH                Nginx动态模块安装路径 默认 <prefix>/modules
      --conf-path=PATH                   Nginx配置文件的路径 默认 <prefix>/conf/nginx.conf
      --error-log-path=PATH              nginx.conf中没有指定的情况下 错误日志默认路径 <prefix>/logs/error.log
      --pid-path=PATH                    nginx.conf中没有指定的情况下 pid文件默认路径 <prefix>/logs/nginx.pid
      --lock-path=PATH                   nginx.lock文件的路径

      --user=USER                        nginx.conf中没有指定的情况下 Nginx使用的用户 默认 nobody
      --group=GROUP                      nginx.conf中没有指定的情况下 Nginx使用的用户组 默认 nobody

      --build=NAME                       指定编译的名字
      --builddir=DIR                     指定编译的目录

      --with-select_module               允许select模式 根据configure检测 如果没有更好的 select将是默认方式
      --without-select_module            不允许select模式
      --with-poll_module                 允许poll模式
      --without-poll_module              不允许poll模式

      --with-threads                     允许线程池支持

      --with-file-aio                    允许file aio支持 (文件异步读写模型)
      --with-ipv6                        启动 ipv6 支持

      --with-http_ssl_module             提供HTTPS支持
      --with-http_v2_module              支持HTTP2协议
      --with-http_realip_module          获取客户机真实IP模块 
      --with-http_addition_module        添加在响应之前或之后追加内容的模块
      --with-http_xslt_module            通过XSLT模板转换XML应答
      --with-http_xslt_module=dynamic    通过XSLT模板转换XML应答 编译为动态模块
      --with-http_image_filter_module    传输JPEG/GIF/PNG 图片的一个过滤器
      --with-http_image_filter_module=dynamic       同上 编译为动态模块
      --with-http_geoip_module           获取IP所属地的模块
      --with-http_geoip_module=dynamic   获取IP所属地的模块 编译为动态模块
      --with-http_sub_module             允许替换响应中的一些文本
      --with-http_dav_module             开启WebDAV扩展动作模块
      --with-http_flv_module             提供flv播放服务的模块
      --with-http_mp4_module             提供mp4播放服务的模块
      --with-http_gunzip_module          提供gunzip压缩的模块
      --with-http_gzip_static_module     在线实时压缩输出数据流 能有效节省带宽
      --with-http_auth_request_module    客户子请求的认证基础
      --with-http_random_index_module    随机目录索引
      --with-http_secure_link_module     检查客户请求链接 可以用于下载防盗链
      --with-http_degradation_module     允许在内存不足的情况下返回204或444码
      --with-http_slice_module           切片模块
      --with-http_stub_status_module     Nginx工作状态统计模块

      --without-http_charset_module      禁用重新编码web页面模块
      --without-http_gzip_module         禁用在线实时压缩输出数据流
      --without-http_ssi_module          禁用服务器端包含模块
      --without-http_userid_module       禁用用户ID模块 该模块为用户通过cookie验证身份
      --without-http_access_module       禁用访问模块 对于指定的IP段 允许访问配置
      --without-http_auth_basic_module   禁用基本的认证模块
      --without-http_autoindex_module    禁用目录自动索引模块
      --without-http_geo_module          禁用Geo模块
      --without-http_map_module          禁用Map模块 该模块允许你声明map区段
      --without-http_split_clients_module 禁用基于某些条件将客户端分类模块
      --without-http_referer_module      禁用 过滤请求 拒绝报头中Referer值不正确的请求的模块
      --without-http_rewrite_module      禁用url重写模块
      --without-http_proxy_module        禁用http代理模块
      --without-http_fastcgi_module      禁用fastcgi模块
      --without-http_uwsgi_module        禁用uwsgi模块
      --without-http_scgi_module         禁用scgi模块
      --without-http_memcached_module    禁用Memcached模块
      --without-http_limit_conn_module   禁用连接限制模块
      --without-http_limit_req_module    禁用限制用户连接总和的模块
      --without-http_empty_gif_module    禁用empty_gif模块
      --without-http_browser_module      禁用Browser模块
      --without-http_upstream_hash_module    以下是禁用负载均衡相关的一些模块
      --without-http_upstream_ip_hash_module
      --without-http_upstream_least_conn_module
      --without-http_upstream_keepalive_module
      --without-http_upstream_zone_module

      --with-http_perl_module            通过此模块 nginx可以直接使用perl
      --with-http_perl_module=dynamic    编译为动态模块
      --with-perl_modules_path=PATH      设定模块路径
      --with-perl=PATH                   设定perl库文件路径

      --http-log-path=PATH               设定http访问日志路径
      --http-client-body-temp-path=PATH  设定http客户端请求临时文件路径
      --http-proxy-temp-path=PATH        设定http代理临时文件路径
      --http-fastcgi-temp-path=PATH      设定http fastcgi临时文件路径
      --http-uwsgi-temp-path=PATH        设定http uwsgi临时文件路径
      --http-scgi-temp-path=PATH         设定http scgi临时文件路径

      --without-http                     禁用http server功能
      --without-http-cache               禁用http cache功能

      --with-mail                        启用POP3/IMAP4/SMTP代理模块支持
      --with-mail=dynamic                编译为动态模块
      --with-mail_ssl_module             启用加密的邮箱代理模块
      --without-mail_pop3_module         禁用pop3模块
      --without-mail_imap_module         禁用imap模块
      --without-mail_smtp_module         禁用smtp模块

      --with-stream                      启动tcp/udp代理模块
      --with-stream=dynamic              编译为动态模块
      --with-stream_ssl_module           启动加密的tcp/udp代理模块
      --without-stream_limit_conn_module 
      --without-stream_access_module     
      --without-stream_upstream_hash_module
      --without-stream_upstream_least_conn_module
      --without-stream_upstream_zone_module

      --with-google_perftools_module     启用google_perftools模块 优化高并发性能
      --with-cpp_test_module             启用ngx_cpp_test_module支持

      --add-module=PATH                  启用拓展模块 指定路径
      --add-dynamic-module=PATH          启用动态拓展模块

      --with-cc=PATH                     指定c编译器路径
      --with-cpp=PATH                    指定C预处理路径
      --with-cc-opt=OPTIONS              设置C编译器参数
      --with-ld-opt=OPTIONS              设置链接文件参数
      --with-cpu-opt=CPU                 指定编译的CPU 可选值:
                                         pentium, pentiumpro, pentium3, pentium4,
                                         athlon, opteron, sparc32, sparc64, ppc64

      --without-pcre                     禁用pcre库 (正则表达式)
      --with-pcre                        启用pcre库
      --with-pcre=DIR                    指定pcre库文件目录
      --with-pcre-opt=OPTIONS            在编译时为pcre库设置附加参数
      --with-pcre-jit                    构建pcre提供jit编译支持

      --with-md5=DIR                     指向md5库文件目录
      --with-md5-opt=OPTIONS             在编译时为md5库设置附加参数
      --with-md5-asm                     使用md5汇编源

      --with-sha1=DIR                    指向sha1库目录
      --with-sha1-opt=OPTIONS            在编译时为sha1库设置附加参数
      --with-sha1-asm                    使用sha1汇编源

      --with-zlib=DIR                    指向zlib库目录
      --with-zlib-opt=OPTIONS            在编译时为zlib设置附加参数
      --with-zlib-asm=CPU                为指定的CPU使用zlib汇编源进行优化

      --with-libatomic                   为原子内存的更新操作的实现提供一个架构
      --with-libatomic=DIR               指向libatomic_ops安装目录

      --with-openssl=DIR                 指向openssl源码目录
      --with-openssl-opt=OPTIONS         在编译时为openssl设置附加参数

      --with-debug                       启用debug信息
      
## <font color='#5CACEE'>附录</font>
> 只需要在编译nginx时添加相应的选项就可以了 [<font color='#AAAAAA'>Nginx详细编译安装教程</font>](/2016/03/31/nginx/nginx编译安装)