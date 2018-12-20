---
title: 从零开始搭建Vue开发环境
date: 2018-12-20 12:50:00
updated: 2018-12-20
categories: 
    - Vue
tags:
    - web
    - vue
    - webpack
photos:
    - /uploads/photos/jjv8512oa1v816j4.jpg
---


## 简介
> Vue (读音 /vjuː/，类似于 view) 是一套用于构建用户界面的渐进式框架。与其它大型框架不同的是，Vue 被设计为可以自底向上逐层应用。Vue 的核心库只关注视图层，不仅易于上手，还便于与第三方库或既有项目整合。另一方面，当与现代化的工具链以及各种支持类库结合使用时，Vue 也完全能够为复杂的单页应用提供驱动。本篇文章记录不使用 vue-cli 的自动化功能，手动搭建一个 Vue 的开发环境。

<!-- more -->

## 环境

| 软件     | 版本       |
| -------- | ---------- |
| 操作系统 | Windows 10 |
| Node.js  | v10.13.0   |
| Vue      | v2.5.21    |
|          |            |
|          |            |



## 步骤

### 初始化项目目录

创建一个空的目录作为项目目录，并在目录内执行 `npm init --yes`

    D:\Workspace\webapp>npm init --yes
    Wrote to D:\Workspace\webapp\package.json:
    
    {
    "name": "webapp",
    "version": "1.0.0",
    "description": "",
    "main": "index.js",
    "scripts": {
        "test": "echo \"Error: no test specified\" && exit 1"
    },
    "keywords": [],
    "author": "",
    "license": "ISC"
    }

并创建新目录 `src` 作为代码的存放目录。在 `src` 目录中创建 `index.html` 写入以下内容：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>
    <div id="app"></div>
</body>
</html>
```

### 加速 npm 包下载

默认的 npm 非常连接官方的 npm 源，下载速度非常慢，可以使用 `cnpm` 来加速下载。

首先全局安装 cnpm
```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org
```
之后就可以使用 cnpm 来开心的下载 npm 包了，但是 cnpm 下载某些包会出现依赖无法完全解决的问题，导致包无法正常使用，这种情况就只好配合 npm 来使用了。

还有一种加速 npm 包下载的方法，就是让默认的 npm 命令使用国内的 npm 镜像站。可以注意到，上一条安装 cnpm 的命令中，就使用了 `--registry=https://registry.npm.taobao.org` 临时将下载源切换到 taobao 提供的 npm 镜像站。这里使用 `nrm` 工具来切换镜像站，nrm 工具也需要先使用 npm 来安装。

```bash
npm install -g nrm --registry=https://registry.npm.taobao.org
```

`nrm ls` 命令可以看到当前默认使用的是 npm 的官方源

    D:\Workspace\webapp>nrm ls
    
    * npm ---- https://registry.npmjs.org/
    cnpm --- http://r.cnpmjs.org/
    taobao - https://registry.npm.taobao.org/
    nj ----- https://registry.nodejitsu.com/
    rednpm - http://registry.mirror.cqupt.edu.cn/
    npmMirror  https://skimdb.npmjs.com/registry/
    edunpm - http://registry.enpmjs.org/

使用 `nrm use taobao` 将默认源切换到 taobao 提供的镜像站

    D:\Workspace\webapp>nrm use taobao
    
    Registry has been set to: https://registry.npm.taobao.org/
    
    D:\Workspace\webapp>nrm ls
    
    npm ---- https://registry.npmjs.org/
    cnpm --- http://r.cnpmjs.org/
    * taobao - https://registry.npm.taobao.org/
    nj ----- https://registry.nodejitsu.com/
    rednpm - http://registry.mirror.cqupt.edu.cn/
    npmMirror  https://skimdb.npmjs.com/registry/
    edunpm - http://registry.enpmjs.org/

### 搭建 webpack 开发环境

#### 安装 webpack

Vue 官方推荐的开发方式是配合 `webpack` 打包工具，那么首先把 webpack 环境搭建起来。

```bash
cnpm install webpack webpack-cli --save-dev
```

webpack3 中，webpack和它的命令行工具都包含在一个包中，但在 webpack4 中，官方将两者分开了，所以必须两个包都安装才可以使用 `webpack` 命令。官方推荐局部安装 webpack ，直接输入 webpack 命令是没法找到的，高版本的 node.js 可以使用 npx 命令来执行 webpack，或者直接使用相对路径执行 webpack。

    D:\Workspace\webapp>webpack -v
    'webpack' 不是内部或外部命令，也不是可运行的程序
    或批处理文件。
    
    D:\Workspace\webapp>npx webpack -v
    4.28.0
    
    D:\Workspace\webapp>node_modules\.bin\webpack -v
    4.28.0

