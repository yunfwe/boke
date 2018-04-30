---
title: Nginx配置文件详解
date: 2016-05-17 10:36:56
categories: 
    - Nginx
tags:
    - nginx
---
## <font color='#5CACEE'>简介</font>
> Nginx丰富的功能实现 都是通过配置文件完成的 Nginx配置文件的结构非常简单易懂 而且又十分强大 下面就是Nginx配置文件的结构说明 以及一些常用配置项的解释
<!-- more -->




	
## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|nginx|1.9.13|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.13.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>Nginx配置文件结构</font>
> Nginx配置文件是一个纯文本文件 默认位置位于 <prefix>/conf/nginx.conf 配置文件内容是以block的形式组织 每个block用 {} 表示 block内可以包含block 其关系如下:

    +--------------------------------+
    |              main              |      main 全局配置 pid文件位置 运行用户等配置
    |    +-----------------------+   |
    |    |        events         |   |      events 设定Nginx工作模式 比如epoll select等
    |    +-----------------------+   |
    |  +---------------------------+ |
    |  |            HTTP           | |      HTTP核心模块
    |  | +-----------------------+ | |
    |  | |         server        | | |      server 每一个server都可以视为一个虚拟主机
    |  | | +-------------------+ | | |
    |  | | |      location     | | | |      location 匹配网页位置
    |  | | +-------------------+ | | |
    |  | | +-------------------+ | | |
    |  | | |      location     | | | |      一个server可以存在多个不同的location
    |  | | +-------------------+ | | |
    |  | +-----------------------+ | |
    |  | +-----------------------+ | |
    |  | |         server        | | |      多个server就可以启动多个虚拟主机
    |  | +-----------------------+ | |
    |  +---------------------------+ |
    +--------------------------------+


