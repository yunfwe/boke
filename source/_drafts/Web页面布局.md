---
title: Web页面布局
date: 2018-12-24 12:50:00
updated: 2018-12-25
categories: 
    - Web
tags:
    - web
    - css
    - javascript
photos:
    - /uploads/photos/8fa387f3a.jpg
---



## 简介
> 使用现代前端技术开发的应用，不管是 Web 页面，还是混合开发的手机 APP，都离不开页面元素的布局。而布局又可以说是页面开发里最麻烦的地方，不仅要兼容不同的设备，还要兼容不同的浏览器，还很可能一不小心改错了一个值就造成整个页面的雪崩。这里汇总下关于页面布局的基础知识以及实际开发中可能会遇到的问题。
<!-- more -->


## 环境

| 软件 | 版本 |
| ---- | ---- |
| 操作系统 | Windows 10 |
| Chrome浏览器 | 70 |

## 教程
> 这里假使读者已经有了基础的 CSS 和 JavaScript 知识。如果对这些基础知识还没有概念的话，如果继续往下看，可能会觉得比较难以理解和接受。

### CSS 基础
> 这里讲诉的 CSS 基础重点在于  **三大特性**、**盒子模型**、**浮动** 和 **定位** 这几个方面，其他的背景啊、边框啊也都是细节，而这几个才是整个页面布局的基础。

#### 标签显示模式

网页的标签非常多，并且不同的标签用于不同的场合，因此不同的标签也有不同的显示模式。比如两个 `a` 标签默认是可以放在一行显示的，而 `p` 标签则不可以，默认在页面上独占一行或多行。

##### 块级元素

`p` 标签就是常见的块级元素，以及我们经常用来布局的 `div` 标签、`h1 ~ h6` 标签等，默认都是块级元素。块级元素由于可以对其设置宽高、对齐，因此常用于网页布局和结构搭建。


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        h1 {
            background-color: #8a8a8a;
        }
        p {
            background-color: #5e68ea;
        }
        div {
            background-color: #ff7171;
            padding: 3px;
        }
    </style>
</head>
<body>
    <h1>第一行</h1>
    <p>第二行</p>
    <div>
        <p>第三行</p>
    </div>
</body>
</html>
```

![1545666248139](/uploads/2018/Web页面布局/1545666248139.png)

可以看到块级元素的几个特性：

+ 独占一行或多行
+ 宽高、内外边距都可以控制
+ 宽度默认是占满整个容器
+ 可以容器其他行内元素、块级元素

需要注意的是，`p` 标签和 `h1 ~ h6` 等文字类块级标签不可以容纳其他块级元素。

浏览器默认给一些块元素提供了外边距，所以页面上元素与元素之间还会有块空白。一般在实际开发中，都会重置所有元素的内外边距：

```css
* {
    margin: 0;
    padding: 0;
}
```

![1545666827380](/uploads/2018/Web页面布局/1545666827380.png)

这样页面上就不会有这么多无法掌控的情况了。

##### 行内元素

行内元素不占有独立的区域，仅仅靠自身的字体大小和图像尺寸来支撑结构，一般不可以设置宽度、高度、对齐等属性，常用于控制页面中文本的样式。常见的行内元素有 `a`, `b`, `del`, `i`, `span` 等。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        a, b, del, i, span {
            margin: 5px;
            padding: 5px;
        }
    </style>
</head>
<body>
    <div>
        <a href="#"><span>超文本链接</span></a>
        <b>加粗</b>
        <del>删除</del>
        <i>斜体</i>
        <span>没有预设样式</span>
    </div>
</body>
</html>
```

![1545667856330](/uploads/2018/Web页面布局/1545667856330.png)

`span` 元素最为纯粹，可塑性非常高，所以经常会使用 `span` 标签来为文本添加各种样式。

行内元素的特点：

+ 不会独占一行，会和相邻的行内元素在一行上显示。
+ 无法设置高和宽，以及上下内外边距，但是左右内外边距可以设置。
+ 它的内容有多宽，容器就被撑多宽
+ 行内元素只能容纳文本或则其他行内元素。

`a` 标签比较特殊，也可以容纳块级元素。