#### 使用 webpack 打包

接下来在 src 目录下编写一个 `main.js`，文件内容如下：

```javascript
let app = document.getElementById("app")
app.innerHTML = "<h1>Hello webpack!<h1>"
```

将 `main.js` 打包为 `bundle.js`，我们一般将打包后的文件单独放到 `dist` 目录下：

```bash
npx webpack src\main.js -o dist\bundle.js --mode development
```

    D:\Workspace\webapp>npx webpack src\main.js -o dist\bundle.js --mode development
    Hash: 8a16b3a0c76c2b1d9f8a
    Version: webpack 4.28.0
    Time: 94ms
    Built at: 2018-12-20 22:58:15
        Asset      Size  Chunks             Chunk Names
    bundle.js  3.85 KiB    main  [emitted]  main
    Entrypoint main = bundle.js
    [./src/main.js] 82 bytes {main} [built]

如果不加上 `--mode development`，webpack 则默认使用 `production` 级别去打包，如果代码里有 `console.log` 等无关程序运行逻辑的代码都会被清理掉，这样不方便项目的调试。这时可以看到项目目录下多出来一个 `dist` 目录，目录中有一个打包好的 `bundle.js`。这个例子中并没有在 `main.js` 里引入第三方的文件，如果引入了，webpack 也会一并打包为一个 `bundle.js`。

在 `index.html` 里引入打包好的 `bundle.js`：
```html
<body>
    <div id="app"></div>
    <script src="../dist/bundle.js"></script>
</body>
```

浏览器查看效果：

![1545318454063](/uploads/2018/从零开始搭建Vue开发环境/1545318454063.png)

#### webpack 配置文件

用命令行的方式是非常不方便，如果关闭了终端，下次使用 webpack 编译代码就还需要输入长长的一串代码，我们可以将代码写入到 webpack 的配置文件中，并配合 `package.json` 提供的自定义脚本命令功能来实现方便的编译。

与 `package.json` 同级的目录下创建 `webpack.config.js` 文件，当前项目目录下为：

![1545318902621](/uploads/2018/从零开始搭建Vue开发环境/1545318902621.png)

`webpack.config.js` 里写入如下内容：

```javascript
const path = require('path')

module.exports = {
    entry: path.join(__dirname, './src/main.js'),
    output: {
        path: path.join(__dirname, "./dist"),
        filename: "bundle.js"
    },
    mode: "development"
}
```

代码语法使用 node.js 的语法，并使用 `module.exports` 将配置暴露出去，其中 `entry` 表示入口文件，也就是我们的 `main.js` 所在的目录。`output` 提供一个输出的目录和打包后的文件名。`mode` 则是配置使用哪种模式进行打包。之后我们对 webpack 的配置也都是围绕这个文件进行。

这是在命令行只输入 `npx webpack` 命令，可以看到也编译成功了。

接着修改 `package.json`，在 `scripts` 项中添加 `"build": "webpack"`，这里就不需要借助 npx 工具来执行 webpack 了，npm 会在合适的位置运行 webpack 命令。

当前 `package.json` 内容如下：

```json
{
  "name": "webapp",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "webpack": "^4.28.0",
    "webpack-cli": "^3.1.2"
  },
}
```

控制台运行 `npm run build`

    D:\Workspace\webapp>npm run build
    
    > webapp@1.0.0 build D:\Workspace\webapp
    > webpack
    
    Hash: 8a16b3a0c76c2b1d9f8a
    Version: webpack 4.28.0
    Time: 95ms
    Built at: 2018-12-20 23:25:53
        Asset      Size  Chunks             Chunk Names
    bundle.js  3.85 KiB    main  [emitted]  main
    Entrypoint main = bundle.js
    [./src/main.js] 82 bytes {main} [built]

预设的命令执行成功了。



#### webpack-dev-server 配置

每次更改了代码，每次都需要重新编译，并刷新浏览器页面，这样是非常浪费时间的。而且通过文件的方式在浏览器预览效果，后期可能会出现各种问题。`webpack-dev-server` 则提供了一个支持时时编译，并自动刷新浏览器的功能。

我们首先安装它：

```bash
cnpm install webpack-dev-server --save-dev
```

webpack-dev-server 也支持直接通过命令行参数启动，但是既然已经使用了 `webpack.config.js` 来管理配置，那么就不提倡命令行参数启动了。修改 `webpack.config.js` 内容如下：

