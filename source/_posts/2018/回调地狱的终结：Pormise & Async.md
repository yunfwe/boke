---
title: 回调地狱的终结：Pormise & Async
date: 2018-12-31
updated: 2018-12-31
categories: 
    - JavaScript
tags:
    - javascript
photos:
    - /uploads/photos/s8fae3f3a.jpg
---

## 简介
> 由于 JavaScript 是一门单线程，事件驱动的语言，因此异步编程方式是它一个非常重要的特性。无论是客户端的 JavaScript 还是服务端的 JavaScript 在处理 HTTP请求响应、事件监听、文件读取等操作时都避不开回调，如果异步的事件需要嵌套执行，那么回调给代码结构和可读性简直带来了灾难，这个被后人称之为：回调地狱。

## 环境
> 由于浏览器环境不支持 async/await 这些 ES8 提案才支持的语法，因此 JavaScript 执行环境选择 Node.js。浏览器不支持包含 ES7/ES8 的语法特性的代码，可以通过 Babel 等工具转为低版本 JavaScript 语法运行。

| 软件     | 版本       |
| -------- | ---------- |
| 操作系统 | Windows 10 |
| Node.js  | v10.13.0   |


## 教程

### 经典回调问题

JavaScript 中对异步事件处理是通过给异步事件传递处理函数的方式，也就是回调（callback）来完成，下面看一个例子：

```javascript
const fs = require("fs")
/* 
    以 utf-8 编码打开当前目录下 aaa.txt 文件。
    如果回调函数执行失败，则打印失败原因，否则打印文件内容。
*/
fs.readFile("aaa.txt", "utf-8", function(err, data){
    if (err) {
        console.log(err.message)
    } else {
        console.log(data)
    }
})
```

这是一个经典的 JavaScript 处理异步事件的方法，我们将对数据的后续处理写成函数传递给 `fs.readFile` 方法，文件读取成功后 `fs.readFile` 会自动调用我们传递给它的函数。

现在我们需要进行秩序的读取三个甚至更多的文件，只有在 `aaa.txt` 读取完成后再继续读取 `bbb.txt`，接着再读取 `ccc.txt`。传统的解决方案应该会写出下面的代码：

```javascript
const fs = require("fs")
/* 
    以 utf-8 编码打开当前目录下 aaa.txt 文件。
    如果回调函数执行失败，则打印失败原因，否则打印文件内容。
*/
fs.readFile("aaa.txt", "utf-8", function(err, data){
    if (err) {
        console.log(err.message)
    } else {
        console.log(data)
    }
    // 继续读取 bbb.txt
    fs.readFile("bbb.txt", "utf-8", function(err, data){
        if (err) {
            console.log(err.message)
        } else {
            console.log(data)
        }
        // 继续读取 ccc.txt
        fs.readFile("ccc.txt", "utf-8", function(err, data){
            if (err) {
                console.log(err.message)
            } else {
                console.log(data)
            }
        })
    })
})
```

如果还要继续读取更多的文件，并对文件内容进行操作，那之后的代码也都要写在回调函数中，会造成嵌套越来越多。这样对代码的可读性和日后的维护都带来了很大挑战。

随着 JavaScript 能干的事情越来越多，人们已经不满足只用它来处理一些简单的事情了，当随着代码越来越多，项目工程越来越大，JavaScript 的不断发展中，势必会寻找一些解决方案来应对这些问题。

之前最流行的是 2009 年 12 月发布的 ES5 标准，终于在 2015 年的 6 月 ES6 发布了，这是个历经 6 年沉淀出的版本，给 JavaScript 带来了大量的新特性并保持了向下的兼容，其中对异步回调地狱的解决方案：`Promise` 就是这个版本带来的特性之一。

JavaScript 设计时的缺陷，历史包袱等原因，后面新的版本带来新特性的同时，又要对之前代码保持兼容，现在 JavaScript 各种功能重复又不相同的 API 也让人一言难尽。。。

### 当代的 Promise

`Promise`：承诺的意思，你可以通过 `Promise` 封装一个异步事件，并且在事件创建后再将回调函数传递给 `Promise`，而 `Promise` 则向你承诺异步事件有结果的时候，会调用之后传给 `Promise` 的处理函数。而传统的回调，是在事件创建之初就一并将回调函数传递过去的。

