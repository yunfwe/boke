---
title: 愉快的用 Vim 写代码
date: 2018-05-11 10:12:00
categories: 
    - Vim
tags:
    - vim
    - linux
photos:
    - /uploads/photos/104fe851474.png
---

## 简介
> Vim 是一款高可定制的文本编辑器软件，而大多数人使用 vim 应该是从 Linux 的教科书里得知的吧。vim 来自于 vi 编辑器，而 vi 在1976年就发布了，经过如此多年的进化，可以说是非常成熟和强大了。但是 vim 的学习曲线比较陡，但是对 vim 学习的越深入，使用 vim 提升的效率就越高。这里是这几天对 vim 的学习，打造出的一款比较得心应手的编程工具。

<!-- more -->

## 环境

在 Ubuntu 16.04 和 Ubuntu 18.04 上测试成功，理论上比较高的 Vim 版本都可以。Mac 没测试环境 ╮(╯▽╰)╭ ，Windows 就用 IDE 了，不想用 IDE 还可以使用 Notepad++ 或者 VScode。Vim 胜在是安装在服务器上的，这样需要远程连接服务器来写代码调试的话就非常方便了。先秀几张效果截图。


**代码补全**
![](/uploads/2018/vim/1fsp4b39a33kd72v.jpeg)

**文件分屏**
![](/uploads/2018/vim/r5utf7qitfk2o807.jpeg)

**文件操作**
![](/uploads/2018/vim/15t4t2ae954qzzc7.jpeg)


## 安装