```javascript
const path = require('path')
const webpack = require("webpack")

module.exports = {
    entry: path.join(__dirname, './src/main.js'),
    output: {
        path: path.join(__dirname, "./dist"),
        filename: "bundle.js"
    },
    mode: "development",
    devServer: {
        open: true,
        port: 3000,
        hot: true
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
    ]
}
```
我们添加了 `devServer` 和 `plugins` 配置项，并导入了一个新的包 `webpack`。
`devServer` 里配置的三个属性，`open` 表示自动帮我们打开浏览器，`port` 表示服务监听在 3000 端口，`hot` 表示开启热加载功能。热加载功能一个需要注意的地方就是需要在 `plugins` 里添加这个插件，否则热加载功能是关闭的，所以才有了 `new webpack.HotModuleReplacementPlugin()` 这段代码。

还有一个需要注意的地方是，使用 `webpack-dev-server` 时一定要将 `mode` 设置为 `development`，否则每次热更新都非常慢，因为编译为 `production` 是非常耗时且消耗 CPU 资源的，但是可以给打包后的代码带来更小的体积。

接着在 `package.json` 中添加命令，并修改 `build` 命令构建 `production` 级别的代码：

```json
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack --mode production",
    "dev": "webpack-dev-server"
  }
```

控制台输入 `npm run dev` 命令，可以看到 `webpack-dev-server` 开始执行了，片刻，浏览器也自动打开了项目的根目录的页面：

![1545320800406](/uploads/2018/从零开始搭建Vue开发环境/1545320800406.png)

`index.html` 在 `src` 目录下，点击 `src` 目录则打开了先前的页面。修改 `main.js` 里的内容为如下：

```javascript
let app = document.getElementById("app")
app.innerHTML = "<h1>Hello Vue!<h1>"
```

可以看到每次对代码 `Ctrl + S` 保存一次，控制台就多输出一些内容，如果内容有 `Compiled successfully.` 则表示自动编译成功了，当我们兴高采烈的刷新浏览器时发现，怎么一点变化都没！这是因为 `webpack-dev-server` 并不是直接将编译后的代码保存在磁盘上，而且放在了内存中。而我们刚才的 `index.html` 引入的还是之前编译好的 `bundle.js` 文件。

修改 `index.html` 将引入 `bundle.js` 的代码改为 `<script src="/bundle.js"></script>`，接着重启服务或者刷新浏览器试试：

![1545322079036](/uploads/2018/从零开始搭建Vue开发环境/1545322079036.png)

而且每次修改了 `main.js` 后都会自动帮我们编译并刷新浏览器。
还有个小问题，`webpack-dev-server` 每次打开浏览器能不能直接定位到 `index.html` 而不是我们手动进入 `src` 目录呢？答案是肯定的，修改 `devServer` 的属性如下：

```javascript
    devServer: {
        open: true,
        port: 3000,
        hot: true,
        contentBase: "src",
    },
```

`contentBase` 会告诉 `webpack-dev-server` 以哪个目录作为根目录，然后重启 `webpack-dev-server` 可以看到浏览器自动打开的就是我们希望看到的页面了。

但是。。。当我们自动修改了 `main.js` 的时候，`webpack-dev-server` 会自动编译并把它放入内存，而 `index.html` 依然在物理磁盘上，那么我们能不能把这个文件也放入内存？这时还需要借助一个 `html-webpack-plugin` 的插件，接下来安装并使用它：

```bash
cnpm install html-webpack-plugin --save-dev
```

修改 `webpack.config.js` 为如下内容：

```javascript
const path = require('path')
const webpack = require("webpack")
const htmlWebpackPlugin = require("html-webpack-plugin")

module.exports = {
    entry: path.join(__dirname, './src/main.js'),
    output: {
        path: path.join(__dirname, "./dist"),
        filename: "bundle.js"
    },
    mode: "development",
    devServer: {
        open: true,
        port: 3000,
        hot: true,
        // contentBase: "src",
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
        new htmlWebpackPlugin({
            template: path.join(__dirname, "./src/index.html"),
            filename: "index.html"
        })
    ]
}
```

这里我们做了三处更改，首先引入了 `html-webpack-plugin` 这个插件，然后注释掉了 `contentBase: "src"`，接着初始化了 `htmlWebpackPlugin` 的对象，并将 `index.html` 的路径和文件名提供给插件。

还需要修改 `index.html` 将引入 `bundle.js` 的代码去掉：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>
    <div id="app"></div>