#### Promise 基本概念

在浏览器环境或者 Node.js 环境中，`Promise` 是一个全局的构造函数。`Promise` 构造函数接受一个函数作为参数，我们需要封装的异步事件，就是写在这个函数中的。这个函数的主要作用只是为了封装异步事件为一个 `Promise` 对象，那么异步事件的正常结果和异次结果又该如何处理呢？

答案是这个函数会接收两个函数作为参数，一个用来处理正常结果的，一个用来处理异次结果。大致样子如下：

```javascript
let promise = new Promise(function(resolve, reject){
    if (/* 异步操作成功 */) {
        resolve(data)
    } else {
        reject(err)
    }
})
```

`resolve` 和 `reject` 这里都只是形参，当一个 `Promise` 对象创建的时候，传递的函数就立即执行了。函数的执行会产生三种状态：`pending`、`fulfilled`、`rejected`。

+ `pending`：异步事件初始化，还没有结果的时候。
+ `fulfilled`：在函数中调用 `resolve` 方法后将触发 `Promise` 对象的状态更改为 `fulfilled`，表示异步事件正常结束。
+ `rejected`：当异步事件抛出异常时，我们调用这个函数将触发 `Promise` 对象的状态更改为 `rejected`，表示异步事件异常结束。

之后我们就可以给 `Promise` 绑定 `fulfilled` 和 `rejected` 状态的回调函数了，我们通过 `Promise.prototype.then()` 函数来将 `fulfilled` 和 `rejected` 状态的处理函数传递进去：

```javascript
promise.then(function(data){
    // 当 Promise 的状态变为 fulfilled 的时候执行的回调
    console.log(data)
}, function(err){
    // 当 Promise 的状态变为 rejected 的时候执行的回调
    console.log(err)
})
```

在封装 `Promise` 对象中通过 `resolve(data)` 可以将异步事件返回的数据传递出去，然后由 `.then()` 的第一个回调函数来接收，因此我们就可以将对异步事件结果的处理过程写在 `.then()` 的第一个回调函数中了。同理，对异常结果的处理在 `.then()` 的第二个回调函数中处理。

如果不需要对异常情况进行处理，对异常处理的回调函数在 `.then()` 中是可以省略的，也就是说，可以只给 `.then()` 传递一个正常结果处理的回调即可。

#### Promise 初体验

说了这么多，现在就看看怎么把之前出现的读取文件的例子用 `Promise` 改造一下，看看和传统的回调嵌套有什么本质上的不同。

```javascript
const fs = require("fs")

let promise = new Promise(function(resolve, reject){
    fs.readFile("aaa.txt", "utf-8", (err, data)=>{
        /* 
            由于作用域的原因，如果给 readFile 的回调使用 function()，
            那么将无法访问 resolve 和 reject 方法了。
        */
        if (err) {
            reject(err)
        } else {
            resolve(data)
        }
    })
})

promise.then(function(data){
    // 处理成功读取到文件内容的回调函数
    console.log('文件内容：' + data)
},function(err){
    // 处理读取文件异常的回调函数
    console.log('失败原因：' + err.message)
})
```

当文件正常读取后的执行结果：

    C:\Users\yunfwe\Desktop>node app.js
    文件内容：Hello! this is aaa.txt

当文件不存在的执行结果：

    C:\Users\yunfwe\Desktop>node app.js
    失败原因：ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\aaa.txt'

结果与我们预料的相同，接下来读取多个文件，我们总不能为每个文件都单独写一串封装为 `Promise` 对象的代码吧，最好的做法是用一个构造函数，传给这个函数不同的文件名称，然后自动为我们返回一个封装好的 `Promise` 对象：

```javascript
function readFile(fileName) {
    return new Promise(function(resolve, reject){
        fs.readFile(fileName, "utf-8", (err, data)=>{
            /* 
                由于作用域的原因，如果给 readFile 的回调使用 function()，
                那么将无法访问 resolve 和 reject 方法了。
            */
            if (err) {
                reject(err)
            } else {
                resolve(data)
            }
        })
    })
}
```

我们创建了一个新的 `readFile` 函数，这个函数会根据不同的文件名，自动返回一个封装好的 `Promise` 对象。如果我们想并发的读取多个文件，大可以这样来写：

