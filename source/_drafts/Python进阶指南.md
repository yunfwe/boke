---
title: Python进阶指南
date: 2018-04-04 23:12:00
updated: 2018-04-11
categories: 
    - Python
tags:
    - python
photos:
    - /uploads/photos/2jiya20va4e4fm46.jpg
---

## 简介
> 记录了关于Python编程中的一些小技巧和黑科技，包括一些非常好用的官方库和第三方库（堪称神器）用于解决工作学习中遇到的各种问题。本文档并不详细解释所有提到的知识点和库，只提供解决某种类型问题的一种思路，详细的用法还需要进一步翻阅官方文档或者借助搜索引擎。由于 Python2.7 将会在2020年官方停止，Python3 才是未来，所以本文档的例子都在 Python3.6 上测试通过。本文档长期更新。

<!-- more -->

## 编程技巧

### 高级语法

#### 解压序列

解压序列赋值给多个变量，先看一个简单的例子

    >>> a,b,c = (1,2,3)
    >>> print(a,b,c,sep=' ')
    1 2 3
    >>> a,b = (1,2,3)
    Traceback (most recent call last):
    File "<stdin>", line 1, in <module>
    ValueError: too many values to unpack (expected 2)
    >>> a,b,c,d = (1,2,3)
    Traceback (most recent call last):
    File "<stdin>", line 1, in <module>
    ValueError: not enough values to unpack (expected 4, got 3)

元组`(1,2,3)`解压并分别赋值给了`a,b,c`，如果接收的变量太少或者太多都会抛出异常。这时可以使用 `*` 来将多余的元素都赋值给这个变量。

    >>> a,*b,c = (1,2,3,4)
    >>> print('a=%s b=%s c=%s' % (a,b,c))
    a=1 b=[2, 3] c=4

这种解压赋值可以用在任何可迭代对象上，也就是说字符串、列表、生成器、字典甚至文件对象都适用，不过字典会将 key 进行赋值。

    >>> a,b,c = {'d':1,'e':2,'f':3}
    >>> print(a,b,c,sep=' ')
    d e f
    >>> f = open('/etc/passwd')
    >>> a,b,*_ = f
    >>> print(a,b,sep='')
    root:x:0:0:root:/root:/bin/bash
    daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin

利用这个知识点还可以实现不借助第三方变量来交换两个变量的值

    >>> x,y = 1,2
    >>> print(x,y,sep=' ')
    1 2
    >>> x,y = y,x
    >>> print(x,y,sep=' ')
    2 1

#### 三目运算符

像 C 和 Java 等都有一种叫三目运算符的东西 `(expr) ? value1 : value2;`，根据判断表达式的结果来从两个选择中取一个值，Python 中也有类似的东西，但是语法却完全不同的。

语法： `value1 if expr else value2`。当表达式的结果为真时，取 value1，为假时取 value2。

示例：

    >>> b = 1
    >>> a = 2 if b != 1 else 3
    >>> print(a)
    3

还有一个小技巧，Python 如果对 `True` 和 `False` 进行数学运算的时候，会把 `True` 当作 1，`False` 当作 0，所以还可以采用对迭代器进行切片的方式取值：

    >>> True+1
    2
    >>> True + False
    1
    >>> ('a','b')[1>2]
    'a'
    >>> ('a','b')[1<2]
    'b'


#### 列表解析

列表解析是根据已有的可迭代对象，高效的创建新列表的方法。

语法：
+ `[expression for iter_val in iterable]`
+ `[expression for iter_val in iterable if cond_expr]`

示例：

将所有的小写字母转为大写

    >>> L = ['a', 'b', 'c']
    >>> [x.upper() for x in L]
    ['A', 'B', 'C']

将所有的小写字母转为大写并排除掉列表中的数字

    >>> L = [1, 'a', 2, 'c']
    >>> [x.upper() for x in L if type(x) == type(str())]
    ['A', 'C']

可以看到，对于一些简单的处理，用列表解析更简洁，而且因为Python的内部优化，其运行速度会比普通处理方法更快。


#### 字典解析

字典解析就是利用可迭代对象创建新的字典。

语法：
+ `{expression:expression for iter_val in iterable}`
+ `{expression:expression for iter_val in iterable if cond_expr}`

