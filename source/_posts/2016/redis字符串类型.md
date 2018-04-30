---
title: Redis字符串类型
date: 2016-05-20 13:36:32
categories: 
    - Redis
---
## <font color='#5CACEE'>简介</font>
> 字符串类型是 Redis 中最基本的数据类型，它能存储任何形式的字符串，包括二进制数据。你可以用其存储用户的邮箱、JSON 化的对象甚至是一张图片。一个字符串类型键允许存储的数据的最大容量是512 MB
<!-- more -->

## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|redis|3.2.0|[<font color='#AAAAAA'>点击下载</font>](http://download.redis.io/releases/redis-3.2.0.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>命令返回值</font>
> 与redis-server交互 当执行一条命令后 redis-server都会有一个命令返回值 redis-server的返回值类型有五种 下面分别说明

    1. 状态回复
    状态回复是最简单的一种回复 比如向Redis发送SET命名设置某个键值时 Redis会回复OK表示成功
    127.0.0.1:6379> SET a 1
    OK
    127.0.0.1:6379> PING
    PONG
    127.0.0.1:6379>

    2. 错误回复
    当命令不存在或者命令格式有错误的情况下 Redis会返回错误回复
    127.0.0.1:6379> SET
    (error) ERR wrong number of arguments for 'set' command
    127.0.0.1:6379>
    
    3. 整数回复
    获取当前数据库中键的数量等 返回以(integer)开头的回复 这个便是整数回复
    127.0.0.1:6379> dbsize
    (integer) 2
    127.0.0.1:6379>
    
    4. 字符串回复
    字符串回复是最常用的一种回复类型 比如当获得一个键的值 Redis返回的便是一个字符串值
    127.0.0.1:6379> get a
    "1"
    127.0.0.1:6379>
    
    5. 多行字符串回复
    当请求的并非一个键的值 而是一个列表等 就会收到多行字符串回复 每行字符串都以一个序号开头
    127.0.0.1:6379> keys *
    1) "a"
    2) "b"
    127.0.0.1:6379>

    
### <font color='#CDAA7D'>常用命令</font>
> 下面将详细说明操作Redis字符串类型的相关命令

#### <font color='#DDA0DD'>赋值与取值</font>

```
SET key value       # 赋值
GET key             # 取值
```
    
    127.0.0.1:6379> SET name xiaoming
    OK
    127.0.0.1:6379> GET name
    "xiaoming"
    127.0.0.1:6379>
    
    如果需要给多个键同时赋值和取值 Redis还提供了MSET MGET两个命令
    
```
MSET key value [key value ...]      # 同时赋值
MGET key [key ...]                  # 同时取值
```
    
    127.0.0.1:6379> MSET a 1 b 2 c 3
    OK
    127.0.0.1:6379> MGET a c b 
    1) "1"
    2) "3"
    3) "2"
    127.0.0.1:6379>
    
    用MSET 给a 赋值1 b赋值2 c赋值3 返回状态回复OK 
    用MGET 先获取a的值 再获取c的值 最后获取b的值 返回一个多行字符串回复
    
    
#### <font color='#DDA0DD'>递增递减</font>

```
INCR key            # 递增
```
    
    当Redis存储的字符串是整数时 Redis提供了一个INCR的命令 其作用就是让当前键值递增
    127.0.0.1:6379> INCR num
    (integer) 1
    127.0.0.1:6379> INCR num
    (integer) 2
    127.0.0.1:6379> INCR num
    (integer) 3
    127.0.0.1:6379>
    
    当递增的key不存在时 Redis则自动创建这个key 并赋值为0 所以第一次递增后 就返回1了
    可以看到 返回值类型是整数回复 如果递增的对象不是一个整数会怎样呢
    
    127.0.0.1:6379> INCR name
    (error) ERR value is not an integer or out of range
    127.0.0.1:6379> 

    可以看到 收到一条错误回复 如果想要递增指定的数字 这个就要引入第二条递增命令了

```
INCRBY key increment            # 递增指定整数
```
    
    127.0.0.1:6379> INCRBY num 10
    (integer) 13
    127.0.0.1:6379> INCRBY num 3
    (integer) 16
    127.0.0.1:6379>
    
    可以看到 INCR和INCRBY的区别就是 INCRBY可以自定义递增数量 而INCR 只能每次加一
    现在说说递减 递减其实也有专门的操作命令
    
```
DECR key                        # 递减
DECRBY key decrement            # 递减指定整数
```
    
    127.0.0.1:6379> DECR num
    (integer) 15
    127.0.0.1:6379> DECRBY num 5
    (integer) 10
    127.0.0.1:6379>
    
    有没有想过 如果给INCRBY递增一个负数 或者给DECRBY递减一个负数会发生什么事情呢
    
    127.0.0.1:6379> DECRBY num -10
    (integer) 20
    127.0.0.1:6379> INCRBY num -5
    (integer) 15
    127.0.0.1:6379>
    
    可以看到 正如所想的那样 负负得正还是成立的
    不仅整数可以递增 Redis还存在递增浮点数的命令

