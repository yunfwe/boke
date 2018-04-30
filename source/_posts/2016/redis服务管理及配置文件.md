---
title: Redis服务管理及配置文件
date: 2016-05-18 10:04:37
categories: 
    - Redis
tags:
    - nosql
    - redis
---
## <font color='#5CACEE'>简介</font>
> Redis启动后还需要对其进行管理 比如如何安全的关闭数据库 以及如何配置服务的监听地址 访问密码等 
下面将详细说明 Redis服务的简单管理 以及配置文件详解
<!-- more -->

## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|redis|3.2.0|[<font color='#AAAAAA'>点击下载</font>](http://download.redis.io/releases/redis-3.2.0.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>启动和停止Redis</font>
> 启动Redis很简单 可执行程序路径后面跟配置文件路径就可以了 如果在前台运行Redis的话 Ctrl+c就可以很安全的关闭Redis了 那么如果在后台运行呢

    /usr/local/redis/bin/redis-server /etc/redis.conf --daemonize yes
    
    通过--daemonize yes或者直接修改配置文件中的daemonize为yes 让Redis默认后台运行
    
    [root@localhost ~]# netstat -anpt
    tcp    0   0 127.0.0.1:6379        0.0.0.0:*       LISTEN    3268/redis-server 1 
    
    可以看到 Redis已经监听在本机127.0.0.1的6379端口 PID号为3268 
    关闭Redis也非常简单 因为Redis能很好的处理TREM信号 所以可以直接 kill 3268
    同样 使用redis-cli客户端连接工具 向Redis服务发送SHUTDOWN命令也是可以安全关闭的
    
    /usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 6379 SHUTDOWN
    
    redis的命令不区分大小写 但是建议命令大写
    如果服务监听在本机的127.0.0.1:6379 redis-cli可以直接连接 而不用指定主机和端口号
    当redis收到结束命令或TERM信号后 会断开所有客户端连接 然后将内存数据序列化到硬盘 最后完成退出
    
    