示例：

计算字符的 ASCII 码，然后以键值的形式保存在字典中

    >>> L = ['a', 'b', 'C', 'D']
    >>> {x:ord(x) for x in L}
    {'a': 97, 'b': 98, 'C': 67, 'D': 68}

过滤掉刚才字典中小写字母的键

    >>> D = {'a': 97, 'b': 98, 'C': 67, 'D': 68}
    >>> {x:y for x,y in D.items() if y >= 65 and y < 97}
    {'C': 67, 'D': 68}

#### 集合解析

集合解析和列表解析用法一致，只不过使用和字典解析一样的大括号，并且返回的是一个集合。

语法：
+ `{expression for iter_val in iterable}`
+ `{expression for iter_val in iterable if cond_expr}`

示例：

将所有的小写字母转为大写，并且去掉重复的字母

    >>> L = ['a', 'a', 'b', 'c']
    >>> {x.upper() for x in L}
    {'B', 'A', 'C'}

#### 生成器表达式

生成器表达式的用法和列表解析也非常相似，但是生成器表达式不同于列表解析的地方是它返回的是一个生成器。生成器表达式使用了惰性计算的机制。

语法：
+ `(expression for iter_val in iterable)`
+ `(expression for iter_val in iterable if cond_expr)`

示例：

将所有的小写字母转为大写并排除掉列表中的数字

    >>> L = [1, 'a', 2, 'c']
    >>> g = (x.upper() for x in L if type(x) == type(str()))
    >>> g
    <generator object <genexpr> at 0x7f8e1fa79468>
    >>> next(g)
    'A'
    >>> next(g)
    'C'
    >>> next(g)
    Traceback (most recent call last):
    File "<stdin>", line 1, in <module>
    StopIteration

### 函数式编程

#### lambda

先来看看 `lambda` 的一个简单例子：

    >>> func = lambda x: x**2
    >>> func(2)
    4
    >>> func(4)
    16


可以这样理解，`lambda` 作为一个表达式，定义了一个匿名函数。`lambda` 的主体只能是一个表达式，而不是一个代码块，所以 `lambda` 只能封装有限的逻辑进去。表达式的结果就是 `lambda` 的返回值。

语法：`lambda [arg1 [,arg2,.....argn]]:expression`

#### map

语法：`map(function, iterable, ...)`

`map()` 函数的第一个参数是一个方法，第二个参数开始是一个迭代器。如果同时存在多个迭代器，`map()` 会同时遍历所有的迭代器，遍历次数以最短的迭代器为准，每个迭代器的值都将作为参数传给 `function`。下面看看 `map()` 应该怎么用。

示例：

把列表中所有是数字的元素乘 2

    >>> L = [1, 'a', 2, 'c']
    >>> list(map(lambda x: x*2 if type(x) == type(int()) else x, L))
    [2, 'a', 4, 'c']

Python3 的 `map()` 函数默认返回生成器，所以需要用 `list()` 函数将它转化为列表。这里传给 `map()` 函数的处理方法，使用的是 `lambda` 表达式生成的匿名函数，也可以将一个普通函数或者方法传给 `map()` 使用，比如：

    >>> list(map(chr,[68,69,88]))
    ['D', 'E', 'X']


#### filter

语法：`filter(function, iterable)`

`filter()` 函数用于过滤序列，过滤掉不符合条件的元素，返回由符合条件元素组成的新列表。Python3 的 `filter()` 也是返回一个生成器。

示例：

过滤掉列表中的偶数，只保留奇数

    >>> list(filter(lambda x: x%2,range(10)))
    [1, 3, 5, 7, 9]

当处理函数返回 `True` 时，列表元素会留下，返回 `False` 时，列表元素会被丢弃。1 会被作为 `True`，0 会被作为 `False`。

#### reduce

语法：`reduce(function, iterable[, initializer])`

`reduce()` 函数会对参数序列中元素进行累积。`reduce()` 函数默认会先将迭代器的第一个和第二个元素传入 `function` 中来求值，之后将得到的新值和迭代器的第三个元素传入 `function` 中继续求值，直到迭代器遍历完毕后汇总结果。`initializer` 参数是一个可选参数，如果提供了此参数，则 `reduce()` 函数会直接将它的值作为运算的初始值与迭代器的第一个元素传入 `function` 中。