</body>
</html>
```
然后重启 `webpack-dev-server` 可以看到，又打开了熟悉的页面。为什么我们没有引入 `bundle.js` 还可以正常显示页面呢？打开控制台可以看到，`html-webpack-plugin` 已经帮我们自动加入这句代码了。

![1545323432735](/uploads/2018/从零开始搭建Vue开发环境/1545323432735.png)

其实这个插件最重要的一点是，我们执行 `npm run build` 编译项目的时候，`html-webpack-plugin` 还会帮我们把处理好的 `index.html` 文件放入 `dist` 目录中。

![1545323871346](/uploads/2018/从零开始搭建Vue开发环境/1545323871346.png)


#### webpack 处理 css

##### webpack 中使用 less
##### webpack 中使用 sass

#### webpack 处理其他资源

#### webpack 中 babel 配置

### webpack 与 Vue 的结合





























#### 安装 vue

这一步比较简单，直接用 cnpm 安装即可，唯一不同的是 vue 是运行时依赖，需要使用 `--save` 来写入到 `package.json` 的 `dependencies` 中。

```bash
cnpm install vue --save
```

当前 `package.json` 文件内容如下：

```json

```

#### 运行 webpack

接下来在 src 目录下编写一个 `main.js`，文件内容如下：

```javascript
import Vue from "vue"

let vm = new Vue({
    el: "#app",
    data:{
        msg:"Hello Vue"
    }
})
```

并修改 `index.html`：

```html
<body>
    <div id="app">{{msg}}</div>
</body>
```

浏览器是无法支持 ES6 的 `import` 语法的，所以 `index.html` 无法直接引入 `main.js` 来运行，而需要使用 webpack 来将代码和依赖的 Vue 框架打包成单个 js 文件，然后 `index.html` 只需要引入这一个文件就可以了。

将 `main.js` 打包为 `bundle.js`，我们一般将打包后的文件单独放到 `dist` 目录下：

```bash
npx webpack src\main.js -o dist\bundle.js --mode development
```

    D:\Workspace\webapp>npx webpack src\main.js -o  dist\bundle.js --mode development
    Hash: fac48cfc51c4578bdf70
    Version: webpack 4.28.0
    Time: 382ms
    Built at: 2018-12-20 22:06:47
        Asset     Size  Chunks             Chunk Names
    bundle.js  238 KiB    main  [emitted]  main
    Entrypoint main = bundle.js
    [./node_modules/_webpack@4.28.0@webpack/buildin/global.js] (webpack)/buildin/global.js 472 bytes {main} [built]
    [./src/main.js] 110 bytes {main} [built]
        + 4 hidden modules

如果不加上 `--mode development`，webpack 则默认使用 `production` 级别去打包，会去掉 Vue 框架代码里提供的调试信息，这样不方便项目的调试。这时可以看到项目目录下多出来一个 `dist` 目录，目录中有一个打包好的 `bundle.js`。这个文件的体积有点大，是因为将 Vue 连同之前写的代码都一起打包成了也给文件，这样 `index.html` 就可以只引入这一个文件了，有利于减少浏览器向服务端发起的资源请求数。

#### Vue 中的一个坑

在 `index.html` 中引入打包好的代码，并在浏览器中打开这个文件。这时比较尴尬的事情发生了，页面上空空如也，F12 打开控制台，看到有一个警告信息：

    vue.runtime.esm.js:602 [Vue warn]: You are using the runtime-only build of Vue where the template compiler is not available. Either pre-compile the templates into render functions, or use the compiler-included build.
    
    (found in <Root>)

大致意思说，当前使用的只能在运行时构建的 Vue，其中的模板编译器不可用，所以直接在 `index.html` 里写的模板字符串 `{{msg}}` 就没办法被编译了。解决方案也给了两个，要么预先将模板编译后写入 `render` 方法，要么使用包含编译器的 Vue 文件。

这是因为我们通过 `import Vue from "vue"` 导入的 Vue，是个精简版的 Vue...，把模板编译的功能给阉割了，所以模板字符串就没法被正常的替换了。可以查看 `node_modules\vue\package.json` 文件中 `"main": "dist/vue.runtime.common.js"`，Vue 默认导出的是 `dist/vue.runtime.common.js` 这个文件。

我们可以在 `main.js` 中手动导入完整版的 `vue.js` 文件，但是完整版的 `vue.js` 304K 的大小，而 `vue.runtime.common.js` 才 210K 大小，所以我们选择使用 `render` 函数来解决这个文件。

我们需要先创建一个模板，然后使用 `render` 函数将模板渲染到页面里，修改 `main.js` 为如下内容：

```javascript
import Vue from "vue"

let App = {
    template:"<h1>{{msg}}</h1>",
    data(){
        return {
            msg:"Hello Vue"
        }
    }
}

let vm = new Vue({
    el: "#app",
    render: function(createElement) {
        return createElement(App)
    }
})
```

去掉 `index.html` 里的模板字符串内容：
```html
<body>
    <div id="app"></div>
    <script src="../dist/bundle.js"></script>
</body>
```

重新运行 webpack ，然后浏览器刷新查看效果：

## 附录