---
title: Redis有序集合类型
date: 2016-05-24 12:53:19
categories: 
    - Redis
---
## <font color='#5CACEE'>简介</font>
> 有序集合类型 顾名思义 与集合类型的区别就是有序 这个有序是在集合类型的基础上 给每个元素关联了一个分数 按照分数进行排序
<!-- more -->

## <font color='#5CACEE'>环境</font>
|软件名称|版本号|下载地址|
|-|:-:|-:|
|redis|3.2.0|[<font color='#AAAAAA'>点击下载</font>](http://download.redis.io/releases/redis-3.2.0.tar.gz)|

## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>与列表类型的区别</font>
> 有序集合类型在某些方面和列表类型相似 但是还是有很大的区别

    与列表相似的地方:
        1. 两者都是有序的
        2. 两者都可以获取某一个范围的元素
        
    与列表不同的地方:
        1. 列表通过链表实现 所以访问两端数据比较快 访问中间数据会较慢 
        2. 而集合采用散列表和跳跃表 所以没有这个忧虑
        3. 列表不能简单的调整某个元素的位置 但有序集合通过修改元素分数可以 
        4. 有序集合比列表类型更耗费内存
        
### <font color='#CDAA7D'>常用命令</font>
> 下面将详细说明操作Redis有序集合类型的相关命令
#### <font color='#DDA0DD'>增加元素</font>
```
ZADD key score member [score member …]      # 增加元素
```

    127.0.0.1:6379> ZADD num 1 a 2 b 3 c
    (integer) 3
    127.0.0.1:6379> ZADD num 2 a 2.5 d
    (integer) 1
    127.0.0.1:6379>
    
    元素的分数可以修改 可以是小数 最后的排序方式就是按照分数排序的
    
#### <font color='#DDA0DD'>获取元素分数</font>
```
ZSCORE key member           # 获取元素分数
```

    127.0.0.1:6379> ZSCORE num a
    "2"
    127.0.0.1:6379> ZADD num 3 a 
    (integer) 0
    127.0.0.1:6379> ZSCORE num a
    "3"
    127.0.0.1:6379>
    
    
#### <font color='#DDA0DD'>获取某个范围的元素</font>
```
ZRANGE key start stop [WITHSCORES]      # 获取某个索引范围的元素
ZREVRANGE key start stop [WITHSCORES]   # 获取某个索引范围的元素 反序排序
```

    127.0.0.1:6379> ZRANGE num 0 -1
    1) "b"
    2) "d"
    3) "a"
    4) "c"
    127.0.0.1:6379> ZRANGE num 0 1 WITHSCORES
    1) "b"
    2) "2"
    3) "d"
    4) "2.5"
    127.0.0.1:6379>
    
    ZRANGE的用法和LRANGE的用法大致一样 只不过多了个 WITHSCORES 可以同时显示分数
    如果出现分数相同的情况 则按照 0 < 9 < A < Z < a < z 规则排序
    
    127.0.0.1:6379> ZREVRANGE num 0 -1
    1) "c"
    2) "a"
    3) "d"
    4) "b"
    127.0.0.1:6379>
    
    可以看到 ZREVRANGE 与 ZRANGE 结果是相反的


#### <font color='#DDA0DD'>获取某个分数范围的元素</font>
```
ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]     # 获取某个分数范围的元素
ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]  # 获取某个分数范围的元素 反序排序
```

    127.0.0.1:6379> ZRANGEBYSCORE num 2.5 3
    1) "d"
    2) "a"
    3) "c"
    127.0.0.1:6379> ZRANGEBYSCORE num 2.5 (3
    1) "d"
    127.0.0.1:6379> ZRANGEBYSCORE num (2.5 3
    1) "a"
    2) "c"
    127.0.0.1:6379>
    
    如果不希望获取端点值 可以在端点分数前加 "(" 这样就可以把端点值排除在外了 无穷大可以用 +inf
    
    127.0.0.1:6379> ZRANGEBYSCORE num 2.5 3 LIMIT 0 2
    1) "d"
    2) "a"
    127.0.0.1:6379> ZRANGEBYSCORE num 2.5 3 LIMIT 1 2
    1) "a"
    2) "c"
    127.0.0.1:6379> ZRANGEBYSCORE num 2.5 3 LIMIT 1 3
    1) "a"
    2) "c"
    127.0.0.1:6379> ZRANGEBYSCORE num 2.5 3 LIMIT 0 3
    1) "d"
    2) "a"
    3) "c"
    127.0.0.1:6379>
    
    WITHSCORES用法不在赘述 LIMIT是限制结果数量 LIMIT 1 2表示从结果的索引1开始 只要2个结果
    ZREVRANGEBYSCORE的用法可以参考ZRANGE与ZREVRANGE的去别 也不再详细说明

#### <font color='#DDA0DD'>增加某个元素的分数</font>
```
ZINCRBY key increment member            # 增加某个元素的分数
```

    127.0.0.1:6379> ZSCORE num a
    "3"
    127.0.0.1:6379> ZINCRBY num 4 a
    "7"
    127.0.0.1:6379> ZINCRBY num -2 a
    "5"
    127.0.0.1:6379>
    
    如果指定的元素不存在 ZINCRBY同样会先创建 赋值为0后在增加分数

#### <font color='#DDA0DD'>获取集合中元素数量</font>
```
ZCARD key               # 获取集合中元素数量
```

    127.0.0.1:6379> ZCARD num
    (integer) 4
    127.0.0.1:6379> ZADD num 6 e 
    (integer) 1
    127.0.0.1:6379> ZCARD num
    (integer) 5
    127.0.0.1:6379>
    