Python3 的 `reduce()` 不再是默认全局空间的了，用的时候需要先导入。

示例：

计算 1 到 100 的和

    >>> from functools import reduce
    >>> reduce(lambda x,y: x+y, range(1,101))
    5050
    >>> reduce(lambda x,y: x+y, range(1,101),100)
    5150


题外话：理解了 Python 中的 `map()` 和 `reduce()` 函数，也很容易理解 Hadoop 中的 MapReduce 计算模型了。

### 对字符串进行操作

#### 使用正则来分割字符串

对字符串的分割通常是使用字符串的 `split()` 方法，但是这个方法有个局限就是每次只能按照一种分隔符来进行分割，而使用 `re.split()` 则可以使用正则表达式来进行分割。

    >>> import re
    >>> s = 'abc 123;def,oe2'
    >>> re.split(r'\s|;|,', s)
    ['abc', '123', 'def', 'oe2']


#### 字符串开头或结尾匹配

可能经常需要对一个url的协议头进行检测，或者对一个文件名的后缀进行检测，最简单的方法就是使用 `str.startswith()` 和 `str.endswith()` 方法了。

    >>> url = ['http://127.0.0.1/','ftp://127.0.0.1/']
    >>> fname = ['hello.py', 'hi.c', 'hi.py', 'hi.js']
    >>> [s for s in url if s.startswith('http:')]
    ['http://127.0.0.1/']
    >>> [s for s in fname if s.endswith(('c','js'))]
    ['hi.c', 'hi.js']

需要注意的是，如果想匹配多个字符串开头或结尾，必须将多个匹配项放到元组内。

#### 字符串匹配和搜索

如果只是简单的匹配或者搜索字符串中特定的字符串，使用 `str` 类型的 `find()` 方法就可以了，但是如果想要完成更复杂的搜索，就要使用正则表达式了，Python的 `re` 模块提供了对正则表达式的支持

    >>> import re, os
    >>> reg = re.compile(r'inet addr:(.*?)\s', re.S)
    >>> re.findall(reg, os.popen('ifconfig em1').read())
    ['192.168.4.6']

#### 字符串搜索和替换

对于简单的字符串替换，可以使用 `str.replace()` 方法。

    >>> text = 'yeah, but no, but yeah, but no, but yeah'
    >>> text.replace('yeah', 'yep')
    'yep, but no, but yep, but no, but yep'

对于复杂的替换可以使用 `re.sub()` 函数。

    >>> text = 'Today is 11/27/2012. PyCon starts 3/13/2013.'
    >>> import re
    >>> re.sub(r'(\d+)/(\d+)/(\d+)', r'\3-\1-\2', text)
    'Today is 2012-11-27. PyCon starts 2013-3-13.'

如果想要忽略大小写的替换，可以在使用 `re` 模块的时候给这些操作提供 `re.IGNORECASE` 标志参数。

    >>> text = 'UPPER PYTHON, lower python, Mixed Python'
    >>> re.findall('python', text, flags=re.IGNORECASE)
    ['PYTHON', 'python', 'Python']
    >>> re.sub('python', 'snake', text, flags=re.IGNORECASE)
    'UPPER snake, lower snake, Mixed snake'

对于文本搜索，难点在于正则表达式的编写。

#### 删除字符串头尾部不需要的字符

`strip()` 方法能用于删除开始或结尾的字符。 `lstrip()` 和 `rstrip()` 分别从左和从右执行删除操作。 默认情况下，这些方法会去除空白字符，但是也可以指定其他字符。

    >>> s = ' hello world \n'
    >>> s.strip()
    'hello world'
    >>> s.lstrip()
    'hello world \n'
    >>> s.rstrip()
    ' hello world'
    >>>
    >>> t = '-----hello====='
    >>> t.lstrip('-')
    'hello====='
    >>> t.strip('-=')
    'hello'

#### 字符串对齐

在终端上打印长短不一的字符串时这个可能非常有用，对字符串的对其方法，可以使用字符串的 `ljust()` , `rjust()` 和 `center()` 方法