```javascript
readFile("aaa.txt").then(function(data){...})
readFile("bbb.txt").then(function(data){...})
readFile("ccc.txt").then(function(data){...})
```

但是这并不能满足我们读完 `aaa.txt` 再继续往下读取的意愿，那么我们可以让第一个文件的处理结束后，返回第二个文件的 `Promise` 对象，然后通过 `.then()` 进行链式调用的方法依次读取：

{% fold %}
```javascript
const fs = require("fs")

function readFile(fileName) {
    return new Promise(function(resolve, reject){
        fs.readFile(fileName, "utf-8", (err, data)=>{
            /* 
                由于作用域的原因，如果给 readFile 的回调使用 function()，
                那么将无法访问 resolve 和 reject 方法了。
            */
            if (err) {
                reject(err)
            } else {
                resolve(data)
            }
        })
    })
}

readFile("aaa.txt")
.then(function (data){
    // 处理 aaa.txt
    console.log('文件内容：' + data)
    return readFile("bbb.txt")
}, function (err){
    console.log('失败原因：' + err.message)
})
.then(function (data){
    // 处理 bbb.txt
    console.log('文件内容：' + data)
    return readFile("ccc.txt")
}, function (err){
    console.log('失败原因：' + err.message)
})
.then(function (data){
    // 处理 ccc.txt
    console.log('文件内容：' + data)
}, function (err){
    console.log('失败原因：' + err.message)
})
```
{% endfold %}

当文件都正常读取的情况下：

    C:\Users\yunfwe\Desktop>node app.js
    文件内容：Hello! this is aaa.txt
    文件内容：Hello! this is bbb.txt
    文件内容：Hello! this is ccc.txt

这中写法，即使我们要读取再多的文件，也只需要依次往下排列代码就行了，并不需要对代码进行嵌套，也更不存在回调地狱的问题了。但是如果遇到一个文件读取失败呢？可达鸭眉头一皱发现事情并不简单

`bbb.txt` 读取失败的情况：

    C:\Users\yunfwe\Desktop>node app.js
    文件内容：Hello! this is aaa.txt
    失败原因：ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'
    文件内容：undefined

因为 `bbb.txt` 不存在，所以 `Promise` 里触发了 `fulfilled` 状态，那么执行的就是错误处理的方法，然而在错误处理的方法中，我们并没有返回读取下一个文件的 `Promise` 对象。解决方法也很简单，就是在每一个 `Promise` 的异常处理函数中也返回下一个 `Promise`。。。

```javascript
readFile("aaa.txt")
.then(function (data){
    // 处理 aaa.txt
    console.log('文件内容：' + data)
    return readFile("bbb.txt")
}, function (err){
    console.log('失败原因：' + err.message)
    return readFile("bbb.txt")
})
.then(function (data){
    // 处理 bbb.txt
    console.log('文件内容：' + data)
    return readFile("ccc.txt")
}, function (err){
    console.log('失败原因：' + err.message)
    return readFile("ccc.txt")
})
.then(function (data){
    // 处理 ccc.txt
    console.log('文件内容：' + data)
}, function (err){
    console.log('失败原因：' + err.message)
})
```

结果：

    C:\Users\yunfwe\Desktop>node app.js
    文件内容：Hello! this is aaa.txt
    失败原因：ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'
    文件内容：Hello! this is ccc.txt

#### Promise 异常处理

正常情况下，一把都是有关联的异步操作才会使用 `Promise` 来链起来执行，因为下一个异步操作可能会依赖于上一个异步操作的结果，如果其中一个异步操作失败，那么剩下的就没继续执行下去的意义了。如果我们为每个 `Promise` 对象都指定了异常处理回调，链中的某一个 `Promise` 即使触发了异常，整个链依然会继续执行下去的，虽然结果并不是我们想要的。

我们更希望的是，当某一个 `Promise` 发生异常的时候，就立即终止整个 `Promise` 链的执行，我们可以统一使用 `Promise.prototype.catch()` 来捕获异常并终止整个链。

```javascript
readFile("aaa.txt")
.then(function (data){
    // 处理 aaa.txt
    console.log('文件内容：' + data)
    return readFile("bbb.txt")
})
.then(function (data){
    // 处理 bbb.txt
    console.log('文件内容：' + data)
    return readFile("ccc.txt")
})
.then(function (data){
    // 处理 ccc.txt
    console.log('文件内容：' + data)
})
.catch(function(err){
    console.log(err.message)
})
```