```
INCRBYFLOAT num increment       # 递增指定浮点数
```
    
    127.0.0.1:6379> INCRBYFLOAT num 1.4
    "16.4"
    127.0.0.1:6379> INCRBYFLOAT num -3.2
    "13.2"
    127.0.0.1:6379>

#### <font color='#DDA0DD'>向尾部追加值</font>
```
APPEND key value                # 向尾部追加值
```
    
    127.0.0.1:6379> APPEND name 123abc
    (integer) 14
    127.0.0.1:6379> GET name
    "xiaoming123abc"
    127.0.0.1:6379>
    
    可以看到 APPEND 命令可以向字符串后面增加任意的字符串 返回增加后字符串长度

#### <font color='#DDA0DD'>获取字符串长度</font>
```
STRLEN key                      # 获取字符串长度
```

    127.0.0.1:6379> SET hello hello
    OK
    127.0.0.1:6379> STRLEN hello
    (integer) 5
    127.0.0.1:6379> SET hello 你好
    OK
    127.0.0.1:6379> STRLEN hello
    (integer) 6
    127.0.0.1:6379>
    
    Redis可以存储所有编码的字符串 中文也不例外 
    例子中Redis接受的是UTF-8编码的中文 一个中文UTF-8编码长度是3 所以 '你好' 会返回6了

#### <font color='#DDA0DD'>位操作</font>
> 位操作是个很有意思的操作 操作的是这个字符串在内存中的比特位
```
GETBIT key offset               # 获取偏移多少位后的值
SETBIT key offset value         # 设置偏移多少位后的值
BITCOUNT key [start end]        # 获取比特位是1的个数
BITPOS key bit [start] [end]    # 获取第一个位值是0或1的位置
```

    大家都知道 一个字节由8个比特位组成 而一个英文字符又正好一个字节
    
    127.0.0.1:6379> SET name abc

    a b c的三个字母的ASCII码分别是97 98 99 那么转换为二进制则如下
    
                a        b        c
            01100001 01100010 01100011
    
    比特位获取索引从0开始 比如第0位是0 第1位是1 第2位也是1
    
    127.0.0.1:6379> GETBIT name 2
    (integer) 1
    127.0.0.1:6379> GETBIT name 7
    (integer) 1
    127.0.0.1:6379> GETBIT name 8
    (integer) 0
    127.0.0.1:6379> GETBIT name 9
    (integer) 1
    127.0.0.1:6379>
    
    GETBIT是获取比特位的 那么SETBIT自然可以更改比特位的值 更改比特位后 自然也更改了这个字符
    分析a b c 三个字符的二进制数据 发现他们的区别在最后两位 01 10 11 那么修改这几个位的值试试
    
    127.0.0.1:6379> SETBIT name 6 1
    (integer) 0
    127.0.0.1:6379> GET name
    "cbc"
    127.0.0.1:6379>
    
    将a的第6位修改为1 那么原本a的二进制就变成了01100011 也就是和c相同了 a被变成了c
    
    BITCOUNT用来统计一定范围内比特位为1的个数 name的值变为cbc后 比特位如下
    
                c        b        c
            01100011 01100010 01100011
            
    可以数出来 1的个数有11个 BITCOUNT还可以限定参与计算的字符范围
    
    127.0.0.1:6379> BITCOUNT name
    (integer) 11
    127.0.0.1:6379> BITCOUNT name 0 0
    (integer) 4
    127.0.0.1:6379>
    
    第一个0是从第几个字符开始 第二个0是到第几个字符结束 0 0 就表示只有第一个字符c参与计算
    
    Redis 2.8.7版本以上才有BITPOS这个命令 可以获取指定键的第一个位值是0或者1的位置 也可以限定范围
    
    127.0.0.1:6379> BITPOS name 1
    (integer) 1
    127.0.0.1:6379> BITPOS name 0 1 2
    (integer) 8
    127.0.0.1:6379>
    
    第一个命令 获取name中 位值为1的索引 可以看到 01100011中 位值为1的索引是1
    第二个命令 限定从索引为1的字符开始 到索引为2的字符 位值为0的索引 字符b的第一位就是0 索引是8
    
## <font color='#5CACEE'>附录</font>
> 命令总结

    SET key value                   赋值
    GET key                         取值
    MSET key value [key value …]    同时赋值
    MGET key [key …]                同时取值
    INCR key                        递增
    INCRBY key increment            递增指定整数
    DECR key                        递减
    DECRBY key decrement            递减指定整数
    INCRBYFLOAT num increment       递增指定浮点数
    APPEND key value                向尾部追加值
    STRLEN key                      获取字符串长度
    GETBIT key offset               获取偏移多少位后的值
    SETBIT key offset value         设置偏移多少位后的值
    BITCOUNT key [start end]        获取比特位是1的个数
    BITPOS key bit [start] [end]    获取第一个位值是0或1的位置
    