#### <font color='#DDA0DD'>获得指定分数范围内的元素个数</font>
```
ZCOUNT key min max          # 获得指定分数范围内的元素个数
```

    127.0.0.1:6379> ZRANGE num 0 -1 WITHSCORES
     1) "b"
     2) "2"
     3) "d"
     4) "2.5"
     5) "c"
     6) "3"
     7) "a"
     8) "5"
     9) "e"
    10) "6"
    127.0.0.1:6379> ZCOUNT num (2.5 5
    (integer) 2
    127.0.0.1:6379> ZCOUNT num 2.5 5
    (integer) 3
    127.0.0.1:6379>
    
    获取分数为2.5到5之间元素个数 也可以使用 "(" 是否排查端点
    
#### <font color='#DDA0DD'>删除一个或多个元素</font>
```
ZREM key member [member …]      # 删除一个或多个元素
```

    127.0.0.1:6379> ZREM num a b 
    (integer) 2
    127.0.0.1:6379> ZRANGE num 0 -1 
    1) "d"
    2) "c"
    3) "e"
    127.0.0.1:6379>
    
    命令返回删除成功的元素数量
    
#### <font color='#DDA0DD'>按照排名范围删除元素</font>
```
ZREMRANGEBYRANK key start stop          # 按照排名范围删除元素
```

    127.0.0.1:6379> ZREMRANGEBYRANK num 0 1
    (integer) 2
    127.0.0.1:6379> ZRANGE num 0 -1 WITHSCORES
    1) "e"
    2) "6"
    127.0.0.1:6379>
    
    按照索引范围去删除元素 返回删除成功的元素个数

#### <font color='#DDA0DD'>按照分数范围删除元素</font>
```
ZREMRANGEBYSCORE key min max        # 按照分数范围删除元素
```

    127.0.0.1:6379> ZADD num 2 a 3 b 4 d
    (integer) 3
    127.0.0.1:6379> ZREMRANGEBYSCORE num (2 4
    (integer) 2
    127.0.0.1:6379> ZRANGE num 0 -1
    1) "a"
    2) "e"
    127.0.0.1:6379>
    
    删除分数大于2 小于4的元素 返回删除成功的元素个数

#### <font color='#DDA0DD'>获得元素的排名</font>
```
ZRANK key member                # 获得元素的排名 正序排序
ZREVRANK key member             # 获得元素的排名 反序排序
```

    127.0.0.1:6379> ZRANK num a
    (integer) 0
    127.0.0.1:6379> ZRANK num e
    (integer) 1
    127.0.0.1:6379> ZREVRANK num e
    (integer) 0
    127.0.0.1:6379> ZREVRANK num a
    (integer) 1
    127.0.0.1:6379>
    
    排序从0开始 ZREVRANK会反序排序 

#### <font color='#DDA0DD'>集合运算</font>
```
ZINTERSTORE dest numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]  # 交集
ZUNIONSTORE dest numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]  # 并集
```

    numkeys是参与计算的键的个数 WEIGHTS是权重 
    AGGREGATE绝定最后结果集合的元素分数是取平均数还是最大最小值
    
    127.0.0.1:6379> ZADD num1 1 a 2 b 3 c 
    (integer) 3
    127.0.0.1:6379> ZADD num2 1 b 2 c 3 d 
    (integer) 3
    127.0.0.1:6379> ZINTERSTORE tmp1 2 num1 num2 AGGREGATE SUM
    (integer) 2
    127.0.0.1:6379> ZRANGE tmp1 0 -1 WITHSCORES 
    1) "b"
    2) "3"
    3) "c"
    4) "5"
    127.0.0.1:6379>
    
    结果分数是取参与运算元素分数的总数 num1中b的分数是2 num2中b的分数是1 最后结果是3
    如果不加AGGREGATE 默认也是去SUM值 所以可以不用加
    
    WEIGHTS参数设置每个集合的权重，每个集合在参与计算时元素的分数会被乘上该集合的权重
    
    127.0.0.1:6379> ZINTERSTORE tmp2 2 num1 num2 WEIGHTS 1 10
    (integer) 2
    127.0.0.1:6379> zrange tmp2 0 -1 WITHSCORES
    1) "b"
    2) "12"
    3) "c"
    4) "23"
    127.0.0.1:6379> 
    
    ZUNIONSTORE与ZINTERSTORE用法相似 则不再赘述
    

## <font color='#5CACEE'>附录</font>
> 命令总结

    ZADD key score member [score member …]              增加元素
    ZSCORE key member                                   获取元素分数
    ZRANGE key start stop [WITHSCORES]                  获取某个索引范围的元素
    ZREVRANGE key start stop [WITHSCORES]               获取某个索引范围的元素 反序排序
    ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]     获取某个分数范围的元素
    ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]  获取某个分数范围的元素 反序排序
    ZINCRBY key increment member                        增加某个元素的分数
    ZCARD key                                           获取集合中元素数量
    ZCOUNT key min max                                  获得指定分数范围内的元素个数
    ZREM key member [member …]                          删除一个或多个元素
    ZREMRANGEBYRANK key start stop                      按照排名范围删除元素
    ZREMRANGEBYSCORE key min max                        按照分数范围删除元素
    ZRANK key member                                    获得元素的排名 正序排序
    ZREVRANK key member                                 获得元素的排名 反序排序
    ZINTERSTORE dest numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]  交集
    ZUNIONSTORE dest numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]  并集