执行结果：

    C:\Users\yunfwe\Desktop>node app.js
    文件内容：Hello! this is aaa.txt
    ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'

`bbb.txt` 文件不存在，`.catch()` 捕获了这个异常并终止了接下来的执行。如果在 `.then()` 中产生的异常也会被 `.catch()` 捕获。

```javascript
readFile("aaa.txt")
.then(function (data){
    // 处理 aaa.txt
    console.log('文件内容：' + data)
    throw new Error("手动触发的异常")
    return readFile("bbb.txt")
})
.then(function (data){
    // 处理 bbb.txt
    console.log('文件内容：' + data)
    return readFile("ccc.txt")
})
.then(function (data){
    // 处理 ccc.txt
    console.log('文件内容：' + data)
})
.catch(function(err){
    console.log(err.message)
})
```

运行结果：

    C:\Users\yunfwe\Desktop>node app.js
    文件内容：Hello! this is aaa.txt
    手动触发的异常

因此一般总是建议在 `Promise` 的后面跟上一个 `.catch()` 来处理已知的或者意料之外的异常。当然，你依然可以在 `.catch()` 中也返回一个 `Promise` 对象，然后继续用 `.then()` 进行其他的逻辑处理。`Promise` 最直接的好处就是链式调用。

#### Promise 的其他用法

这里举例说明 `Pormise` 的几个其他常用的方法，其他更详细的 `Pormise` 用法可以查阅 MDN web docs：[Pormise](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Promise)

##### Pormise.all()

`Pormise.all()` 接收一个由多个 `Promise` 对象组成的数组，只有这个数据里所有的 `Promise` 对象都完成的时候才会去调用 `.then()` 方法，否则有一个失败，那么整体就是 `rejected`：

```javascript
const fs = require("fs")

function readFile(fileName) {
    return new Promise(function(resolve, reject){
        fs.readFile(fileName, "utf-8", (err, data)=>{
            if (err) {
                reject(err)
            } else {
                resolve(data)
            }
        })
    })
}

Promise.all([readFile("aaa.txt"), readFile("bbb.txt"), readFile("ccc.txt")])
.then(function(data){
    console.log(data)
})
.catch(function(err){
    console.log(err.message)
})
```

正常情况下返回的是个包含结果集的数组：

    C:\Users\yunfwe\Desktop>node app.js
    [ 'Hello! this is aaa.txt',
      'Hello! this is bbb.txt',
      'Hello! this is ccc.txt' ]

如果有一个异常，则会触发 `.catch()`：

    C:\Users\yunfwe\Desktop>node app.js
    ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'

##### Pormise.race()

与 `Pormise.all()` 用法相似，但是结果不同，`Pormise.race()` 中只要有一个 `Pormise` 对象率先改变状态（不管完成还是失败），那 `Pormise.race()` 之后 `.then()` 就都是对这一个改变状态了的 `Pormise` 的处理。

```javascript
Promise.race([readFile("aaa.txt"), readFile("bbb.txt"), readFile("ccc.txt")])
.then(function(data){
    console.log(data)
})
.catch(function(err){
    console.log(err.message)
})
```

`aaa.txt` 先完成读取，所以只返回了 `aaa.txt` 的数据：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt

判断一个文件是否存在比读取文件内容快得多，所以 `bbb.txt` 不存在的情况下率先改变成了 `rejected` 状态：

    C:\Users\yunfwe\Desktop>node app.js
    ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'

基于 `Pormise.race()` 的性质，我们可以给浏览器的 Ajax 请求添加超时的功能：

```javascript
Pormise.race([$ajax.get("/api"), new Promise(function()(resolve, reject){
        setTimeout(() => reject(new Error('request timeout')), 5000)
    })
])
```

这样如果 `$ajax` 没有在 5 秒之内完成的话，`setTimeout` 就会将状态率先改为 `rejected` 了。

### 未来的 Async

之所以说 `async` 是未来的，是因为 ES8 的标准才引入了 `async` 关键字，`async` 是 `Generator` 的语法糖，而 `Generator` 是 ES6 提供的一种异步编程解决方案。以后使用 `async` 越来越多一定是个趋势。

