---
title: Cordova混合开发环境搭建
date: 2018-12-09 12:50:00
updated: 2018-12-11
categories: 
    - Cordova
tags:
    - html5
    - cordova
photos:
    - /uploads/photos/20181209214532.jpg
---

<!-- created: 2018-12-09 12:50:00 -->

## 简介
> Cordova提供了一组设备相关的API，通过这组API，移动应用能够以JavaScript访问原生的设备功能，如摄像头、麦克风等。Cordova还提供了一组统一的JavaScript类库，以及为这些类库所用的设备相关的原生后台代码。Cordova支持如下移动操作系统：iOS, Android,ubuntu phone os, Blackberry, Windows Phone, Palm WebOS, Bada 和 Symbian。
<!-- more -->

## 环境

> 下面是在Windows平台编译安卓apk为例。如果是其他平台，本文档也有一定参考价值

###  安装应用

| 软件        | 版本要求      | 下载                                                         |
| :---------- | :------------ | ------------------------------------------------------------ |
| Node.js     | 最新LTS版即可 | [下载地址](http://nodejs.cn/download/)                       |
| jdk         | 1.8 以上      | [下载地址](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) |
| Android SDK | 最新版即可    | [下载地址](http://tools.android-studio.org/index.php/sdk/)   |
| gradle      | 最新版即可    | [下载地址](https://gradle.org/releases/)                     |
| ant         | 最新版即可    | [下载地址](https://ant.apache.org/bindownload.cgi)           |

### 配置环境变量

> 根据实际软件的安装目录配置环境变量

| 变量名称     | 值                                                  |
| ------------ | --------------------------------------------------- |
| JAVA_HOME    | D:\Application\Java\jdk1.8.0_101                    |
| CLASSPATH    | .;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar; |
| ANDROID_HOME | D:\Application\android\sdk                          |

**Path环境变量中添加如下值**

![1544333928085](/uploads/2018/Cordova混合开发环境搭建/1544333928085.png)



### 验证环境变量

java

    > java -version
    java version "1.8.0_101"
    Java(TM) SE Runtime Environment (build 1.8.0_101-b13)
    Java HotSpot(TM) 64-Bit Server VM (build 25.101-b13, mixed mode)

gradle

    > gradle -v
    
    ------------------------------------------------------------
    Gradle 5.0
    ------------------------------------------------------------
    
    Build time:   2018-11-26 11:48:43 UTC
    Revision:     7fc6e5abf2fc5fe0824aec8a0f5462664dbcd987
    
    Kotlin DSL:   1.0.4
    Kotlin:       1.3.10
    Groovy:       2.5.4
    Ant:          Apache Ant(TM) version 1.9.13 compiled on July 10 2018
    JVM:          1.8.0_101 (Oracle Corporation 25.101-b13)
    OS:           Windows 10 10.0 amd64

ant

    > ant -v
    Apache Ant(TM) version 1.10.5 compiled on July 10 2018
    Trying the default build file: build.xml
    Buildfile: build.xml does not exist!
    Build failed


node.js

    > node -v
    v10.13.0

### 安装 Android SDK

进入 Android SDK 的安装目录，执行 `SDK Manager.exe` ，安装如下模块：

![1544338294525](/uploads/2018/Cordova混合开发环境搭建/1544338294525.png)

### 安装 Cordova

> node.js 默认会将全局安装的模块还有下载的缓存放在C盘，可以通过更改配置文件来改变安装的位置。

注意：根据 node.js 的实际安装位置或个人喜好酌情修改

	> npm config set prefix "D:\Application\nodejs"
	> npm config set cache "D:\Application\nodejs\node_cache"

接下来就可以安装 Cordova 了，使用默认的仓库安装会比较慢，可以考虑使用淘宝的镜像站来安装

```
npm config set registry "https://registry.npm.taobao.org"
npm install -g cordova
```

    > cordova -v
    8.1.2 (cordova-lib@8.1.1)

如果没有报错，那么 cordova 就安装完了。

## 开发

### 创建应用
> 接下来就用 Cordova 创建第一个应用程序，并打包为 Android APK。

	> cordova create myapp
	Creating a new cordova project.

这样一个初始项目目录就构建完成了，还需要添加相应的目标平台，比如 Android 还是 IOS。

    > cordova platform ls
    Installed platforms:
    
    Available platforms:
      android ~7.1.1
      browser ~5.0.1
      ios ~4.5.4
      osx ~4.0.1
      windows ~6.0.0

添加某个支持的平台使用 `cordova platform add` 命令，删除某个平台将 `add` 换成 `rm` 即可。

    > cordova platform add android
    Using cordova-fetch for cordova-android@~7.1.1
    Adding android project...
    Creating Cordova project for the Android platform:
            Path: platforms\android
            Package: io.cordova.hellocordova
            Name: HelloCordova
            Activity: MainActivity
            Android target: android-27
    Android project created with cordova-android@7.1.4
    Android Studio project detected
    Android Studio project detected
    Discovered plugin "cordova-plugin-whitelist" in config.xml. Adding it to the project
    Installing "cordova-plugin-whitelist" for android
    
                   This plugin is only applicable for versions of cordova-android greater than 4.0. If you have a previous platform version, you do *not* need this plugin since the whitelist will be built in.
    
    Adding cordova-plugin-whitelist to package.json
    Saved plugin info for "cordova-plugin-whitelist" to config.xml
    --save flag or autosave detected
    Saving android@~7.1.4 into config.xml file ...
### 编译项目

执行：`cordova build android`，如果编译成功，最后会出现 `BUILD SUCCESSFUL` 以及 apk 安装包的位置。默认是 DEBUG 模式的编译，如果是发行版可以使用 `cordova build android --release`

**注意**：第一次编译的时候，Gradle 会下载一些依赖，这些依赖会安装在用户家目录下的 `.gradle` 目录中，这一步我也没有什么好的办法，只能祈祷网络好一点能赶紧下载完。编译后的 apk 都是没有签名的，如果是 `release` 模式编译的 apk，不签名的话是无法安装的。

如果通过USB连接了安卓手机，则可以直接使用 `cordova run android` 命令将 apk 部署到手机上测试，手机需要打开USB调试模式，并允许通过 USB 安装 apk 包。

打开效果如下：

<img src="/uploads/2018/Cordova混合开发环境搭建/1544338825661.png" width=300>

### 调试项目

可以通过 Chrome 浏览器调试页面，或者直接使用 Chrome 浏览器配合真机调试

#### 使用浏览器调试

首先安装浏览器平台的支持，然后使用浏览器调试页面。

    > cordova platform add browser
    Using cordova-fetch for cordova-browser@~5.0.1
    Adding browser project...
    Creating Cordova project for cordova-browser:
            Path: D:\Workspace\myapp\platforms\browser
            Name: HelloCordova
    Installing "cordova-plugin-whitelist" for browser
    --save flag or autosave detected
    Saving browser@~5.0.4 into config.xml file ...

然后执行 `cordova run browser` 会直接打开浏览器显示页面，这时候可以使用 `F12` 打开控制台调试了。

![1544360041683](/uploads/2018/Cordova混合开发环境搭建/1544360041683.png)


#### 使用浏览器调试真机

将安卓手机通过USB连接电脑，并安装好驱动（Win10貌似自带驱动），然后打开USB调试模式并允许通过USB安装应用程序。
执行 `cordova run android` 命令，这时手机上应该已经自动安装并打开了程序。

通过 Chrome 浏览器打开页面 `chrome://inspect/#devices`，Devices 中已经出现了自己的手机机型以及一个 cordova 的 WebView 条目，然后点击 `inspect`:

![1544360589393](/uploads/2018/Cordova混合开发环境搭建/1544360589393.png)
![1544360677819](/uploads/2018/Cordova混合开发环境搭建/1544360677819.png)

可以看到就跟调试普通页面一样，鼠标在不同的标签上划过，手机app上对应的标签也会高亮显示：

<img src="/uploads/2018/Cordova混合开发环境搭建/49A7953522E667BB0ECF3D8C4D6676B7.jpg" width=300>

## 附录

### 一个获取设备信息的demo

首先安装获取设备信息的 cordova 插件

    > cordova plugin add cordova-plugin-device
    Installing "cordova-plugin-device" for android
    Android Studio project detected
    Installing "cordova-plugin-device" for browser
    Adding cordova-plugin-device to package.json
    Saved plugin info for "cordova-plugin-device" to config.xml

`cordova plugin add` 命令会自动给已安装的所有平台都安装上指定的插件。

删除项目目录下 www 目录中的所有文件，然后重新创建 `index.html`，写入以下内容：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>设备信息</title>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        #content {
            position: fixed;
            height: 90%;
            width: 100%;
            background-color: #c7c7c7;
            text-align: center

        }
        #btn {
            position: fixed;
            bottom: 0;
            width: 100%;
            height: 10%;
            border: 1px solid skyblue;
            background-color: #fff;
            font-size: 18px;
        }
        #btn:active {
            background-color: skyblue;

        }
    </style>
</head>
<body>
    <div id="content">

    </div>
    <button id="btn">获取信息</button>
    <script src="cordova.js"></script>
    <script>
        document.addEventListener("deviceready", onDeviceReady, false);
        function onDeviceReady() {
            var btn = document.getElementById("btn")
            var content = document.getElementById("content")
            btn.onclick = function(){
                content.innerHTML = ""
                for (let i of ['cordova','model','platform','uuid',
                            'version','manufacturer','serial']){
                    let tmp = document.createElement("p")
                    tmp.innerText = i + ': ' + device[i]
                    content.appendChild(tmp)
                }
            }
        }
    </script>
</body>
</html>
```

运行：`cordova run browser` 在浏览器上点击获取信息的按钮，显示如下：

![1544362788456](/uploads/2018/Cordova混合开发环境搭建/1544362788456.png)

运行：`cordova run android` 在手机上点击获取信息的按钮，显示如下：

<img src="/uploads/2018/Cordova混合开发环境搭建/1544362880491.png" width=300>