自己写的配置已经开源在了 Github 上 [点击浏览](https://github.com/yunfwe/vimconf)

因为安装过程中需要联网安装插件，所以务必保证网络正常，并且已经安装 git 命令行工具。

输入以下命令安装：
```
source <(curl -s https://raw.githubusercontent.com/yunfwe/vimconf/master/install.sh)
```

Vim 的配置被安装到了家目录下的 `.vimrc` 文件和 `.vim` 目录，如果安装之前存在着两个目录，脚本将自动备份。如果想卸载也非常简单，手动删除家目录下的 `.vimrc` 和 `.vim` 即可，或者执行提供好的卸载脚本也可以：
```
source <(curl -s https://raw.githubusercontent.com/yunfwe/vimconf/master/uninstall.sh)
```

## 配置

Vim 的配置文件非常强大，是一种专门的 `Vim Script` 的语言编写，大部分的 Vim 插件也都是用这个语言写的

这里看看配置文件的内容，以及各内容的说明

    " curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    " vim -c "PlugInstall" -c "q" -c "q"

    """""""""""""""""""""""""""""""""""""""""""""""""
    " 使用plug
    """""""""""""""""""""""""""""""""""""""""""""""""
    call plug#begin('~/.vim/plugged')
    Plug 'scrooloose/nerdtree'      " 目录树插件
    Plug 'vim-airline/vim-airline'  " 状态栏插件
    Plug 'vim-airline/vim-airline-themes' " 状态栏主题插件
    Plug 'joshdick/onedark.vim'     " 状态栏主题使用的颜色
    Plug 'jiangmiao/auto-pairs'     " 自动补全引号括号
    Plug 'vim-scripts/SuperTab'     " 提高Tab键能力的插件
    "Plug 'vim-scripts/c.vim'        " 官方C语言插件
    Plug 'rkulla/pydiction'         " 轻量级的Python补全插件
    Plug 'luochen1990/rainbow'      " 为不同的括号添加颜色的插件
    call plug#end()
    """""""""""""""""""""""""""""""""""""""""""""""""

Vim 的配置文件中，用双引号开头表示注释，是被 Vim 忽略的，Vim 安装插件最简单的方法就是使用插件管理器，但是插件管理器也是 Vim 的一个插件，所以这个插件就需要手动安装了，因此安装脚本的开头就是从 Github 上获取这个插件管理器，然后放到相应的目录中后 先用一个简单的只包含需要安装其他插件指令的配置文件启动 Vim 并安装其他插件。

插件大多数人都选择直接从 github 上获取，所以插件名就可以不用写 github 的全路径，只需要用户名和仓库名就可以了，Vim 的插件管理器还有非常多的种类，但是 `vim-plug` 可以并发下载安装插件，比其他种类的更轻，更快。

    """""""""""""""""""""""""""""""""""""""""""
    " 实用设置
    """""""""""""""""""""""""""""""""""""""""""
    "当打开vim且没有文件时自动打开NERDTree
    autocmd vimenter * if !argc() | NERDTree | endif
    " 只剩 NERDTree时自动关闭
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
    set autoread        " 设置当文件被改动时自动载入
    if has("autocmd")
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    endif
    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 编码设置
    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    set langmenu=zh_CN.UTF-8
    set helplang=cn
    set termencoding=utf-8
    set encoding=utf8
    set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 通用设置
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    let mapleader = ","      " 定义<leader>键
    set nocompatible         " 设置不兼容原始vi模式
    filetype on              " 设置开启文件类型侦测
    filetype plugin on       " 设置加载对应文件类型的插件
    set noeb                 " 关闭错误的提示
    syntax enable            " 开启语法高亮功能
    syntax on                " 自动语法高亮
    set t_Co=256             " 开启256色支持
    set cmdheight=1          " 设置命令行的高度
    set showcmd              " select模式下显示选中的行数
    set scrolloff=3          " 光标移动到buffer的顶部和底部时保持3行距离 
    set ruler                " 总是显示光标位置
    set laststatus=2         " 总是显示状态栏
    set number               " 开启行号显示
    set cursorline           " 高亮显示当前行
    set whichwrap+=<,>,h,l   " 设置光标键跨行
    set virtualedit=block,onemore   " 允许光标出现在最后一个字符的后面
    set incsearch            " 实时搜索
    set mouse-=a             " 不允许使用鼠标操作
    set noeb vb t_vb=        " 关闭终端响铃
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 代码缩进和排版
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set autoindent           " 设置自动缩进
    set cindent              " 设置使用C/C++语言的自动缩进方式
    set cinoptions=g0,:0,N-s,(0    " 设置C/C++语言的具体缩进方式
    set smartindent          " 智能的选择对其方式
    filetype indent on       " 自适应不同语言的智能缩进
    set expandtab            " 将制表符扩展为空格
    set tabstop=4            " 设置编辑时制表符占用空格数
    set shiftwidth=4         " 设置格式化时制表符占用空格数
    set softtabstop=4        " 设置4个空格为制表符
    set smarttab             " 在行和段开始处使用制表符
    "set nowrap               " 禁止折行
    set wrap                 " 自动折行
    set iskeyword+=_,$,@,%,#,-  " 带有如下符号的单词不要被换行分割
    set backspace=2          " 使用回车键正常处理indent,eol,start等
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 代码补全
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set wildmenu             " vim自身命名行模式智能补全
    set completeopt-=preview " 补全时不显示窗口，只显示补全列表
    set matchtime=1          " 匹配括号高亮的时间（单位是十分之一秒）
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 代码折叠
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set foldmethod=syntax   " 设置基于语法进行代码折叠
    set nofoldenable        " 关闭折叠代码
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 缓存设置
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set nobackup            " 设置不备份
    set noswapfile          " 禁止生成临时文件
    set autoread            " 文件在vim之外修改过，自动重新读入
    set autowrite           " 设置自动保存
    set confirm             " 在处理未保存或只读文件的时候，弹出确认
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

正如每个配置项的注释所言，这个是对 Vim 编辑器的一些配置。

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 新文件标题
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "新建.c,.h,.sh,.java文件，自动插入文件头 
    autocmd BufNewFile *.cpp,*.[ch],*.sh,*.rb,*.java,*.py exec ":call SetTitle()" 
    ""定义函数SetTitle，自动插入文件头 
    func SetTitle() 
        "如果文件类型为.sh文件 
        if &filetype == 'sh' 
            call setline(1,"\#!/bin/bash") 
            call append(line("."), "") 
        elseif &filetype == 'python'
            call setline(1,"#!/usr/bin/env python")
            call append(line("."),"# -*- coding:utf-8 -*-")
            call append(line(".")+1,"# Author: root  date: ".strftime("%Y-%m-%d"))
            call append(line(".")+2, "") 
            call append(line(".")+3, "") 

        elseif &filetype == 'ruby'
            call setline(1,"#!/usr/bin/env ruby")
            call append(line("."),"# encoding: utf-8")
            call append(line(".")+1, "")
            call append(line(".")+2, "")

            "    elseif &filetype == 'mkd'
            "        call setline(1,"<head><meta charset=\"UTF-8\"></head>")
        else 
            call setline(1, "/*************************************************************************") 
            call append(line("."), "	> File Name: ".expand("%")) 
            call append(line(".")+1, "	> Author: root") 
            call append(line(".")+2, "	> Mail: root@localhost.com") 
            call append(line(".")+3, "	> Created Time: ".strftime("%Y-%m-%d")) 
            call append(line(".")+4, " ************************************************************************/") 
            call append(line(".")+5, "")
        endif
        if expand("%:e") == 'cpp'
            call append(line(".")+6, "#include <iostream>")
            call append(line(".")+7, "using namespace std;")
            call append(line(".")+8, "")
            call append(line(".")+9, "")
        endif
        if &filetype == 'c'
            call append(line(".")+6, "#include <stdio.h>")
            call append(line(".")+7, "")
            call append(line(".")+8, "")
        endif
        if expand("%:e") == 'h'
            call append(line(".")+6, "#ifndef _".toupper(expand("%:r"))."_H")
            call append(line(".")+7, "#define _".toupper(expand("%:r"))."_H")
            call append(line(".")+8, "#endif")
            call append(line(".")+9, "")
        endif
        if &filetype == 'java'
            call append(line(".")+6,"public class ".expand("%:r"))
            call append(line(".")+7,"")
        endif
        "新建文件后，自动定位到文件末尾
    endfunc 
    autocmd BufNewFile * normal G
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

这段配置就用到了定义函数，逻辑判断等语法，作用是在 Vim 编辑新文件的时候，根据文件名来自动生成不同的文件头部信息，为了方便，可以把代码中的 `Author` 和 `Mail` 配置为自己的信息，这样就不用每次创建了文件之后再修改了。


    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 键盘命令
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    nnoremap <C-N> :bn<CR>
    nnoremap <C-P> :bp<CR>
    nmap <Esc><Esc><Esc> :qa!<CR> " 连续三个Esc不保存退出全部
    " 切换NERDTree 
    map <F3> :NERDTreeToggle<CR>
    :autocmd BufRead,BufNewFile *.dot map <F5> :w<CR>:!dot -Tjpg -o %<.jpg % && eog %<.jpg  <CR><CR> && exec "redr!"
    "C，C++ 按F5编译运行
    map <F5> :call CompileRunGcc()<CR>
    func! CompileRunGcc()
        exec "w"
        if &filetype == 'c'
            "exec "!g++ % -o %<"
            "exec "!time ./%<"
            exec "!g++ % -o %< && time ./%<"
        elseif &filetype == 'cpp'
            "exec "!g++ % -std=c++11 -o %<"
            "exec "!time ./%<"
            exec "!g++ % -std=c++11 -o %< && time ./%<"
        elseif &filetype == 'java' 
            "exec "!javac %" 
            "exec "!time java %<"
            exec "!javac % && time java %<"
        elseif &filetype == 'sh'
            :!time bash %
        elseif &filetype == 'python'
            exec "!time python %"
        elseif &filetype == 'html'
            exec "!firefox % &"
        elseif &filetype == 'go'
            "        exec "!go build %<"
            exec "!time go run %"
        elseif &filetype == 'mkd'
            exec "!~/.vim/markdown.pl % > %.html &"
            exec "!firefox %.html &"
        endif
    endfunc
    "代码调试
    map <F8> :call Rungdb()<CR>
    func! Rungdb()
        exec "w"
        if &filetype == 'cpp'
            "exec "!g++ % -std=c++11 -g -o %<"
            "exec "!gdb ./%<"
            exec "!g++ % -std=c++11 -g -o %< && gdb ./%<"
        elseif &filetype == 'c'
            "exec "!gcc % -g -o %<"
            "exec "!gdb ./%<"
            exec "!gcc % -g -o %< && gdb ./%<"
        elseif &filetype == 'python'
            exec "!python -m pdb %"
        elseif &filetype == 'go'
            "exec "!go build -o %< %"
            "exec "!gdb ./%<"
            exec "!go build -o %< % && gdb ./%<"
        endif
    endfunc
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

定义了一些快捷键，比如在同时编辑多个文件时 `Ctrl + p` 和 `Ctrl + n` 可以切换到上一个或下一个，连击三次 `Esc` 会不保存退出全部文件， `F3` 会切换是否显示文件目录树，`F5` 编译运行和 `F8` 调试。还有就是插件自己的快捷键，比如使用 `Ctrl + w + w` 可以切换窗口，使用 `s` 或者 `i` 可以分割窗口。使用 `m` 可以显示文件操作菜单，这些都是 `NERDTree` 目录树插件的快捷键，还可以自己按照 Vim 的规则定义一些方便的快捷键。

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 主题
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set background=dark
    let g:onedark_termcolors=256
    colorscheme onedark

这里就是应用了下载的第一个插件的那个主题，感觉非常养眼，不 是没那么毁眼。其中有几个特殊的字符需要特殊的几种字体才能看到，我喜欢用的 `Consolas` 字体是没问题的。

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " 插件配置
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " airline
    let g:airline_theme="onedark"
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " nerdtree
    "let g:NERDTreeFileExtensionHighlightFullName = 1
    "let g:NERDTreeExactMatchHighlightFullName = 1
    "let g:NERDTreePatternMatchHighlightFullName = 1
    "let g:NERDTreeHighlightFolders = 1          
    "let g:NERDTreeHighlightFoldersFullName = 1  
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    
    " pydiction 
    let g:pydiction_location = '~/.vim/plugged/pydiction/complete-dict'
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " rainbow
    let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

顾名思义，就是针对安装的插件的配置了，不同的插件会读取其中不同的值来产生不同的行为。

## 附录

如果体验了和平常不同的 Vim 后对它产生了浓厚的兴趣，那么对 Vim 的使用进行一次深入的学习那就最好不过了。

+ [官方中文文档在线](http://vimcdoc.sourceforge.net/doc/help.html)
+ [官方中文文档下载](http://vimcdoc.sourceforge.net/)