`async` 配合 `await` 可以让异步的代码看起来和同步的一样，并且可以使用 `try` 和 `catch` 来捕捉异步事件产生的异常。想了解这两个需要先熟悉什么是 `Generator`。

#### Generator

##### 基本用法

`Generator`（生成器）是用于将一个函数变成 `Generator` 函数，这种函数的执行过程和普通函数不太一样，普通函数使用 `return` 返回值，而 `Generator` 函数中还可以使用 `yield` 返回值，并且 `yield` 还可以在函数内使用多次。`return` 返回值后整个函数就完成执行了，而 `yield` 只表示这个函数暂停了，下一次继续驱动 `Generator` 函数运行的时候，就会从上次暂停的地方继续运行。下面看一个简单的例子：

```javascript
function* gen(){
    yield "hello"
    yield "world"
}
```

注意申明一个 `Generator` 函数和普通函数的不同，`Generator` 函数需要在 `function` 和函数名中间加上一个 `*`，加在哪里并不重要，`function *gen()` 和 `function*gen()` 都可以，但是推荐使用 `function* gen()` 这种方式。接着使用两个 `yield` 返回了两个字符串，下面看看如何运行这种函数：

    C:\Users\yunfwe\Desktop>node
    > function* gen(){
    ...     yield "hello"
    ...     yield "world"
    ... }
    undefined
    > let f = gen()
    undefined
    > f
    Object [Generator] {}
    > f.next()
    { value: 'hello', done: false }
    > f.next()
    { value: 'world', done: false }
    > f.next()
    { value: undefined, done: true }

我们运行 `gen()` 后，返回的是一个 `Generator` 类型的对象，然后调用这个对象的 `next` 方法，返回了一个普通对象，这个对象的 `value` 属性是第一个 `yield` 返回的值，第二个属性 `done` 表示这个 `Generator` 函数是否运行结束。当第三次执行 `f.next()` 的时候，因为已经没有 `yield` 可以执行了所以 `done` 的值变成了 `true`。

##### 创建一个整数列表

接下来使用一个小例子来更深入的了解下 `Generator` 函数的运行原理。我们编写一个 `range` 函数，传给它一个整数，然后返回从 0 到 传递的整数之间所有的整数，先看普通函数版本：

```javascript
function range(len){
    let l = []
    for (let i = 0; i < len; i++){
        l.push(i)
    }
    return l
}
```