```python
print('id'.ljust(10),'name'.ljust(10),'age'.ljust(10),sep='')
print('-'*23)
print('1'.ljust(10),'Tom'.ljust(10),'20'.ljust(10),sep='')
print('2'.ljust(10),'Jack'.ljust(10),'21'.ljust(10),sep='')
print('3'.ljust(10),'Alan'.ljust(10),'19'.ljust(10),sep='')
```

输出：

    [root@localhost ~]# python3 test.py
    id        name      age       
    -----------------------
    1         Tom       20        
    2         Jack      21        
    3         Alan      19     

这些方法都能接受一个可选的填充字符参数

    >>> a = 'Tom'
    >>> a.center(10,'*')
    '***Tom****'

或者还可以使用更强大的内建函数 `format()`。

#### 字符串拼接

字符串拼接除了使用 `+` 号连接两个字符串，还有效率更高更快的 `join()` 方法， `join()` 适用于要拼接的字符串在一个可迭代对象中。

    >>> parts = ['Is', 'Chicago', 'Not', 'Chicago?']
    >>> ' '.join(parts)
    'Is Chicago Not Chicago?'
    >>> ','.join(parts)
    'Is,Chicago,Not,Chicago?'
    >>> ''.join(parts)
    'IsChicagoNotChicago?'

#### 字符串插入变量

可能经常会遇到动态生成字符串的场景，Python 提供了多种方式来实现这种需求

使用字符串拼接：

    >>> s = 'Monday'
    >>> 'Today is ' + s
    'Today is Monday'


使用占位符：

    >>> s = 'Hi, %s is %s'
    >>> s % ('Today', 'Monday')
    'Hi, Today is Monday'

使用 `str.format()` 函数：

    >>> info = 'Name: {name}, Age: {age}'
    >>> info.format(name='Tom', age=20)
    'Name: Tom, Age: 20'

使用格式化字符串（Python 3.6 +）

    >>> name,age = 'Tom',20
    >>> f'Name: {name}, Age: {age}'
    'Name: Tom, Age: 20'

#### 像操作文件一样操作字符串

使用 `io.StringIO()` 和 `io.BytesIO()` 类来创建类文件对象操作字符串数据

    >>> s = io.StringIO()
    >>> s.write('Hello World\n')
    12
    >>> print('This is a test', file=s)
    15
    >>> # Get all of the data written so far
    >>> s.getvalue()
    'Hello World\nThis is a test\n'
    >>> # Wrap a file interface around an existing string
    >>> s = io.StringIO('Hello\nWorld\n')
    >>> s.read(4)
    'Hell'
    >>> s.read()
    'o\nWorld\n'
    >>>

`io.StringIO` 只能用于文本。如果你要操作二进制数据，要使用 `io.BytesIO` 类来代替

### 对列表/字典等操作

#### 对字典的值进行排序

内置函数 `sorted()` 支持对可迭代对象的元素进行排序，并将结果作为列表返回。如果排序的元素也是一个可迭代对象，则可以指定使用这个元素的某个项进行排序。

    >>> d = {'a':10,'b':8,'c':11}
    >>> sorted(d.items(), key=lambda x:x[1])
    [('b', 8), ('a', 10), ('c', 11)]

或者下面这样也可以，只不过只返回了键

    >>> sorted(d, key=lambda k:d[k])
    ['b', 'a', 'c']


同理，使用这个方法也可以找出字典的最小值和最大值，但是还有更好的方法。

#### 字典的最大值和最小值

 `min()` 和 `max()` 函数可以快速得出一个可迭代对象的最小值和最大值，如果只是想简单的知道字典中的最大值或者最小值，调用字典的 `values()` 方法，然后通过 `min()` 或者 `max()` 进行计算就解决了，但是显然就无法得出这个最大值的键了。

`min()` 和 `max()` 函数也提供有 `key` 参数，使用上和 `sorted` 相同。

    >>> d = {'a':10,'b':8,'c':11}
    >>> min(d, key=lambda k:d[k])
    'b'
    >>> max(d, key=lambda k:d[k])
    'c'
    >>> max(d.items(), key=lambda d:d[1])
    ('c', 11)

#### 去除列表/字典中的重复元素/值

