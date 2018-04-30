---
title: Redis散列类型
date: 2016-05-25
categories: 
    - Redis
tags:
    - Redis

---

## <font color='#5CACEE'>简介</font>
>Redis 是采用字典结构以键值对的形式存储数据的，而散列类型（hash）的键值也是一种字典结构，其存储了字段（field）和字段值的映射，但字段值只能是字符串，不支持其他数据类型，换句话说，散列类型不能嵌套其他的数据类型。一个散列类型键可以包含最多232最少1个字段

<!--more-->


## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|redis|3.2.0|[<font color='#AAAAAA'>点击下载</font>](http://download.redis.io/releases/redis-3.2.0.tar.gz)|




## 简单认识散列类型
散列类型适合存储对象：使用对象类别和 ID 构成键名，使用字段表示对象的属性，而字段值则存储属性值。需要注意 散列类型的字段值只能是字符串类型 不能嵌套其他类型

        键:ID              字段              字段值
                  +---->   color   ----->    white
        car:1 ----+---->   name    ----->    Ferraris
                  +---->   price   ----->    10 million

散列类型的字段可以随意拓增或者减少 所以散列类型的结构只是人为的约定


## 常用命令
下面将详细说明操作Redis散列类型的相关命令

### 赋值与取值
        HSET key field value                # 赋值
        HGET key field                      # 取值
        127.0.0.1:6379> HSET car:1 color white
        (integer) 1
        127.0.0.1:6379> HSET car:1 name Ferraris
        (integer) 1
        127.0.0.1:6379> HSET car:1 price '10 million'
        (integer) 1
        127.0.0.1:6379> HGET car:1 color
        "white"
        127.0.0.1:6379> HGET car:1 name
        "Ferraris"
        127.0.0.1:6379> HGET car:1 price
        "10 million"
        127.0.0.1:6379>

HSET不区分插入和更新操作 修改数据时不用事先判断字段是否存在
插入或修改一个字段时 当字段不存在 HSET命令返回1 否则返回0

        127.0.0.1:6379> HSET car:1 color blue
        (integer) 0
        127.0.0.1:6379> HGET car:1 color
        "blue"
        127.0.0.1:6379>

和字符串类似 当需要给多个字段同时设定值 或获取值 也有相应的命令

    HMSET key field value [field value ...]      # 同时赋值
    HGET key field                               # 同时取值
    127.0.0.1:6379> HMSET car:2 color red name Bentley price '3 million'
    OK
    127.0.0.1:6379> HMGET car:2 color name price
    1) "red"
    2) "Bentley"
    3) "3 million"
    127.0.0.1:6379>

如果事先不知道这个car:2有哪些字段 那么如何获取这个key中所有的字段和值呢

        HGETALL key             # 获取所有字段值
        127.0.0.1:6379> HGETALL car:2
        1) "color"
        2) "red"
        3) "name"
        4) "Bentley"
        5) "price"
        6) "3 million"
        127.0.0.1:6379>

还可以单独获取字段名或字段值

        HKEYS key           # 只获取字段名
        HVALS key           # 只获取字段值
        127.0.0.1:6379> HKEYS car:1
        1) "name"
        127.0.0.1:6379> HKEYS car:2
        1) "color"
        2) "name"
        3) "price"
        4) "date"
        127.0.0.1:6379> HVALS car:1
        1) "Ferraris"
        127.0.0.1:6379> HVALS car:2
        1) "red"
        2) "Bentley"
        3) "3 million"
        4) "2016-05-22"
        127.0.0.1:6379> 

### 判断字段是否存在

        HEXISTS key field            # 判断字段是否存在
        127.0.0.1:6379> HEXISTS car:1 date
        (integer) 0
        127.0.0.1:6379> HSET car:1 date '2016-05-22'
        (integer) 1
        127.0.0.1:6379> HEXISTS car:1 date
        (integer) 1
        127.0.0.1:6379>

当字段不存在返回0 字段存在 返回1

### 字段不存在时赋值

        HSETNX key field value      # 字段不存在时赋值
        127.0.0.1:6379> HSETNX car:2 color black
        (integer) 0
        127.0.0.1:6379> HGET car:2 color
        "red"
        127.0.0.1:6379> HSETNX car:2 date '2016-05-22'
        (integer) 1
        127.0.0.1:6379> HGET car:2 date
        "2016-05-22"
        127.0.0.1:6379>

可以看到 如果字段存在 赋值失败 并返回0 如果不存在 赋值成功 返回1

### 字段值自增自减
        HINCRBY key field increment     # 字段值自增
        127.0.0.1:6379> HINCRBY car id 1
        (integer) 1
        127.0.0.1:6379> HGET car id
        "1"
        127.0.0.1:6379> HINCRBY car id 2
        (integer) 3
        127.0.0.1:6379> HGET car id
        "3"
        127.0.0.1:6379>

字段值的自增和字符串的自增道理相同 因为没有自减 所以可以用自增 -1 来实现

### 删除字段
        HDEL key field [field ...]      # 删除指定的一个或多个字段
        127.0.0.1:6379> HDEL car:1 price date
        (integer) 2
        127.0.0.1:6379> HGETALL car:1
        1) "color"
        2) "blue"
        3) "name"
        4) "Ferraris"
        127.0.0.1:6379> HDEL car:1 price color
        (integer) 1
        127.0.0.1:6379>

HDEL会返回删除成功的字段个数

### 获取字段数量
        HLEN key            # 获取字段数量
        127.0.0.1:6379> HLEN car:1
        (integer) 1
        127.0.0.1:6379> HLEN car:2
        (integer) 4
        127.0.0.1:6379>

## 附录
### 命令总结

        HSET key field value                    给键的字段赋值
        HGET key field                          获取键的字段值
        HMSET key field value [field value ...] 同时赋值
        HGET key field                          同时取值
        HGETALL key                             获取所有字段值
        HKEYS key                               只获取字段名
        HVALS key                               只获取字段值
        HEXISTS key field                       判断字段是否存在
        HSETNX key field value                  字段不存在时赋值
        HINCRBY key field increment             字段值自增
        HDEL key field [field ...]              删除指定的一个或多个字段
        HLEN key                                获取字段数量