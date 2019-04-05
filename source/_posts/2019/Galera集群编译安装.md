---
title: javascript vue
date: 2019-08-06 09:03:00
categories: 
    - xxx
tags:
    - 1111
photos:
    - /uploads/photos/352ac65cb7ea.jpg
---

# 标
> 这是引用

这还是不同文案三菱电机萨拉丁哈山东撒娇的 `javas`

<!-- more -->

```javascript

import { Terminal } from 'xterm'
import * as fit from 'xterm/lib/addons/fit/fit'
import * as attach from 'xterm/lib/addons/attach/attach'
Terminal.applyAddon(fit)
Terminal.applyAddon(attach)

let addr = BASEURL.split("//")[1]
console.log(addr)

class sshTerminal {
    constructor(info){
        this.info = info
        this.terminalContainer = null
        this.term = new Terminal({
            cols: 80,
            rows: 25,
            cursorBlink: 5,
            scrollback: 30000,
            tabStopWidth: 4
        })
        this.terminalSocket = null
    }
    open(){
        this.terminalContainer = document.getElementById('webssh'+this.info.id)
        this.term.open(this.terminalContainer)
        this.terminalSocket = new WebSocket(`ws://${addr}/webtermainal/${this.info.id}`)
        // this.terminalSocket = new WebSocket(`ws://192.168.4.233:5000/wssh/${this.info.hostip}/root?password=111111`)
        this.terminalSocket.onopen = ()=>{console.log("ws opened")}
        this.terminalSocket.onclose = ()=>{console.log("ws closed")}
        this.terminalSocket.onerror = ()=>{
            console.log("ws error")
            this.term.write("\r\n\r\n\t后端服务接口连接失败...")
        }
        this.term.attach(this.terminalSocket)
        this.term._initialized = true
        console.log('ws open start')
    }
    close(){
        this.terminalSocket.close()
        this.term.destroy()
    }

}

export default sshTerminal

```


## 表题2

asdjilasjilsad




### 标题3


## ojasodjasod


## asdsad