去除列表重复元素可以使用 `set()` 函数将列表转换为集合，其中重复的值就去掉了，但是这样也将丢失列表元素的顺序，而且也并不适合字典类型的数据。我们可以模仿 `sorted()` 函数来自己写一个完成需求的函数。

```python
def dedupe(items, key=None):
    seen = set()
    for item in items:
        val = item if key is None else key(item)
        if val not in seen:
            yield item
            seen.add(val)
```

    >>> d = {'a':10,'b':8,'c':11,'d':8}
    >>> l = [2,1,3,1,2]
    >>> list(dedupe(d, lambda x:d[x]))
    ['a', 'b', 'c']
    >>> list(dedupe(l))
    [2, 1, 3]



#### 快速找到字典公共键

可以利用集合的特性，计算多个字典键的交集即可。

    >>> d1 = {'a':1,'c':2,'f':3}
    >>> d2 = {'a':2,'c':4,'d':3}
    >>> d3 = {'b':2,'e':4,'c':3}
    >>> set(d1.keys()) & set(d2.keys()) & set(d3.keys())
    {'c'}
    >>> d1.keys() & d2.keys() & d3.keys()
    {'c'}

集合之间可以进行 `-`（差集），`&`（交集），`|`（并集）计算。

如果字典比较多，还可以使用 `map()` 和 `reduce()` 来处理

    >>> from functools import reduce
    >>> reduce(lambda x,y:x&y, map(dict.keys, [d1,d2,d3]))
    {'c'}

#### 给切片一个名字

如果程序里需要用到大量的切片，这样会很严重的降低程序的可读性。但是如果给切片范围起一个名字，代码就更清晰可读了。

使用 `slice()` 函数创建一个切片对象，可以被用在任何切片允许的地方

    >>> INFO = "00:50:56:C0:00:08-192.168.198.1"
    >>> mac = slice(None,17)
    >>> ip = slice(18,None)
    >>> INFO[mac]
    '00:50:56:C0:00:08'
    >>> INFO[ip]
    '192.168.198.1'


## 标准库

### 数据结构处理

#### collections 数据类型容器

##### collections.namedtuple

Python中普通的 `tuple` 数据类型的元素是不可修改的，而且 `tuple` 的长度是不可变的，因此 `tuple` 的资源消耗少于 `list`。`tuple` 的元素访问只能通过索引，而在程序中通过索引访问元素的代码可读性太差，而 `collections.namedtuple` 则拓展了 `tuple` 的能力，允许以面向对象的方式访问其中的元素，而且资源消耗却跟 `tuple` 差不多。

示例：

    >>> from collections import namedtuple
    >>> Student = namedtuple('Student',['name','age','sex'])
    >>> s = Student(name='Tom',age=16,sex='boy')
    >>> s
    Student(name='Tom', age=16, sex='boy')
    >>> s[0]
    'Tom'
    >>> s.name
    'Tom'
    >>> isinstance(s, tuple)
    True

可以看到 `namedtuple` 类型是 `tuple` 类型的子类。任何可以使用 `tuple` 的地方就可以使用 `namedtuple`


##### collections.OrderedDict

Python的默认 `dict` 类型是无序的，使用 `OrderedDict` 则可以实现有序的字典。

注意：Python3.6 换了种 `dict` 类型的实现方式，所以 Python3.6 的字典变成有序的了，但是使用 `OrderedDict` 可以确保在之前支持 `OrderedDict` 的版本中创建有序字典。

    >>> from collections import OrderedDict
    >>> d = OrderedDict(c=1,b=2,a=3)
    >>> d.keys()
    odict_keys(['c', 'b', 'a'])
    >>> isinstance(d,dict)
    True

`OrderedDict` 是 `dict` 类型的子类，使用 `dict` 类型的地方也完全可以使用 `OrderedDict`


##### collections.deque

`collections.deque` 是一个双端队列。顾名思义 `deque` 提供了在队列两端插入和删除的操作，如果创建 `deque` 对象的时候指定了队列长度，当队列满了从一端继续插入元素的时候，另一端的元素就会被移除。如果没有指定队列长度，就可以在两端无限插入元素了，当然前提是内存够用。

    >>> import collections
    >>> d = collections.deque(maxlen=3)   
    >>> d.append(1)
    >>> d.append(2)
    >>> d.append(3)
    >>> d
    deque([1, 2, 3], maxlen=3)
    >>> d.append(4)
    >>> d
    deque([2, 3, 4], maxlen=3)
    
