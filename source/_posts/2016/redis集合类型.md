---
title: Redis集合类型
date: 2016-05-24 11:17:41
categories: 
    - Redis
---
## <font color='#5CACEE'>简介</font>
> 集合和列表有很多相似的地方 但是很容易将他们区分开 集合的元素有唯一性 而且元素是无序的。集合类型的常用操作是向集合中加入或删除元素、判断某个元素是否存在等。最方便的是多个集合类型键之间还可以进行并集、交集和差集运算
<!-- more -->

## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|redis|3.2.0|[<font color='#AAAAAA'>点击下载</font>](http://download.redis.io/releases/redis-3.2.0.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>常用命令</font>
> 下面将详细说明操作Redis集合类型的相关命令

#### <font color='#DDA0DD'>增加和删除元素</font>
```
SADD key member [member ...]        # 向一个集合添加元素
SREM key member [member ...]        # 从一个集合删除元素
```
    
    127.0.0.1:6379> SADD num 1 2 2 3
    (integer) 3
    127.0.0.1:6379> SREM num 1 1 2
    (integer) 2
    127.0.0.1:6379>
    
    SADD执行成功会返回添加成功的个数 因为2相同 所以只有一个被添加 SREM也同样 返回被成功删除的个数
    
    
#### <font color='#DDA0DD'>获取集合内所有元素</font>
```
SMEMBERS num            # 获取集合内所有元素
```
    
    127.0.0.1:6379> SMEMBERS num
    1) "3"
    127.0.0.1:6379> SADD num 2 2
    (integer) 1
    127.0.0.1:6379> SMEMBERS num
    1) "2"
    2) "3"
    
    可以看到 num中只剩下3了 而且添加两个元素2 最后num中也只有一个2
    
#### <font color='#DDA0DD'>判断元素是否在集合中</font>
```
SISMEMBER num 2         # 判断元素是否在集合中
```
    
    127.0.0.1:6379> SISMEMBER num 2
    (integer) 1
    127.0.0.1:6379> SISMEMBER num 1
    (integer) 0
    127.0.0.1:6379>
    
    如果命中了 则返回1 否则返回0
    
#### <font color='#DDA0DD'>集合运算</font>
```
SDIFF key1 [key2 ...]           # 计算差集
SINTER key1 [key2 ...]          # 计算交集
SUNION key1 [key2 ...]          # 计算并集
```
    
    SDIFF计算多个集合的差集 会想计算key1与key2的差集 然后将这个结果与key3继续计算 交集并集也同理
    
    127.0.0.1:6379> SADD num1 1 2 3
    (integer) 3
    127.0.0.1:6379> SADD num2 2 3 4
    (integer) 3
    127.0.0.1:6379> SDIFF num1 num2
    1) "1"
    127.0.0.1:6379> SDIFF num2 num1
    1) "4"
    127.0.0.1:6379>
    
    num1与num2的差集运算表示属于num1 且不属于num2的元素 反之亦然
    
    127.0.0.1:6379> SINTER num1 num2
    1) "2"
    2) "3"
    127.0.0.1:6379>
    
    SINTER 计算num1和num2的交集 
    
    127.0.0.1:6379> SUNION num1 num2
    1) "1"
    2) "2"
    3) "3"
    4) "4"
    127.0.0.1:6379
    
    SUNION 计算num1和num2的合集
    
#### <font color='#DDA0DD'>获取集合中元素个数</font>
```
SCARD key               # 获取集合中元素个数
```
    
    127.0.0.1:6379> SMEMBERS num1
    1) "1"
    2) "2"
    3) "3"
    127.0.0.1:6379> SCARD num1
    (integer) 3
    127.0.0.1:6379>
    
    SCARD 返回一个集合中元素个数
    
#### <font color='#DDA0DD'>存储集合运算后的结果</font>
```
SDIFFSTORE dest key [key …]          # 将差集运算的结果保存为dest
SINTERSTORE dest key [key …]         # 将交集运算的结果保存为dest
SUNIONSTORE dest key [key …]         # 将并集运算的结果保存为dest
```

    127.0.0.1:6379> SUNIONSTORE all num1 num2
    (integer) 4
    127.0.0.1:6379> SMEMBERS all
    1) "1"
    2) "2"
    3) "3"
    4) "4"
    127.0.0.1:6379>
    
    和SDIFF唯一区别就是不将结果返回 而是将结果保存为新的集合 只返回新集合元素个数 其余两个道理相同
    
#### <font color='#DDA0DD'>随机获得集合中的元素</font>
```
SRANDMEMBER key [count]         # 随机获得集合中的元素
```
    
    count非必选项 用于每次获取多少个随机元素 count的正负体现的意义也不同 
    count > 0 时 随机获取count个元素 但是元素不会出现重复获取的情况 也就是都是唯一的
    count < 0 时 随机获取count的绝对值个元素 元素可能被重复获取 
    如果count的值大于集合中的元素个数 则SRANDMEMBER会返回集合中的全部元素
    
    127.0.0.1:6379> SRANDMEMBER all 
    "1"
    127.0.0.1:6379> SRANDMEMBER all 
    "2"
    127.0.0.1:6379> SRANDMEMBER all 6
    1) "1"
    2) "2"
    3) "3"
    4) "4"
    127.0.0.1:6379> SRANDMEMBER all -6
    1) "2"
    2) "1"
    3) "1"
    4) "3"
    5) "2"
    6) "2"
    127.0.0.1:6379>
    
#### <font color='#DDA0DD'>从集合中弹出一个元素</font>
```
SPOP key            # 从集合中弹出一个元素
```

    127.0.0.1:6379> SPOP all
    "4"
    127.0.0.1:6379> SMEMBERS all
    1) "1"
    2) "2"
    3) "3"
    127.0.0.1:6379> SPOP all
    "1"
    127.0.0.1:6379> SMEMBERS all
    1) "2"
    2) "3"
    127.0.0.1:6379>

    由于集合是无序的 所以SPOP会随机弹出一个值


## <font color='#5CACEE'>附录</font>
> 命令总结

    SADD key member [member ...]            向一个集合添加元素
    SREM key member [member ...]            从一个集合删除元素
    SMEMBERS num                            获取集合内所有元素
    SISMEMBER num 2                         判断元素是否在集合中
    SDIFF key1 [key2 ...]                   计算差集
    SINTER key1 [key2 ...]                  计算交集
    SUNION key1 [key2 ...]                  计算并集
    SCARD key                               获取集合中元素个数
    SDIFFSTORE dest key [key …]             将差集运算的结果保存为dest
    SINTERSTORE dest key [key …]            将交集运算的结果保存为dest
    SUNIONSTORE dest key [key …]            将并集运算的结果保存为dest
    SRANDMEMBER key [count]                 随机获得集合中的元素
    SPOP key                                从集合中弹出一个元素