运行结果：

    > range(5)
    [ 0, 1, 2, 3, 4 ]
    > range(10)
    [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

的确达到了我们的目的，但是这个函数有一个致命的缺陷，就是如果要生成的范围非常巨大，比如 `range(99999999999999)`

    > range(99999999999999)

    ==== JS stack trace =========================================

        0: ExitFrame [pc: 000003D44F75C5C1]
    Security context: 0x02931fb858a1 <JSObject>
        1: range [000002931FBA36F9] [repl:~1] [pc=000003D44F7622DB](this=0x01e40aa9ad49 <JSGlobal Object>,len=0x02931fbbdf59 <Number 1e+14>)
        2: /* anonymous */ [000002931FBBE1F9] [repl:1] [bytecode=000002931FBBDF81 offset=10](this=0x01e40aa9ad49 <JSGlobal Object>)
        3: InternalFrame [pc: 000003D44F70F0B6]
        4: EntryFrame [pc: 000003D44F709455]
        5: E...

    FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory

node 进程直接挂掉了，因为所有生成的数都在一个数组里保存，这个数组很容易就超过了堆内存的限制。而如果使用 `Generator` 函数，每一个值只会在调用的时候生成并返回，并且没有在函数内部保存这个值，那自然不会发生堆内存超出了：

```javascript
function* range(len){
    for (let i = 0; i < len; i++){
        yield i
    }
}
```

可以看到，因为缺少了对产生的值的保存，代码反而更精简了。那么怎么打印它所产生的值呢？总不能挨个执行 `next` 吧，ES6 新添了 `for ... of` 的语法，所有只要实现了 `Iterator` 接口的对象都可以使用这个语法来遍历，比如：

```javascript
let l = [3,2,1,'a','b','c']

// 使用 for ... of 遍历
for (let i of l){
    console.log(i)
}
// 输出：3 2 1 a b c

// 使用 for ... in 遍历
for (let i in l){
    console.log(i)
}
// 输出：0 1 2 3 4 5
```

`for ... of` 和 `for ... in` 最大的区别就是 `for ... of` 会直接将数组的值传递给了 `let i`，而 `for ... in` 将数组的索引传递给了 `let i`。我们的 `Generator` 函数也实现了 `Iterator` 接口所以也可以使用 `for ... of` 的方法来取值：

```javascript
function* range(len){
    for (let i = 0; i < len; i++){
        yield i
    }
}

for (let i of range(99999999999999)){
    console.log(i)
}
```

这时候屏幕开始疯狂输出了。。。

##### 给 Generator 对象传值

在 `Generator` 对象运行期间，我们还可以在外部通过 `next` 方法传递一些值给生成器内部，在生成器对象内部对传递进来的值进行处理，看下面例子：

```javascript
function* gen(){
    let w = yield "hello"
    console.log(w)
    yield w
}
```

在 `yield` 返回 `hello` 字符串后，我们用 `let w` 再保存 `yield` 接收到的值：

    > function* gen(){
    ...     let w = yield "hello"
    ...     console.log(w)
    ...     yield w
    ... }
    undefined
    > let g = gen()
    undefined
    > g.next()
    { value: 'hello', done: false }
    > g.next("world")
    world
    { value: 'world', done: false }
    > g.next("world")
    { value: undefined, done: true }

运行到 `let g = gen()` 的时候，创建了一个生成器对象 `g`，第一次 `g.next()` 的时候为什么我们没有传值进去呢？因为它运行到 `yield "hello"` 的时候就暂停函数了，如果这个时候传值进去，它也没办法处理。当第二次执行 `g.next("world")` 的时候，从上次暂停的地方继续运行，也就相当于开始运行 `let w = (yield)` 了，这时候通过 `next` 传递进去的值就由 `yield` 返回给内部的 `let w`，接着生成器继续运行到下一个 `yield w` 的时候，将 `w` 的值返回给外部调用者。再继续执行 `g.next("world")` 可内部已经没有 `yield` 语句进行接收传进去的值了，所以没法处理，生成器结束运行。

##### Generator 与 Pormise

利用生成器对象可以将值返回外部调用者并暂停，然后从外部接收值并继续运行到下一个 `yield` 的机制，配合 `Promise` 又能碰撞出什么样的火花呢？

回到之前需要顺序读取三个文件的问题，我们理想状态下，想要写出这样的代码：

```javascript
const fs = require("fs")

function readFile(fileName) {
    return new Promise(function(resolve, reject){
        fs.readFile(fileName, "utf-8", (err, data)=>{
            if (err) {
                reject(err)
            } else {
                resolve(data)
            }
        })
    })
}

function* gen(){
    let aaa = yield readFile("aaa.txt")
    console.log(aaa)
    let bbb = yield readFile("bbb.txt")
    console.log(bbb)
    let ccc = yield readFile("ccc.txt")
    console.log(ccc)
}
```

通过 `yield` 将程序的控制权交给外部，让外部处理 `readFile()` 返回的 `Promise` 对象，然后外部处理完成后将数据传递给 `yield`，生成器内部就可以直接获取到处理好的数据了，接着再处理其他文件的读取。

接下来我们该实现如何在外部启动并处理这个生成器，然后将生成器返回的 `Promise` 对象处理好后再传递给生成器：

```javascript
let g = gen()
g.next().value.then(function(data){
    g.next(data).value.then(function(data){
        g.next(data).value.then(function(data){
            g.next(data)
        })
    })
})
```

通过 `g.next().value` 获取到了生成器返回来的 `Promise` 对象，接着使用 `.then()` 方法处理读取文件完成后的数据通过 `g.next(data)` 传递回去并继续处理它返回的下一个 `Promise` 对象，于是就写出了这样的代码。先看看是否达到我们预期的效果了吧：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt
    Hello! this is bbb.txt
    Hello! this is ccc.txt

没问题，虽然外部处理生成器返回的 `Promise` 还是一团糟，但是生成器函数写的就像是同步代码那样了。接下来就是对外部处理生成器对象的方法进行优化了。我们可以发现，外部对 `g.next()` 的执行基于生成器用 `yield` 返回了多少次，我们可以用生成器返回对象的 `done` 属性来判断这个生成器是否结束，然后用递归的方法不断进行 `g.next(data)` 处理：

```javascript
function run(gen){
    let g = gen()
    function next(data){
        let result = g.next(data)
        if (result.done) return result.value
        result.value.then(function(data){
            next(data)
        })
    }
    next()
}
```

我们定义了一个 `run` 函数作为生成器函数的辅助函数，`run` 函数内部首先初始化了生成器对象，然后定义了一个 `next` 的函数，这个函数通过递归来控制生成器返回值和传递值，通过判断生成器是否已经完成来结束递归。接着我们通过 `run` 函数来启动 `gen` 生成器函数：

完整代码：
{% fold %}
```javascript
const fs = require("fs")

function readFile(fileName) {
    return new Promise(function(resolve, reject){
        fs.readFile(fileName, "utf-8", (err, data)=>{
            if (err) {
                reject(err)
            } else {
                resolve(data)
            }
        })
    })
}

function run(gen){
    let g = gen()
    function next(data){
        let result = g.next(data)
        if (result.done) return result.value
        result.value.then(function(data){
            next(data)
        })
    }
    next()
}

function* gen(){
    let aaa = yield readFile("aaa.txt")
    console.log(aaa)
    let bbb = yield readFile("bbb.txt")
    console.log(bbb)
    let ccc = yield readFile("ccc.txt")
    console.log(ccc)
}

run(gen)
```
{% endfold %}

执行结果：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt
    Hello! this is bbb.txt
    Hello! this is ccc.txt

我们还可以在 `run` 函数中通过 `catch` 来处理异常的情况，我们可以将异常传递进去，或者直接终止生成器：

```javascript
function run(gen){
    let g = gen()
    function next(data){
        let result = g.next(data)
        if (result.done) return result.value
        result.value.then(function(data){
            next(data)
        }).catch(function(err){
            next(err)  // 如果将err传递进去，则生成器继续运行
        })
    }
    next()
}
```

运行结果：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt
    { [Error: ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt']
    errno: -4058,
    code: 'ENOENT',
    syscall: 'open',
    path: 'C:\\Users\\yunfwe\\Desktop\\bbb.txt' }
    Hello! this is ccc.txt

`Generator` 已经有点好用了，那么还有没有更好用的方法呢？

#### async/await 闪亮登场

前面也有说到，`async` 是 `Generator` 的语法糖，`async` 就相当于将 `Generator` 函数，以及之前我们写的 `run` 这个辅助执行器融合到了一起。`await` 关键字只能用在 `async` 申明的函数中，意为等待一个异步操作完成。

##### 基本用法

上一节处理依次读取三个文件的 `gen` 和 `run` 方法，我们先用 `async` 和 `await` 改造一下，先体现一下它的用法：

```javascript
async function genAsync(){
    let aaa = await readFile("aaa.txt")
    console.log(aaa)
    let bbb = await readFile("bbb.txt")
    console.log(bbb)
    let ccc = await readFile("ccc.txt")
    console.log(ccc)
}
```

我们只是把申明 `Generator` 函数的 `*` 换成了在函数前面用 `async`，然后在需要等待异步操作完成的地方使用 `await` 代替了 `yield`，然后其他的什么辅助方法都不需要了，完整代码如下：

```javascript
const fs = require("fs")

function readFile(fileName) {
    return new Promise(function(resolve, reject){
        fs.readFile(fileName, "utf-8", (err, data)=>{
            if (err) {
                reject(err)
            } else {
                resolve(data)
            }
        })
    })
}

async function genAsync(){
    let aaa = await readFile("aaa.txt")
    console.log(aaa)
    let bbb = await readFile("bbb.txt")
    console.log(bbb)
    let ccc = await readFile("ccc.txt")
    console.log(ccc)
}

genAsync()
```

运行结果：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt
    Hello! this is bbb.txt
    Hello! this is ccc.txt

有没有觉得很棒！甚至我们都可以像写同步代码一样，通过 `try...catch` 来捕捉 `await` 产生的异常！

```javascript
async function genAsync(){
    let aaa = await readFile("aaa.txt")
    console.log(aaa)
    try {
        let bbb = await readFile("bbb.txt")
        console.log(bbb)
    } 
    catch (err) {
        console.log(err.message)
    }
    
    let ccc = await readFile("ccc.txt")
    console.log(ccc)
}
```
我们在可能出现异常的地方使用 `try...catch` 来捕捉，运行结果：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt
    ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'
    Hello! this is ccc.txt

异步代码写起来比以前舒服太多了，接下来就探究下 `async` 都帮我们做了什么吧！

##### async 函数

使用 `async` 申明的函数返回的是一个 `Promise` 对象，如果通过 `return` 返回值，相当于将 `Promise` 的状态变为了 `fulfilled` 状态，可以通过 `.then()` 来处理返回的数据。如果在 `async` 函数中抛出异常，相当于将 `Promise` 的状态变成了 `rejected`，可以通过 `.catch()` 来捕捉。

```javascript
async function f(){
    return "hello world"
}

f().then(function(data){
    console.log(data)
})

async function f1(){
    throw new Error("Error!")
}

f1().catch(function(err){
    console.log(err.message)
})
```
执行结果：

    C:\Users\yunfwe\Desktop>node async.js
    hello world
    Error!

##### await 命令

只有 `async` 函数内部才可以使用 `await` 命令。`await` 命令后面可以跟上一个 `Promise` 对象（或者定义了 `then` 方法的对象）或者其他类型的数据，如果是其他类型数据，`await` 会直接返回这个数据。

如果是 `Promise` 对象，当 `await` 后面的 `Promise` 对象的状态变成 `fulfilled`，`await` 将返回它的值。如果 `await` 后面的 `Promise` 对象的状态变成 `rejected`，`await` 会立即抛出一个异常，并结束 `async` 函数的运行，可以通过 `async` 函数的 `.catch()` 在外部来捕捉这个异常，或者直接用 `try...catch` 在内部捕捉 `await` 抛出的异常。

`await` 后面 `Promise` 状态为 `fulfilled` 的情况：

```javascript
async function f(){
    let d = await Promise.resolve("Done")
    console.log(d)
}

f()
```
运行结果：

    C:\Users\yunfwe\Desktop>node async.js
    Done

`await` 后面 `Promise` 状态为 `rejected` 的情况：

```javascript
async function f(){
    try {
        let d = await Promise.reject("Error!")
        console.log(d)
    } 
    catch (err) {
        console.log("Catch: " + err)
    }
}

f()
```

运行结果：

    C:\Users\yunfwe\Desktop>node async.js
    Catch: Error!

如果 `async` 内部没有捕捉到 `await` 抛出的异常，那么可以在 `async` 函数外部通过 `.catch()` 方法捕捉：

```javascript
async function f(){
    try {
        let d = await Promise.reject("Error!")
        console.log(d)
    } 
    catch (err) {
        console.log("Catch: " + err)
    }
    await Promise.reject("New Error!")
}

f().catch(function(err){
    console.log(err)
})
```

运行结果：

    C:\Users\yunfwe\Desktop>node async.js
    Catch: Error!
    New Error!

如果 `async` 内部多个 `await` 等待异步结果，只要有一个 `await` 抛出了异常没被捕捉，那么整个 `async` 函数就立即停止运行了，我们继续改造之前读取文件的例子：

```javascript
async function genAsync(){
    let aaa = await readFile("aaa.txt")
    console.log(aaa)
    let bbb = await readFile("bbb.txt")
    console.log(bbb)
    let ccc = await readFile("ccc.txt")
    console.log(ccc)
}

genAsync().catch(function(err){
    console.log(err.message)
})
```

可以看到，`bbb.txt` 不存在的情况下，如果没有捕捉这个异常，`genAsync` 就 `rejected` 了。运行结果：

    C:\Users\yunfwe\Desktop>node app.js
    Hello! this is aaa.txt
    ENOENT: no such file or directory, open 'C:\Users\yunfwe\Desktop\bbb.txt'


## 附录

这是 2018 年最后一篇博客，特此纪念一下 (￣▽￣)"

### 参考文档

+ [Promise](http://es6.ruanyifeng.com/#docs/promise)
+ [Generator](http://es6.ruanyifeng.com/#docs/generator)
+ [Async](http://es6.ruanyifeng.com/#docs/async)