`deque` 对象的 `rotate` 方法比较有意思，相当于从队列右边弹出几个元素插入到左边来。下面看一个有趣的小例子，模拟一个无限循环的进度条。

```python
import sys
import time
from collections import deque
loading = deque('>--------------------')
while True:
    sys.stdout.write('\r[%s]' % ''.join(loading))
    loading.rotate(1)
    sys.stdout.flush()
    time.sleep(0.1)
```

Python的 `list`（列表）对象不也提供了两端插入或者删除元素的方法吗，但是 `deque` 在两端插入或删除的时间复杂度是 `O(1)`，而 `list` 是 `O(N)`。

##### collections.Counter

`Counter` 工具用于支持便捷和快速地统计可迭代对象中每个元素出现的次数，而且速度非常快。

快速的统计一个文本中，出现次数最多的三个字符

    >>> from collections import Counter
    >>> c = Counter(open('abc.txt').read())
    >>> c.most_common(3)
    [('，', 312256), (' ', 296920), ('的', 180567)]


`Counter` 是 `dict` 类型的子类，以迭代器的每个元素为键，元素出现的次数为值。

##### collections.ChainMap

当需要从多个字典中执行某些操作，比如检测某些键或值是否存在，使用 `ChainMap` 函数可以将多个字典逻辑上合并为一个字典。

    >>> from collections import ChainMap
    >>> a = {'x': 1, 'z': 3 }
    >>> b = {'y': 2, 'z': 4 }
    >>> c = ChainMap(a,b)
    >>> print(c['x'],c['y'],c['z'])
    1 2 3
    >>> del c['z']
    >>> c['z']
    4
    >>> a
    {'x': 1}


如果出现重复键，第一次找到的键被返回，如果对新产生的字典做操作，更改也会映射到原来的字典上去。如果只考虑合并两个字典，可以使用字典的 `update` 方法。

#### heapq 堆队列算法

##### 实现排序

堆是一个二叉树，其中每个父节点的值都小于或者等于其所有子节点的值。整个堆的最小元素总是位于二叉树的根节点。Python 的 `heapq` 模块提供了对堆的支持。

如何获取一个无序列表最大的十个元素和最小的十个元素呢，这里试试使用 `list` 数据类型的实现和使用 `heapq` 的实现。

`list` 的实现
```python
import time
import random
L = [random.randint(1,10000000) for x in range(5000000)]
now = time.time()
L.sort()
print('Max: %s' % L[-10:])
print('Min: %s' % L[:10])
print('Used time: %s sec' % str(time.time()-now))
```

结果：

    Max: [9999984, 9999989, ...... , 9999998, 9999999]
    Min: [2, 2, 3, 5, 5, 7, 10, 12, 14, 16]
    Used time: 5.01489806175 sec


`heapq` 的实现
```python
import time
import heapq
import random
L = [random.randint(1,10000000) for x in range(5000000)]
now = time.time()
print('Max: %s' % heapq.nlargest(10, L))
print('Min: %s' % heapq.nsmallest(10, L))
print('Used time: %s sec' % str(time.time()-now))
```

结果：

    Max: [10000000, 9999999, ...... , 9999989, 9999988]
    Min: [2, 6, 7, 7, 8, 8, 8, 10, 11, 13]
    Used time: 1.21054005623 sec


##### 实现一个优先级队列

先看这样一个例子：

    >>> a = []
    >>> heapq.heappush(a,[-2,2,'a'])
    >>> heapq.heappush(a,[-1,5,'b'])
    >>> heapq.heappush(a,[-1,3,'c'])
    >>> a
    [[-2, 2, 'a'], [-1, 5, 'b'], [-1, 3, 'c']]
    >>> heapq.heappop(a)
    [-2, 2, 'a']
    >>> heapq.heappop(a)
    [-1, 3, 'c']
    >>> heapq.heappop(a)
    [-1, 5, 'b']

