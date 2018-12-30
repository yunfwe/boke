---
title: 回调地狱的终结：Pormise & Async
date: 2018-12-30
categories: 
    - JavaScript
tags:
    - javascript
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
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

ES8 的标准才引入了 `async` 关键字，`async` 是 `generator` 的语法糖，而 `generator` 是 ES6 提供的一种异步编程解决方案，借鉴了 Python 的 `generator` 概念与语法。

`async` 配合 `await` 可以让异步的代码看起来和同步的一样，并且可以使用 `try` 和 `catch` 来捕捉异步事件产生的异常。想了解这两个需要先熟悉什么是 `generator`。

#### Generator




## 附录