### <font color='#CDAA7D'>Nginx配置文件参数</font>

    #user  nobody;                          # 默认运行用户 编译时未指定的话为nobody
    worker_processes  4;                    # Nginx主进程要开启多少个工作进程 一般为当前CPU核心数
    worker_cpu_affinity 0001 0010 0100 1000;   # 将每个进程绑定到CPU的每个核心上 可以略提高性能

    #error_log  logs/error.log;             # 错误日志的位置 默认是安装目录下的logs/error.log
    #error_log  logs/error.log  notice;     # 可以在日志后面添加纪录级别 
    #error_log  logs/error.log  info;       # 可选项有: [debug|info|notice|warn|error|crit]

    #pid        logs/nginx.pid;             # pid文件路径 nginx -s 控制服务就是从这里读取主进程的PID
    worker_rlimit_nofile 65535;             # 指定文件描述符数量 增大可以让Nginx处理更多连接
                                        # 还需要增大系统允许进程打开文件描述符的上限 ulimit -n 65536

    events {
        use epoll;                          # Nginx默认会选择最适合的工作模式 linux一般为epoll
                                            # 支持:[select | poll | kqueue | epoll | /dev/poll]
        worker_connections  65535;          # Nginx每个工作进程最大的连接数
    }                                       # 最大客户连接数为 worker_processes * worker_connections 


    http {
        include       mime.types;         # 其他的block配置 可以通过include导入 这样可以很方便管理配置
        default_type  application/octet-stream; # 响应类型未定义content-type时 文件默认类型为二进制流 
                                                # mime.types中包含文件扩展名与文件类型映射表

        #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
        #                  '$status $body_bytes_sent "$http_referer" '
        #                  '"$http_user_agent" "$http_x_forwarded_for"';
                                          # 定义access.log日志的格式 main为格式名称 

        access_log  logs/access.log  main;      # 默认access.log的位置 以及使用main中定义的格式
        
        client_max_body_size     20m;           # 设置允许客户上传大小
        client_header_buffer_size   32k;        # 客户端请求 header_buffer大小 默认1k
        large_client_header_buffers  4 32k;     # 指定客户请求header_buffer的缓存最大数量和大小
        
        sendfile        on;                     # 开启高效的文件传输模式
        tcp_nopush      on;                     # 开启tcp_nopush和tcp_nodelay用于防止网络阻塞
        tcp_nodelay     on;

        #keepalive_timeout  0;
        keepalive_timeout  65;                  # 客户端连接后保持连接的超时时间
        client_header_timeout  10;              # 设置客户端请求头读取超时时间 
                                                # 超时将返回Request time out (408)
        client_body_timeout    10;              # 设置客户端请求主体读取超时时间  超时也将返回408
        send_timeout           10;              # 指定响应客户端的超时时间
                                                # 如果超过这个时间 客户端没有任何活的 Nginx将关闭连接
                                                
        gzip  on;                               # 开启还是关闭gzip模块 on表示开启 实时压缩输出数据流
        gzip_min_length  1k;                    # 允许压缩页面最小字节数 小于1k的文件可能越压越大
        gzip_buffers     4  16k;                # 申请4个单位16KB的内存做压缩结果流缓存 默认源文件大小
        gzip_http_version  1.1;                 # 用于识别HTTP协议版本 默认 1.1
        gzip_comp_level  2;                     # 压缩等级 1 表示最快压缩 但压缩比最小 9反之
        gzip_types  text/plain application/x-javascript text/css application/xml;   # 指定压缩类型
        gzip_vary  on;                          # 让前端的缓存服务器缓存经过gzip压缩的页面

        server {                                # server段就是虚拟主机的配置
            listen       80;                    # 监听所有IP的80端口 可以指定单个IP
            server_name  localhost;             # 用来指定IP地址或域名 多个域名间用空格分开

            #charset koi8-r;                    # 用于设置网页默认编码

            #access_log  logs/host.access.log  main;    # 每一个虚拟主机也可以定义单独的access.log

            location / {                        # URL地址匹配设置
                root   /var/www/html;           # 网页根目录
                index  index.html index.htm;    # 默认首页地址 会先寻找index.html 然后往后
            }
            
            location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$  {   # 匹配以这些格式结尾的请求
                root    /var/www/static;                    # 匹配到的请求从这个目录找文件
                expires 30d;                                # 客户端缓存静态文件过期时间30天
            }
            
            
            error_page  404              /404.html;         # 自定义404页面 /404.html为root指定的位置

            # redirect server error pages to the static page /50x.html
            #
            error_page   500 502 503 504  /50x.html;        # 自定义50x页面 到/50x.html
            location = /50x.html {                          # 匹配50x页面的请求
                root   html;                                # 匹配到的请求从这个目录找文件
            }

            # proxy the PHP scripts to Apache listening on 127.0.0.1:80
            #
            location ~ \.php$ {                             # 匹配php页面的请求
                index index.php                             # 默认索引index.php
                proxy_pass   http://127.0.0.1               # 匹配到的请求转发到本机80端口处理
            }
            
            location ~ \.jsp$ {                             # 匹配jsp页面的请求
                index index.jsp                             # 默认索引index.jsp
                proxy_pass   http://127.0.0.1:8080          # 匹配到的请求转发到本机8080端口处理
            }
            
            location /status {                              # 匹配status的请求
                stub_status on;                             # 开启Nginx工作状态统计
                access_log    logs/status.log;              # 状态统计页面访问日志
                auth_basic    "Nginx Status";               # 自定义提醒 认证界面会显示
                auth_basic_user_file    /var/www/htpasswd;  # 认证密码文件 htpasswd工具由httpd提供
            }                                               # 访问http://host/status 就可以看到状态统计了
            
            # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
            #
            #location ~ \.php$ {                    # FastCGI模式
            #    root           /var/www/html;      # php页面根目录
            #    fastcgi_pass   127.0.0.1:9000;     # FastCGI监听地址 也可以使用unix套接字监听地址
            #    fastcgi_index  index.php;          # 索引文件
            #    fastcgi_param  SCRIPT_FILENAME  /var/www/html$fastcgi_script_name;  # php脚本全路径
            #    include        fastcgi_params;
            #}

            # deny access to .htaccess files, if Apache's document root
            # concurs with nginx's one
            #
            #location ~ /\.ht {                     # 匹配ht开头的文件
            #    deny  all;                         # 规则是全部拒绝
            #}
        }


        # another virtual host using mix of IP-, name-, and port-based configuration
        #
        #server {                                            # 另一台虚拟主机
        #    listen       8000;                              
        #    listen       somename:8080;
        #    server_name  somename  alias  another.alias;

        #    location / {
        #        root   html;
        #        index  index.html index.htm;
        #    }
        #}


        # HTTPS server
        #
        #server {                                           # 配置https网站
        #    listen       443 ssl;                          # 监听443端口 ssl加密
        #    server_name  localhost;

        #    ssl_certificate      cert.pem;                 # 证书需要用openssl生成 nginx需要添加ssl模块
        #    ssl_certificate_key  cert.key;                 # 证书key

        #    ssl_session_cache    shared:SSL:1m;
        #    ssl_session_timeout  5m;

        #    ssl_ciphers  HIGH:!aNULL:!MD5;
        #    ssl_prefer_server_ciphers  on;

        #    location / {
        #        root   html;
        #        index  index.html index.htm;
        #    }
        #}

    }

## <font color='#5CACEE'>附录</font>
> Nginx还有其他配置块 比如upstream (负载均衡) 或者其他模块提供的功能 这里只说明一些常用的配置块
    
