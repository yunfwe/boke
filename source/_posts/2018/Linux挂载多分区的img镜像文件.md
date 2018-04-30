---
title: Linux挂载多分区的img镜像文件
date: 2018-1-2 14:05:00
categories: 
    - Linux
tags:
    - Linux
photos:
    - /uploads/photos/9ah38f82do8h2.jpg

---


## <font color='#5CACEE'>简介</font>
> 有时候想挂载一个img镜像文件到系统目录，发现无法挂载。使用fdisk命令查看镜像结构 发现有多个分区，这个时候需要将所有分区映射为设备文件后才可以挂载。这个用处好像不太多 这个问题是当时为了修改树莓派的ubuntu镜像文件才用的。或者想自己制作一个linux启动镜像的时候可以玩玩。

<!-- more -->

## <font color='#5CACEE'>环境</font>
> 当然是在linux下进行操作了

## <font color='#5CACEE'>步骤</font>

### <font color='#CDAA7D'>先看看loop设备已经映射了哪些镜像</font>
```
losetup -a
```

### <font color='#CDAA7D'>将loop设备和img镜像绑定</font>
```
losetup /dev/loop0 ubuntu-16.04.3.img 
```

### <font color='#CDAA7D'>将loop0的所有分区映射出来</font>

```
kpartx -av /dev/loop0
```
    root@ubuntu-Lenovo:/home/ubuntu# kpartx -av /dev/loop0 
    add map loop0p1 (253:0): 0 262144 linear 7:0 8192
    add map loop0p2 (253:1): 0 7540736 linear 7:0 270336
    
### <font color='#CDAA7D'>将用到的分区挂载到目录</font>
```
mount /dev/mapper/loop0p2 /mnt/pi/
```
需要注意的是映射的设备文件在/dev/mapper/目录下

### <font color='#CDAA7D'>卸载</font>
```
umount /mnt/pi/
losetup -d /dev/loop0
```

## <font color='#5CACEE'>后记</font>
img镜像里面装个系统 就可以使用qemu等虚拟机启动了 挺好玩的
如果遇到无法umount的问题 可以直接使用 `fuser -ka /mnt/pi/` 强制卸载