### <font color='#CDAA7D'>Redis配置文件</font>
> Redis的启动监听地址 监听端口 以及配置PID文件路径等 有非常多的启动参数 如果都在启动redis的时候传入 那么将非常麻烦 而通过配置文件的方式 将大大简化这个过程
Redis的配置项还分两种 一种是只能在启动Redis的时候配置的 比如监听端口等 还有一种可以在命令行中动态修改的 比如日志记录级别等 以下是Redis配置文件中常用配置项
    
    include /path/to/other.conf     # 包含其他配置文件
    
    监听相关配置项
    tcp-backlog 511                 # TCP监听最大容纳数量 增大可以解决高并发下客户端连接缓慢问题
    unixsocket /tmp/redis.sock      # 非默认项 启动unix套接字监听 redis-cli -s /tmp/redis.sock连接
    timeout 0                       # 客户端多长时间没有操作redis关闭连接 0表示不关闭
    tcp-keepalive 0                 # tcp 心跳包 防止一个死的对端连接 推荐设置为60秒
    
    一般配置项
    daemonize no                    # Redis默认运行在前台 使用yes可以让Redis默认后台运行
    pidfile /var/run/redis.pid      # pid文件位置
    loglevel notice                 # 日志记录级别 [debug | verbose | notice | warning]
    logfile /tmp/redis.log          # 日志文件位置 默认是个空字符串 redis将日志打印到标准输出
    syslog-enabled no               # 如果想把日志记录到系统日志 就改为yes
    databases 16                    # redis启动数据库空间个数 默认进入的是id为0空间 select dbID切换
    
    数据库快照配置项
    save 900 1                      # 保存数据库到磁盘 900 秒内如果至少有 1 个 key 的值变化，则保存
    save 300 10                     # 300 秒内如果至少有 10 个 key 的值变化，则保存
    save 60 10000                   # 60 秒内如果至少有 10000 个 key 的值变化，则保存
    save ""                         # 停用自动保存功能 不同的保存规则是可以都生效的
    dbfilename dump.rdb             # 保存数据的文件位置
    stop-writes-on-bgsave-error yes # 后台保存数据出错 redis强制关闭写操作
    rdbcompression yes              # 是否在保存数据时压缩 可以减少磁盘使用 但是增大CPU负载
    rdbchecksum yes                 # 是否校验rdb文件
    dir ./                          # dump.rdb就保存在dir目录中
    
    主从复制配置项
    slaveof 172.17.0.2 6379         # 作为172.17.0.2的从数据库
    masterauth password             # 如果主数据库需要认证 密码写这里
    slave-serve-stale-data yes      # 如果与主失去联系 从是否要继续提供查询服务 数据可能不是最新
    slave-read-only yes             # 默认从数据库不支持写入操作 
    repl-ping-slave-period 10       # 默认每10秒 从数据库发送ping命令道主数据库
    repl-timeout 60                 # 主从复制过期时间 一定要比repl-ping-slave-period大
    repl-diskless-sync no     # 默认情况下 复制是内存-> 磁盘-> 内存-> slave端 yes后 将直接发到slave
    repl-diskless-sync-delay 5      # 收到第一个请求时 等待多个slave一起来请求之间的间隔时间
    repl-backlog-size 1mb           # 设置主从复制容量大小 slave断线重连 只恢复断开时丢失的数据
    repl-backlog-ttl 3600           # 3600秒后 slave没有连接 master将释放backlog 0表示不释放
    slave-priority 100              # 集群中用 master挂了 slave提升为master的优先级
    min-slaves-to-write 3           # 至少3个slave才允许向master写数据
    min-slaves-max-lag 10           # 至少3个slave 并且ping心跳的超时不超过10秒 才允许向master写数据
    
    安全配置项
    requirepass passwd              # 连接需要密码 redis-cli 需要通过auth命令 或 -a 参数指定密码登陆
    rename-command CONFIG ""        # 给命令重命名 如果重命名为空字符串 则屏蔽命令
    
    限制相关配置
    maxclients 10000                # 最大连接客户端数量 超过的 redis将关闭新连接
    maxmemory 1024mb                # 数据库最大占用1024mb内存 超过的话 将按照策略移除keys
    maxmemory-policy noeviction     # 内存超过后默认移除key的策略
    maxmemory-samples 5             # 调整算法的速度和精度 默认从五个键中找到一个使用最少的键
    
    以下是支持的策略:
        volatile-lru ->     使用 LRU 算法移除包含过期设置的 key
        allkeys-lru  ->     根据 LRU 算法移除所有的 key
        volatile-random ->  随机移除过期的key
        allkeys-random  ->  随机移除所有的key
        volatile-ttl ->     删除最近到期的key
        noeviction   ->     不让任何 key 过期，只是给写入操作返回一个错误
    
    AOF日志配置项
    appendonly no                   # 默认不启用aof日志
    appendfilename redis.aof        # aof日志名称 和rdb快照共享dir路径
    appendfsync everysec            # aof日志同步硬盘数据策略 (fsync)
    每次更改数据库内存后 AOF都会将命令记录到AOF文件 但是由于系统缓存机制 数据还并没真正写入硬盘
    系统默认30秒写入一次硬盘 如果在这期间 系统异常退出 将导致数据丢失 以下是redis的解决策略:
        no        ->        不进行主动同步操作
        always    ->        每次执行写入操作都进行一次同步
        everysec  ->        每秒执行一次主动同步操作
    
    no-appendfsync-on-rewrite no    # 是否在Redis重写aof文件期间调用fsync
    auto-aof-rewrite-percentage 100 # aof文件增长超过上次aof文件大小100% 重写aof文件 0 禁用
    auto-aof-rewrite-min-size 64mb  # 触发aof重写的大小限制 只有aof大小超过64mb 上一条才生效
    aof-load-truncated yes          # redis在启动时可以加载被截断的AOF文件
    
    Lua脚本配置项
    lua-time-limit 5000             # 一个lua脚本最长执行时间 0或负数无限执行 默认5000毫秒
    
    Redis集群配置项
    cluster-enabled yes             # 启用或禁用集群
    cluster-config-file nodes.conf     # 保存节点配置文件的路径 节点配置文件无须人为修改
    cluster-node-timeout 15000      # 集群节点超时 默认15000毫秒
    cluster-slave-validity-factor 10    # master失联多久 slave故障切换 0 表示一直尝试切换
    cluster-migration-barrier 1         # 一个master可以拥有的最小slave数量
    cluster-require-full-coverage yes   # 当一定比例的键空间没有被覆盖到 集群就停止任何查询操作
    
    慢查询日志配置项
    slowlog-log-slower-than 10000   # 配置记录慢查询日志的条件 单位是微妙 负值关闭 0记录所有
    slowlog-max-len 1024            # 记录慢查询日志最大条数
    
    延时监控配置项
    latency-monitor-threshold 0     # redis延迟监控子系统在运行时 会抽样检测可能导致延迟的不同操作
                                    # 系统只记录超过设定值的操作 单位是毫秒 0表示禁用该功能  
    
    事件通知配置项
    notify-keyspace-events ""       # 空字符串表示关闭键空间通知功能 支持以下字符任意组合
    K       ->      键空间通知 所有通知以 __keyspace@ __ 为前缀
    E       ->      键事件通知，所有通知以 __keyevent@ __ 为前缀
    g       ->      DEL EXPIRE RENAME 等类型无关的通用命令的通知
    $       ->      字符串命令的通知
    l       ->      列表命令的通知
    s       ->      集合命令的通知
    h       ->      哈希命令的通知
    z       ->      有序集合命令的通知
    x       ->      过期事件 每当有过期键删除时通知
    e       ->      键淘汰事件 每当有键因为maxmemory-policy 策略被淘汰时通知
    A       ->      参数g$lshzxe 的别名
    
    高级配置
    hash-max-ziplist-entries 512    # 指定在超过一定的数量或者最大的元素超过某一临界值时
    hash-max-ziplist-value 64       # 采用一种特殊的哈希算法
    list-max-ziplist-size -2        # 列表 集合 有序集合和哈希的一样
    list-compress-depth 0
    set-max-intset-entries 512
    zset-max-ziplist-entries 128
    zset-max-ziplist-value 64
    hll-sparse-max-bytes 3000       # HyperLogLog稀疏表示限制设置
    activerehashing yes             # 如果对延迟要求较高 则设为no 禁止重新hash 但可能会浪费很多内存
    client-output-buffer-limit normal 0 0 0         # 客户端缓存限制 硬限制 软限制 以及软限制持续秒数
    client-output-buffer-limit slave 256mb 64mb 60  # 当满足硬限制 或者 软限制和持续秒数 与客户端断开
    client-output-buffer-limit pubsub 32mb 8mb 60
    hz 10                       # 内部函数执行的后台任务的频率 如清除过期数据 客户端超时链接等 1~500
    
    
## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>动态更改Redis配置</font>
> 连接到redis后 用CONFIG GET * 可以看到所有的配置 用CONFIG SET则可以对配置进行修改 但是 并不是所有的配置都能动态修改

    下面的例子 是用CONFIG SET 动态的给数据库添加认证密码
    
    127.0.0.1:6379> CONFIG SET requirepass 123.com
    OK
    127.0.0.1:6379> set a 100
    (error) NOAUTH Authentication required.
    127.0.0.1:6379> auth 123.com
    OK
    127.0.0.1:6379> set a 100
    OK
    127.0.0.1:6379>
    
    可以看到 通过CONFIG GET已经可以看到刚才设置的密码
    127.0.0.1:6379> CONFIG GET requirepass 
    1) "requirepass"
    2) "123.com"
    127.0.0.1:6379>
    
    由于已经配置了密码 下次登陆的时候 也可以直接用 -a 参数提供认证密码
    /usr/local/redis/bin/redis-cli -a 123.com
    
    
    
    
    
    
    
    
    