使用 `heappush` 向一个队列中插入一个列表元素，先使用列表的第一个元素来排序，如果第一个元素相同，则使用第二个元素排序，如果只有一个字母的话，将使用 ASCII 码进行排序。

利用这个特性，可以使用 `heapq` 来实现一个优先级队列，下面看代码：

```python
import heapq

class PriorityQueue:
    def __init__(self):
        self._queue = []
        self._index = 0

    def push(self, item, priority):
        heapq.heappush(self._queue, (-priority, self._index, item))
        self._index += 1

    def pop(self):
        return heapq.heappop(self._queue)[-1]
```

`push` 方法中传入元素和它的优先级，因为 `heapq` 中值越小的就越在队列开头，所以插入到队列的时候要将优先级取负数。而 `_index` 的作用就是如果出现优先级相同的元素，就根据这个值来排序，而每插入一个元素，`_index` 的值都会增加1，所以后面插入的元素优先级就小于之前插入的元素了。

接下来看看效果如何：

    >>> q = PriorityQueue()
    >>> q.push('Bob', 2)
    >>> q.push('Tom', 8)
    >>> q.push('Jack', -5)
    >>> q.pop()
    'Tom'
    >>> q.pop()
    'Bob'
    >>> q.pop()
    'Jack'

Tom 的优先级最高，所以 Tom 被最先弹出了，一个简单的优先级队列就完成了。如果需要在多个线程中使用同一个队列，可以加入锁和信号量机制。

#### operator 内置操作符的函数接口

##### operator.itemgetter

如果有一个字典列表，想根据某个或某几个字典字段来排序这个列表。通过使用 `operator` 模块的 `itemgetter` 函数，可以非常容易的排序这样的数据结构。

    >>> from operator import itemgetter
    >>> rows = [
    ...     {'id':1000, 'name':'Tom', 'age': 18},
    ...     {'id':1001, 'name':'Jack', 'age': 20},
    ...     {'id':1003, 'name':'Mei', 'age': 17},
    ...     {'id':1002, 'name':'Li', 'age': 17},
    ... ]
    >>> sorted(rows, key=itemgetter('name'))
    [{'id': 1001, 'name': 'Jack', 'age': 20},
     {'id': 1002, 'name': 'Li', 'age': 17},
     {'id': 1003, 'name': 'Mei', 'age': 17},
     {'id': 1000, 'name': 'Tom', 'age': 18}]
    >>> sorted(rows, key=itemgetter('id'))
    [{'id': 1000, 'name': 'Tom', 'age': 18},
     {'id': 1001, 'name': 'Jack', 'age': 20},
     {'id': 1002, 'name': 'Li', 'age': 17}, 
     {'id': 1003, 'name': 'Mei', 'age': 17}]


`itemgetter` 函数也支持多个 `keys`，比如下面的代码，如果 `age` 相同的情况下，则按照 `id` 来排序

    >>> sorted(rows, key=itemgetter('age','id'))
    [{'id': 1002, 'name': 'Li', 'age': 17}, 
     {'id': 1003, 'name': 'Mei', 'age': 17},
     {'id': 1000, 'name': 'Tom', 'age': 18},
     {'id': 1001, 'name': 'Jack', 'age': 20}]


也可以使用 `sorted()` 和 `lambda` 表达式实现上面的效果，比如

    >>> sorted(rows, key=lambda r:(r['age'],r['id']))
    [{'id': 1002, 'name': 'Li', 'age': 17},
     {'id': 1003, 'name': 'Mei', 'age': 17},
     {'id': 1000, 'name': 'Tom', 'age': 18},
     {'id': 1001, 'name': 'Jack', 'age': 20}]

但是效率可能要比 `itemgetter` 慢一些。


##### operator.attrgetter

`itemgetter` 是获取字典的每一项，如果是将数据保存在对象实例的属性中，则可以使用 `attrgetter` 来获取

```python
from operator import attrgetter
class User():
    def __init__(self,id,name,age):
        self.id,self.name,self.age = id,name,age
    def __repr__(self):
        return 'User(id=%s, name=%s, age=%s)' % (self.id,self.name,self.age)

users = [User(1000,'Tom',18),User(1001,'Jack',20),
         User(1003,'Mei',17),User(1002,'Li',17)]
sorted(users, key=attrgetter('id'))
sorted(users, key=attrgetter('age','id'))
```