##### 行内块元素

行内块元素可以说就是允许设置宽高、内外边距（包括上下）、对齐属性的行内元素，比如常见的 `img` 标签，`input` 标签。下面看看行内块元素的显示：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        img {
            width: 150px;
            height: 150px;
            border: 1px solid #3280f3;
            vertical-align: bottom
        }
        input {
            width: 200px;
            height: 30px;
            border: 1px solid #f37932;
        }
    </style>
</head>
<body>
    <div>
        <img src="css.png">
        <input type="text" placeholder="这是一个输入框">
    </div>
</body>
</html>
```

![1545668809401](/uploads/2018/Web页面布局/1545668809401.png)

`img` 标签和 `input` 标签都可以设置宽高，`img` 标签默认与其他一行的元素以基线对齐（`baseline`），这里改为底部对齐（`bottom`）的方式让显示的更好看一些。还有个问题可以发现，即使已经设置了 `margin: 0` 和 `padding: 0`，可是两个行内块元素中间依然有个缝隙。下面总结行内块元素的特点：

+ 和相邻行内或行内块元素在一行上，但是中间有空白缝隙。
+ 默认宽度是它本身内容把它撑开的宽度。
+ 宽高、内外边距都可以控制。

##### 显示模式转换

通过 `display` 样式可以转换元素的默认显示模式：
```css
.box {
    display: inline;        /* 转换为行内元素 */
    display: block;         /* 转换为块级元素 */
    display: inline-block;  /* 转换为行内块元素 */
}
```
下面看一个例子：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        span {
            display: block;
            width: 100px;
            height: 100px;
            border: 1px solid #3a65e2;
            margin: 5px;
        }
        div {
            display: inline;
            border: 1px solid #f459b7
        }
    </style>
</head>
<body>
    <span>span现在是块级元素了</span>
    <span>拥有块级元素的特性</span>
    <div>div成了行内元素</div><div>可以一行显示了</div>
</body>
</html>
```
![1545670158259](/uploads/2018/Web页面布局/1545670158259.png)


##### 其他显示模式

这三种基本的显示模式几乎可以应付大部分的页面布局了，其中还有一些非常好用的显示模式，比如 `display: flex` 可以用来做另外一种页面布局，但是对老旧的电脑浏览器存在一些兼容性问题（比如 IE），如果是手机页面开发，`display: flex` 几乎可以想怎么用就怎么用了。

浏览器开发者模式中可以看到所有支持的显示模式：

![1545670550429](/uploads/2018/Web页面布局/1545670550429.png)

#### CSS 三大特性

##### 层叠性

所谓层叠性，是指如果一个元素被应用了多个相同的 CSS 属性，那么浏览器如何处理这种冲突呢？先看一个例子。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        #app {
            width: 100px;
            height: 100px;
            background-color: red;
        }
        #app {
            width: 100px;
            height: 100px;
            background-color: gray;
        }
    </style>
</head>
<body>
    <div id="app"></div>
</body>
</html>
```

在浏览器中查看效果，显示的是灰色的盒子：

![1545658432213](/uploads/2018/Web页面布局/1545658432213.png)

接着把两个颜色替换下看看效果
```css
#app {
    width: 100px;
    height: 100px;
    background-color: gray;
}
#app {
    width: 100px;
    height: 100px;
    background-color: red;
}
```
盒子变成红色：

![1545658706473](/uploads/2018/Web页面布局/1545658706473.png)

可以看到，是最后一次定义的 `background-color` 生效。也就是说，相同的 CSS 样式互相覆盖，只有最上面的一层 CSS 样式才最终被我们看到。

##### 继承性

几乎所有（未来不知道有没有）的应用与文字上的样式，都具有继承性。也就是说，在父标签定义好的一些关于文字的样式，子元素都不需要重新定义。如果子元素需要不同的样式，只能通过在子元素上应用新的样式来层叠掉父元素继承来的样式。

子元素可以继承的样式有 `text-`, `font-`, `line-` 开头的所有元素以及 `color` 元素。下面看一个例子：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        html {
            color: green;
        }
        #father {
            color: blue;
            font-size: 24px;
        }
    </style>
</head>
<body>
    从HTML标签继承来的color为绿色
    <div id="father">
        #father层叠了继承来的color为蓝色<br>
        并定义了字号样式为 20px
        <div id="son">
            #son继承了来自#father的字体颜色和字号
        </div>
    </div>
</body>
</html>
```
结果：
![1545659782277](/uploads/2018/Web页面布局/1545659782277.png)


