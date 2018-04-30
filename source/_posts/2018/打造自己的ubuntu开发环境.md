---
title: 打造自己的ubuntu开发环境
date: 2018-02-10 22:12:00
categories: 
    - Ubuntu
tags:
    - Ubuntu
photos:
    - /uploads/2018/ubuntu/ubuntu.jpg

---
## <font color='#5CACEE'>简介</font>
> 对于经常在Linux做开发的开发者 打造一款让自己用的舒服 赏心悦目的系统开发环境是非常重要的。看着精美的主题和系统 心情也会变得更好，心情好了，代码的质量也就更高了。linux好的桌面发行版有Archlinux啊 Ubuntu啊 还有国产良心Deepin啊之类的，Archlinux太需要折腾了，Deepin呢 已经帮用户做的太多了，安装完毕后总觉得很多自己用不到的软件，桌面自己可以折腾的地方也不多，于是就选择了Ubuntu。鉴于下一个Ubuntu的LTS版18.04还有两个多月才发布 遂使用Ubuntu 16.04来折腾。


<!-- more -->

	
## <font color='#5CACEE'>环境</font>
> 由于Windows系统的便利性还是比Ubuntu高的 还有很多Ubuntu无法代替的地方 所以就只好吧Ubuntu安装到虚拟机里了

|主机|内存|CPU|硬盘|
|--|--|--|--|
|Windows 10 64位|8G DDR4|i7 6代|256G SSD|

|虚拟机|内存|CPU|硬盘|
|--|--|--|--|
|Ubuntu 16.04 64位|4G DDR4|i7 6代|40G SSD|



## <font color='#5CACEE'>步骤</font>

### <font color='#CDAA7D'>获取Ubuntu</font>
> 可以在ubuntu的官网获取 但是速度可能会比较慢。可以在国内的镜像站上免费下载ubuntu系统镜像

**在阿里云镜像站获取最新版ubuntu 16.04的镜像**

ubuntu-16.04.3-desktop-amd64.iso [点此下载](https://mirrors.aliyun.com/ubuntu-releases/16.04.3/ubuntu-16.04.3-desktop-amd64.iso)


### <font color='#CDAA7D'>安装Ubuntu</font>

可以选择在虚拟机或者物理机上安装Ubuntu

**在终端中更新升级软件**
> 由于Ubuntu的官方镜像站有中国的服务器，中文版的也默认使用中国的服务器 所以就不更改镜像站了

**执行以下命令**
```
sudo apt-get update
sudo apt-get upgrade
```
接下来就是开始美化主题了

#### <font color='#DDA0DD'>安装漂亮的主题</font>
> 这里使用我比较喜欢的Numix主题

**deb离线安装**
> 由于安装Numix主题需要添加Numix的ppa源 官方源有时候并不稳定 因为也可以直接安装Numix的deb包。在ubuntu内用火狐浏览器打开此页面后下载，或者Windows上下载好后想办法传入到ubuntu中。
如果想使用官方ppa源安装可以跳过这一段。

|包名|下载地址|
|--|--|
|numix-gtk-theme|[点此下载](/uploads/2018/ubuntu/debs/numix-gtk-theme.deb)|
|numix-icon-theme-circle|[点此下载](/uploads/2018/ubuntu/debs/numix-icon-theme-circle.deb)|

然后安装这两个包，如果没报错的话应该就安装成功了
```
dpkg -i numix-gtk-theme.deb
dpkg -i numix-icon-theme-circle.deb
```

**注意**：直接安装deb包只在当前ubuntu版本上测试通过，其他版本不保证可以使用，最好还是使用官方ppa源的安装方式。

**使用Numix官方源安装**
> 如果使用deb离线安装成功的话 这一步就不用继续了哦

```
sudo add-apt-repository ppa:numix/ppa
sudo apt-get update
sudo apt-get install numix-gtk-theme numix-icon-theme-circle
```

**还需要一款主题管理工具来更改主题**
```
sudo apt-get install unity-tweak-tool 
```

**打开tweak工具 然后将主题、桌面壁纸等换成自己喜欢的吧**

是不是瞬间感觉用户体验上升了一个档次呢 逼格也更高了

### <font color='#CDAA7D'>安装常用软件</font>

#### <font color='#DDA0DD'>搜狗输入法</font>

Ubuntu内用火狐浏览器打开：https://pinyin.sogou.com/linux/ 点击立即下载64位。
下载好后打开文件所在目录，然后在此目录打开终端 输入以下命令开始安装。
```
sudo apt-get install -f ./sogoupinyin_2.2.0.0102_amd64.deb
```

安装完后需要注销下重新登陆 然后打开浏览器 点击左上角小键盘的图标 切换到搜狗输入法。
试试看，是不是可以很舒服的输入中文了。使用`Shift`键切换中英输入哦。


#### <font color='#DDA0DD'>Chrome浏览器</font>
> 由于Windows下一直使用Chrome浏览器，所以对Chrome比较情有独钟。下载需要自备梯子哦。

Chrome浏览器下载地址：https://www.google.cn/chrome/

如果用Ubuntu中的火狐浏览器打开Chrome浏览器的主页，可以直接点击下载Chrome的图标。
Windows下的话 需要点击下载适用于其他平台的Chrome，下载后传到Ubuntu中。

**接下来安装deb包**
```
sudo apt-get install -f ./google-chrome-stable_current_amd64.deb
```



其他软件的安装方式都大同小异 可以在Ubuntu应用商店找到的就在应用商店安装，找不到的就去官方找有没有ppa源或者deb包。



## <font color='#5CACEE'>附录</font>

**漂亮的锁屏界面**
![配置](/uploads/2018/ubuntu/lock.jpg)