输出：

    >>> sorted(users, key=attrgetter('id'))
    [User(id=1000, name=Tom, age=18), User(id=1001, name=Jack, age=20),
     User(id=1002, name=Li, age=17), User(id=1003, name=Mei, age=17)]
    >>> sorted(users, key=attrgetter('age','id'))
    [User(id=1002, name=Li, age=17), User(id=1003, name=Mei, age=17), 
     User(id=1000, name=Tom, age=18), User(id=1001, name=Jack, age=20)]

同理，如果不想用 `attrgetter` 也可以自己用 `lambda` 实现功能。


#### itertools 操作迭代对象的库

##### itertools.groupby

如果有一个包含字典或者对象实例的列表，想根据某个字段进行分组迭代访问，可以使用 `groupby` 函数。

```python
rows = [
    {'id':1000, 'name':'Tom', 'age': 18},
    {'id':1001, 'name':'Jack', 'age': 20},
    {'id':1003, 'name':'Mei', 'age': 17},
    {'id':1002, 'name':'Li', 'age': 17},
    {'id':1004, 'name':'Ani', 'age': 20}
]
```

首先需要排序，然后才可以分组

```python
from operator import itemgetter
from itertools import groupby
rows.sort(key=itemgetter('age'))
for age,items in groupby(rows, key=itemgetter('age')):
    print('age = %s:' % age)
    for i in items:
        print('  ',i)
```

输出：

    age = 17:
      {'id': 1003, 'name': 'Mei', 'age': 17}
      {'id': 1002, 'name': 'Li', 'age': 17}
    age = 18:
      {'id': 1000, 'name': 'Tom', 'age': 18}
    age = 20:
      {'id': 1001, 'name': 'Jack', 'age': 20}
      {'id': 1004, 'name': 'Ani', 'age': 20}


### 文件处理

#### 固定大小的文件迭代

如果有个文本文件，迭代文件对象最好是按行读取，但如果是二进制文件，则最好是每次读取固定大小的字节。

`iter()` 函数有个不常用的用法是如果传入了两个参数，第一个参数必须是一个可调用对象，第二个参数是结束标志，如果迭代过程中遇到了这个结束标志，迭代就结束了。可以利用这个性质来实现文件按固定字节读取。

    >>> f = open('/bin/bash','rb')
    >>> i = iter(lambda :f.read(10), b'')
    >>> next(i)
    b'\x7fELF\x02\x01\x01\x00\x00\x00'
    >>> next(i)
    b'\x00\x00\x00\x00\x00\x00\x02\x00>\x00'
    >>> next(i)
    b'\x01\x00\x00\x00`\x05B\x00\x00\x00'

#### gzip/bz2 文件解压缩

`gzip` 和 `bz2` 为Python提供了对文件进行 `gz` 和 `bz2` 格式的解压缩。

文件压缩：

    >>> import gzip
    >>> f = gzip.open('/tmp/test.gz','wt')
    >>> f.write('Hello gzip')
    10
    >>> f.close()

`gzip.open()` 和 `open()` 函数一样，根据文件模式来判断对文件的读写方式，如果对文本文件压缩，使用 `wt` 文件模式，读取压缩文件使用 `rt` 文件模式。

文件解压：

    >>> import gzip
    >>> f = gzip.open('/tmp/test.gz','rt')
    >>> f.read()
    'Hello gzip'

`bz2` 和 `gzip` 的使用方式一致。压缩文件的时候还可以传入一个压缩等级的参数 默认是 `compresslevel=9`，打开的文件可以是一个文件名，也可以是一个类文件对象上，比如一个套接字对象、一个管道等。

#### mmap 内存映射文件

对文件修改的场景还是经常遇到的，但是如果要修改一个非常大的文件，传统的读取文件，修改文件，写回文件的方式就非常不合适了。


## 第三方库

### chatdet

### pyinstaller

### gevent

### bottle

### gunicorn

## 附录

参考资料：
+ [Python3-cookbook](http://python3-cookbook.readthedocs.io/zh_CN/latest/)
+ [Python3.6 官方文档](https://docs.python.org/3.6/library/)