##### 优先级

给元素定义样式的方式有好多种，比如ID选择器、类和伪类选择器、标签选择器等。如果通过不同的选择器给相同样式定义了不同的值，这时候样式的层叠就不太一样了。

CSS 给通过不同的选择器定义的样式提供不同的优先级，CSS 的层叠只发生在相同的优先级下，比如上面 CSS 层叠性的代码中，都是通过 ID 选择器来定义的样式。

CSS 使用一套权重系统来计算优先级，使用 `0,0,0,0` 这种值来计算权重，不同的选择器或者定义样式的方法（内联样式、继承来的样式、`!important`申明的样式）会给权重系统提供不同的贡献，最后根据总贡献值来确定哪一套样式会覆盖了哪一套，如果贡献值相同，那么就应用最后定义的那套。这个过程就叫做层叠。

下面这个表格表明了不同的选择器或定义样式的方式的贡献值：

| 方式      | 贡献值 |
| --------------- | ------- |
| 继承来的样式    | 0,0,0,0 |
| 通配符选择器（*）    | 0,0,0,0 |
| 标签选择器    | 0,0,0,1 |
| 类、伪类选择器      | 0,0,1,0 |
| ID选择器        | 0,1,0,0 |
| 内联样式       | 1,0,0,0 |
| !important申明 | 无穷大   |

可以将 `0,0,0,0` 的每一位当成一个级别，`0,0,0,1 > 0,0,0,0`，`0,0,1,0 > 0,0,0,1`，所以，`!important` > 内联样式 > ID选择器 > 类、伪类选择器 > 标签选择器 > 通配符选择器（*）和继承来的样式。

下面看一个例子：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        #app {
            width: 300px;
            height: 300px;
            color: blue;
        }
        .box {
            color: green
        }
    </style>
</head>
<body>
    <div id="app" class="box">
            字体颜色是蓝色，因为类选择器的优先级低于ID选择器
    </div>
</body>
</html>
```

结果：
![1545661905949](/uploads/2018/Web页面布局/1545661905949.png)

优先级是可以叠加的，比如：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        #app {
            width: 300px;
            height: 300px;
        }
        .inner {
            color: blue;
        }
        .box > .inner {
            color: green;
        }
    </style>
</head>
<body>
    <div id="app" class="box">
        <span class="inner">
            字体颜色是绿色，因为两个类的贡献值比一个类的贡献值大
        </span>
    </div>
</body>
</html>
```

![1545662472204](/uploads/2018/Web页面布局/1545662472204.png)

通过计算，`.inner` 的权重是 `0,0,1,0`，而 `.box > .inner` 的权重是 `0,0,2,0`，所以 `.box > .inner` 定义的样式会覆盖掉 `.inner` 定义的样式。同理，如果再加上 `#app > .inner` 还会覆盖掉 `.box > .inner` 定义的选择器，因为 `#app > .inner` 的优先级是 `0,1,1,0`。

需要注意的是！CSS 的优先级没有进位，一百个类选择器定义的样式优先级也不会比一个ID选择器定义的样式优先级高！现在测试下 `!important` 的效果：
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        #app {
            width: 300px;
            height: 300px;
        }
        .inner {
            color: blue;
        }
        .box > .inner {
            color: green;
        }
        * {
            color: purple!important;
        }
    </style>
</head>
<body>
    <div id="app" class="box">
        <span class="inner">
            而!important简直六亲不认，
            即使毫无贡献值的通配符选择器定义的color样式，也秒杀一切
        </span>
    </div>
</body>
</html>
```

![1545663311042](/uploads/2018/Web页面布局/1545663311042.png)

#### 盒子模型

#### 浮动

#### 定位

### CSS 布局方式
https://www.jianshu.com/p/090ada2f3080


## 附录

