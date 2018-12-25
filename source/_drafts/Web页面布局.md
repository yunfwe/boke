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
> 使用现代前端技术开发的应用，不管是 Web 页面，还是混合开发的手机 APP，都离不开页面元素的布局。而布局又可以说是页面开发里最麻烦的地方，不仅要兼容不同的设备，还要兼容不同的浏览器，还很可能一不小心改错了一个值就造成整个页面的雪崩。这里汇总下关于页面布局的基础知识以及一些开发中的经验。
<!-- more -->


## 环境

| 软件 | 版本 |
| ---- | ---- |
| 操作系统 | Windows 10 |
| Chrome浏览器 | 70 |

## 教程
> 这里假使读者已经有了基础的 CSS 知识。如果对这些基础知识还没有概念的话，如果继续往下看，可能会觉得比较难以理解和接受。

### CSS 基础
> 这里讲诉的 CSS 基础重点在于  **三大特性**、**盒子模型**、**浮动** 和 **定位** 这几个方面，其他的背景啊、边框啊也都是细节，而这几个才是整个页面布局的基础。

#### 显示模式

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

顺便一提 `img` 标签和文字在一行时的一些显示：

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
            /* vertical-align: bottom */
        }
        span {
            border: 1px solid #d052d3;
        }
    </style>
</head>
<body>
    <div>
        <img src="css.png">
        <span>一些文字</span>
    </div>
</body>
</html>
```
![1545668809400](/uploads/2018/Web页面布局/1545668809400.gif)

`vertical-align` 可以设置行内和行内块元素垂直对其的方式。`img` 和其他行内元素默认的对齐方式并不是底线对其的！所以可以看到 `img` 比 `span` 高出了几个像素。
同样这个问题也会出现，当使用一个 `div` 去包裹 `img` 的时候，`img` 并不是铺满整个 `div` 的。而是底边会留有几个像素：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        div {
            border: 1px solid #3280f3;
            display: inline-block;
        }
        img {
            width: 150px;
            height: 150px;
        }
    </style>
</head>
<body>
    <div>
        <img src="black.png">
    </div>
</body>
</html>
```

![1545751283265](/uploads/2018/Web页面布局/1545751283265.png)

解决方法也很简单，将 `img` 的垂直对其方式设置为底边对其，或者 将 `img` 的显示模式转换为块元素

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

上面的 `img` 显示问题也可以通过显示转换来解决：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        div {
            border: 1px solid #3280f3;
        }
        img {
            width: 150px;
            height: 150px;
            display: block;
        }
    </style>
</head>
<body>
    <div>
        <img src="black.png">
    </div>
</body>
</html>
```

![1545751535135](/uploads/2018/Web页面布局/1545751535135.png)

##### 其他显示模式

这三种基本的显示模式几乎可以应付大部分的页面布局了，其中还有一些非常好用的显示模式，比如 `display: flex` 可以用来做另外一种页面布局，但是对老旧的电脑浏览器存在一些兼容性问题（比如 IE），如果是手机页面开发，`display: flex` 几乎可以想怎么用就怎么用了。

浏览器开发者模式中可以看到所有支持的显示模式：

![1545670550429](/uploads/2018/Web页面布局/1545670550429.png)


#### 三大特性

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

页面上每一个元素都像是一个盒子，盒子里面放的就是我们要展示的文字、图片或者其他的盒子。然后我们通过摆放盒子的位置来使内容合理的呈现在页面上。


##### 内外边距和边框
在现代浏览器中，每一个盒子都由 **内容区域**、**内边距**、**边框**、**外边距** 组成。

![1545704369752](/uploads/2018/Web页面布局/1545704369752.png)

盒子模型可以比喻成我们拆快递，快递包装的厚度可以想象为边框，快递为了保护里面的东西会有一些填充物，这个填充物就可以当成内边距，而快递里面的东西就是实际的内容了。如果有多个快递，快递与快递之间的距离就是外边距了。下面看代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box {
            width: 100px;
            height: 100px;
            padding: 10px;
            border: 5px solid pink;
            margin: 15px;
            background-color: blue;
            display: inline-block
        }
    </style>
</head>
<body>
    <div class="box"></div>
    <div class="box"></div>
</body>
</html>
```

这里将两个 `div` 元素设置为行内块显示，然后开发者模式查看他们的盒模型：

![1545705114625](/uploads/2018/Web页面布局/1545705114625.gif)

可以看到，给元素设置的宽高实际上是给盒子的内容区域设置的，而元素占的实际空间大小是要加上内外边距还有边框的。我们也可以单独为每一个边设置不同的内外边距还有边框，或者通过将盒子左右外边距设置为 `auto` 来让浏览器自动计算实现盒子居中显示：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box {
            width: 100px;
            height: 100px;
            padding: 10px;
            border: 5px solid pink;
            margin: 15px auto;
            background-color: blue;
        }
    </style>
</head>
<body>
    <div class="box"></div>
</body>
</html>
```

![1545706594946](/uploads/2018/Web页面布局/1545706594946.png)

##### 块元素的上下外边距合并

现在 `.box` 的显示模式是块元素了，如果相邻的两个块元素，上下外边距会有什么不同呢？

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box {
            width: 100px;
            height: 100px;
            padding: 10px;
            border: 5px solid pink;
            margin: 15px auto;
            background-color: blue;
        }
    </style>
</head>
<body>
    <div class="box"></div>
    <div class="box"></div>
</body>
</html>
```

![1545706594946](/uploads/2018/Web页面布局/1545706594948.gif)

如果两个盒子的外边距不同，则会以外边距最大的元素为准：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box {
            width: 100px;
            height: 100px;
            padding: 10px;
            border: 5px solid pink;
            margin: 15px auto;
            background-color: blue;
        }
    </style>
</head>
<body>
    <div class="box"></div>
    <div class="box" style="margin: 25px auto"></div>
</body>
</html>
```

![1545707735409](/uploads/2018/Web页面布局/1545707735409.gif)

如何消除这个影响呢？也很简单，用一个父盒子将其中一个盒子嵌套起来，并给父盒子设置一个 `overflow: hidden`：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box {
            width: 100px;
            height: 100px;
            padding: 10px;
            border: 5px solid pink;
            margin: 15px auto;
            background-color: blue;
        }
        .father {
            overflow: hidden;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box"></div>
    </div>
    <div class="box" style="margin: 25px auto"></div>
</body>
</html>
```
![1545707735410](/uploads/2018/Web页面布局/1545707735410.gif)

添加 `overfiow: hidden` 可以防止 `margin` 合并的原理是 `.father` 的盒子触发了浏览器的 BFC 机制，形成了自己的独立空间，但是它的元素占用空间是由里面的子元素撑起来的，父元素的外边距为 0，所以也不会与下一行的块元素发生重叠（如果给父元素设置了外边距，依然会跟下一行的重叠）。那么什么是 BFC 呢？

##### BFC（块级格式化上下文）

BFC 就是页面上的一个隔离的独立容器，容器里面的子元素不会影响到外面的元素。反之也如此。包括浮动，和外边距合并等等，因此，有了这个特性，我们布局的时候就不会出现意外情况了。

元素如何才能形成 BFC 呢？满足如下几个条件之一即可：

+ `float` 的值不为 `none`
+ `position` 的值不为 `static` 或 `relative`
+ `display` 的值为 `table-cell`、`table-caption`、`inline-block`、`flex` 或 `inline-flex`
+ `overflow` 的值不为 `visibility`

利用 BFC 我们能做些什么呢？

1. 上一节的例子已经看到，BFC 可以防止两个元素上下外边距合并的问题。
2. 清除父元素内部的子元素浮动问题。
3. 父元素内部右侧盒子自适应。

下面看一个例子：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 350px;
            /* height: 350px; */
            border: 1px solid blue;
            /* overflow: hidden; */
            /* display: flex; */
            /* position: absolute; */
            /* float: left; */
        }
        
        .box1 {
            width: 100px;
            height: 100px;
            background: #f66;
            /* float: left; */
        }
        
        .box2 {
            height: 200px;
            width: 200px;
            background: #fcc;
            display: none;
            /* overflow: hidden; */
        }
        .other {
            height: 120px;
            width: 120px;
            background-color: #649ddd;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2">
            文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字
            文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字
        </div>
    </div>
    <div class="other"></div>
</body>
</html>
```

当前元素都一行一行的正常排列着：

![1545714903936](/uploads/2018/Web页面布局/1545714903936.png)

当我们给 `.box1` 添加浮动，一切都改变了：

![1545714972297](/uploads/2018/Web页面布局/1545714972297.png)

`.father` 的内容高度变为了 0，变成了只剩靠 2px 的边框维持的一条线。`.box1` 与 `.other` 发生了重叠，这个就是因为父元素内部子元素浮动产生的问题，我们看看如何来解决这个问题：

![1545715245226](/uploads/2018/Web页面布局/1545715245226.png)

我们给 `.father` 设置了高度，这样看似解决了问题，但是这个高度不是因为内部子元素自动撑开的，而是我们手动设置的，如果内部子元素的高度发生变化，我们还得相应的修改父元素高度以适应，这样显然不是太合理。接下来看看如何使用 BFC 来解决这个问题：

![1545715245227](/uploads/2018/Web页面布局/1545715245227.gif)

首先尝试了使用 `overflow: hidden` 的方式，似乎完美解决了问题，但是如果内部盒子的宽度大于父盒子，则会被隐藏。接着使用 `display: flex` 的方式，这使用了 `flex` 布局。当使用了 `position: absolute` 和 `float: left` 的时候，虽然父元素形成了 BFC，并由内部子元素自动撑开了高度，但是却脱离了文档流，依然与下面的元素发生重叠。

在看看最后一个可以利用 BFC 解决的问题：“父元素内部右侧盒子自适应”。首先给父元素提供一个高度，然后将 `.box2` 的 `display: none` 状态取消：

![1545715245228](/uploads/2018/Web页面布局/1545715245228.gif)

可以看到由于 `.box1` 的浮动，与 `.box2` 产生了重叠，并让 `.box2` 的文字与它产生了环绕效果。当我们让 `.box2` 形成 BFC 会产生什么效果呢？

![1545715245229](/uploads/2018/Web页面布局/1545715245229.gif)

当使用 `overflow: hidden` 触发 BFC 后，`.box2` 的左边框紧贴着 `.box1` 的右边框。当取消手动指定的 `.box2` 宽度后，`.box2` 自动适应了 `.father` 剩余的宽度。

##### 更改盒模型

默认我们对块元素设置宽高是内容区域的宽高，如果对这个盒子进行增加内边距和边框，都会使这个元素变大，这个默认模型是 `content-box`。还有一个常用的模型，让内边距和边框都包含到元素的宽高中，这种模型就是 `border-box`。

我们可以通过 `box-sizing` 来更改盒子模型：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box1 {
            width: 100px;
            height: 100px;
            background-color: pink;
            padding: 10px;
            border: 5px solid gray;
            margin: 20px;
        }
        .box2 {
            box-sizing: border-box;
            width: 100px;
            height: 100px;
            background-color: blue;
            padding: 10px;
            border: 5px solid gray;
            margin: 20px;
        }
    </style>
</head>
<body>
    <div class="box1"></div>
    <div class="box2"></div>
</body>
</html>
```

![1545723227167](/uploads/2018/Web页面布局/1545723227167.png)

`.box2` 由于使用了 `border-box` 模型，所以去掉边框和内边距占用的区域，内容区域只剩下 `70 × 70` 了，看起来也比 `.box1` 小了很多。

#### 定位机制

##### 文档流

不给元素添加浮动或者定位的话，元素就放在文档流（或标准流）中。文档流实际上就是网页内的元素从左往右，从上往下依次排列的布局方式。如果给某个元素添加了浮动或者定位，那么它的显示就不会按照文档流的规则，我们称之为：脱离文档流。

当某个元素脱离的文档流，就不会占用文档流的位置了，所以经常会发现多个元素发生了重叠的现象。脱离了文档流的元素的层级会比文档流中的元素层级高，因此大多情况下都是脱离文档流的元素遮住文档流的元素。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .box1 {
            width: 100px;
            height: 100px;
            background-color: pink;
            float: left;
        }
        .box2 {
            width: 120px;
            height: 120px;
            background-color: blue;
        }
    </style>
</head>
<body>
    <div class="box1"></div>
    <div class="box2"></div>
</body>
</html>
```

![1545727983700](/uploads/2018/Web页面布局/1545727983700.png)

##### 浮动

浮动最早是用来控制图片，为了让其他元素特别是文字实现环绕图片的效果。后来发现浮动可以让任何盒子排在一行，而且中间没有间隙（`inline-block` 的两个盒子中间有间隙），慢慢的人们就会浮动的特性来布局了。

元素设置了浮动样式，会脱离文档流的控制，并移动到浮动样式设置的地方。浮动元素依然受限于父级元素，子元素浮动，父元素依然在文档流中。如果多个子元素都添加了浮动，那么这些元素都有了 `inline-block` 元素的特性

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 300px;
            border: 1px solid blue;
            padding: 10px;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
            float: left;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            float: left;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
            float: right;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <span class="box3"></span>
    </div>
</body>
</html>
```

![1545729291972](/uploads/2018/Web页面布局/1545729291972.png)

可以看到，所有添加了浮动的标签，都有了行内块元素的特性，但是会两边贴合没有缝隙。元素会按照浮动样式的值进行漂移，如果是 `left` 则会贴着父元素的左边排列，`right` 会贴着父元素的右边排列。但是子元素不会超出父元素的内边距距离。

浮动的特性：脱离文档流、不占用原本在文档流中的位置、会影响原本文档流的布局、只有左右浮动或者不浮动。

##### 定位

我们如果想移动某个元素的位置，或者将某个元素直接放置到页面中一个固定的位置，如果不使用定位就非常麻烦或者不可能完成了。就连页面中各种各样的动画，也几乎都是通过定位来做的。

元素的定位属性主要包括定位模式和边偏移两部分，定位属性常用的有四种：`static`，`relative`，`absolute`，`fixed`。边偏移样式：`top`，`bottom`，`left`，`right`。一般偏移样式 `top` 和 `bottom` 只使用一个就够了，`left` 和 `right` 同理，不要既给元素设置了 `left` 然后又设置了 `right`。

偏移量不仅可以使用 `px` 等单位，还可以使用百分比：

```css
.box {
    top: 20px;
    left: 10%;
}
```

并且元素如果添加了定位（除了static定位）都会像给元素添加了浮动一样，将元素模式转换为行内块模式。因此即使是行内元素，也可以直接设置高度和内外上下边距。

###### static

文档流中的所有元素都默认是这个定位方式，而且没法通过边偏移样式进行改变元素位置。

###### relative

相对定位：相对与自身原本在文档流中的位置进行边偏移。不脱离文档流，元素原本的占位依然保留。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 300px;
            border: 1px solid blue;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: relative;
            top: 0px;
            left: 0px;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

给 `.box2` 添加了相对定位，并与原来位置的顶部保持 `0px` 的像素偏移和相对与原来位置的左边保持 `0px` 的像素偏移，然后浏览器开发者模式中手动调整这两个值试试看：

![1545729291973](/uploads/2018/Web页面布局/1545729291973.gif)

相对于 `top` 设置偏移时，如果值小于 0 则向上偏移，如果值大于 0 则向下偏移。`left` 如果值小于 0 则向左偏移，如果值大于 0 则向右偏移。

###### absolute

绝对定位：将元素根据最近的已经定位（相对、绝对、固定都可以）的父级或祖先级元素进行定位，如果所有的父元素都没有定位，则以 document 文档为基准进行定位。完全脱离文档流，元素原本的占位不保留。

因此如果想让某个元素以它的某个父或祖先元素进行定位，就需要给这个元素设置绝对定位，并给父或祖先元素也设置合适的定位方式，如果不想改变父或祖先元素的位置，也不想让父或祖先元素脱离文档流，那最好的方式就是给父或祖先元素设置相对定位。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 1000px;
            border: 1px solid blue;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: absolute;
            top: 0px;
            left: 0px;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

这里将 `.father` 的长度设置为 `1000px` 使页面产生滚动条，然后将 `.box2` 改为绝对定位：

![1545729291974](/uploads/2018/Web页面布局/1545729291974.gif)

由于 `.box2` 的祖先都没有设置定位，因此它的绝对定位是以 `document` 整个页面为基准。完全脱离了文档流，所以它原来的位置被 `.box3` 所占据，并且当文档滚动时它也跟着滚动。如果想让它以 `.father` 元素为基准进行定位，又不想改变 `.father` 元素的位置，那么就最好给 `.father` 元素设置相对定位：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 1000px;
            border: 1px solid blue;
            position: relative;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: absolute;
            top: 0px;
            left: 0px;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545729291975](/uploads/2018/Web页面布局/1545729291975.gif)

`.box2` 以 `.father` 为基准定位，所以覆盖了 `.box1`。如果想要元素相对于父元素水平和垂直居中对齐，可以将四个修改偏移的样式都设置为 0 ，然后将 `margin` 设置为 `auto`，看下面示例：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 400px;
            border: 1px solid blue;
            position: relative;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: absolute;
            /* top: 0px; */
            /* left: 0px; */
            /* bottom: 0; */
            /* right: 0; */
            margin: auto;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
    </div>
</body>
</html>
```
![1545729292975](/uploads/2018/Web页面布局/1545729292975.gif)

通过不同的偏移组合，可以将 `.box1` 定位到父元素中的 8 个位置上。

###### fixed

固定定位：永远以浏览器窗口为基准，不随页面滚动而滚动。完全脱离文档流，元素原本的占位不保留。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 1000px;
            border: 1px solid blue;
            position: relative;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: fixed;
            top: 0px;
            left: 0px;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545729291976](/uploads/2018/Web页面布局/1545729291976.gif)

将 `.box2` 设置为固定定位，可以看到它并不随着页面的滚动而滚动。我们经常看到的页面双侧广告，是不是就是这样子的？固定定位也可以像绝对定位那样，通过将四个偏移样式都设置为 0，然后将 `margin` 设置为 `auto` 的方式实现元素相对于浏览器窗口永远水平和垂直居中：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 400px;
            border: 1px solid blue;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            margin: auto;
            
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545741622908](/uploads/2018/Web页面布局/1545741622908.png)

###### sticky

CSS3 新增的样式，粘性定位，这个就比较有意思了。它相当于 `relative` 和 `fixed` 混合。最初会被当作是 `relative`，相对于原来的位置进行偏移。一旦超过一定阈值之后，会被当成 `fixed`，相对于视口进行定位。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 1000px;
            height: 1000px;
            border: 1px solid blue;
            position: relative;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: sticky;
            top: 20px;
            left: 20px;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545742622908](/uploads/2018/Web页面布局/1545742622908.gif)

有点意思吧！不是实际好像用的并不多。

##### z-index 层级

如果对元素使用了定位，就非常容易发生元素重叠的情况，我们可以使用 `z-index` 来调整定位元素的堆叠顺序，其取值可以为负整数、0 和正整数，值越大，则定位的元素越居上，如果值相同，则后定义的元素居上。

`z-index` 的默认值是 0，并且只有相对定位、绝对定位和固定定位才有此属性。其余标准流，浮动，静态定位都无此属性，也不可指定此属性。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 400px;
            border: 1px solid blue;
            position: relative;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
            position: absolute;
            z-index: 0;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 0;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
            position: absolute;
            top: 40px;
            left: 40px;
            z-index: 0;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545741622910](/uploads/2018/Web页面布局/1545741622910.gif)


#### 显示与隐藏

CSS 中可以控制元素显示与隐藏的样式最常用的有三个，一个是 `display`，一个是 `visibility`，另一个是 `overflow`。

##### display

如果将元素的 `display` 设置为 `none` 将会使这个元素彻底的隐藏掉，元素原来的位置也不再保留：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 400px;
            border: 1px solid blue;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            display: none;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545746851690](/uploads/2018/Web页面布局/1545746851690.png)

可以看到 `.box3` 显示在原来 `.box2` 的位置。于此对应的是，将一个隐藏元素的 `display` 设置为原来的显示模式（一般是 `block`），元素就可以再出现了。

##### visibility

`visibility` 与 `display` 不同的是，隐藏元素后，会保留原来的位置。`visibility` 的值为 `hidden` 时元素隐藏不可见，值为 `visible` 时元素显示出来。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        .father {
            width: 400px;
            height: 400px;
            border: 1px solid blue;
        }
        .box1 {
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
        }
        .box2 {
            width: 100px;
            height: 100px;
            background-color: #8000ff;
            visibility: hidden;
        }
        .box3 {
            width: 100px;
            height: 100px;
            background-color: #ff2f97;
        }
    </style>
</head>
<body>
    <div class="father">
        <div class="box1"></div>
        <div class="box2"></div>
        <div class="box3"></div>
    </div>
</body>
</html>
```

![1545747830399](/uploads/2018/Web页面布局/1545747830399.png)

##### overflow

`overflow` 和上面两个的作用就不太一样了，它主要用于设置当对象的内容超过其指定高度及宽度时如何管理内容。

+ `overflow: visible`：默认值，不剪切内容，也不添加滚动条。
+ `overflow: auto`：超出自动添加滚动条，否则不加
+ `overflow: hidden`：超出部分隐藏掉
+ `overflow: scroll`：不管是否超出，都显示滚动条

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
    <style>
        [class^=box] {
            display: inline-block;
            width: 100px;
            height: 100px;
            background-color: #ff9d6f;
            vertical-align: top;
        }
        .content {
            margin: 10px auto;
            width: 30px;
            height: 200px;
            background-color: #4ed869;
        }
        .box1 {
            overflow: visible;
        }
        .box2 {
            overflow: auto;
        }
        .box3 {
            overflow: hidden;
        }
        .box4 {
            overflow: scroll;
        }
    </style>
</head>
<body>
    <div class="box1">
        <div class="content"></div>
    </div>
    <div class="box2">
        <div class="content"></div>
    </div>
    <div class="box3">
        <div class="content"></div>
    </div>
    <div class="box4">
        <div class="content"></div>
    </div>
</body>
</html>
```
![1545749729658](/uploads/2018/Web页面布局/1545749729658.png)

#### 尺寸单位

页面开发中，我们用的最多的就是使用 `px` 作为单位来编写样式了，偶尔也会用到百分比来写一些元素自适应父元素的样式。但是在移动开发中，为了让一套页面可以适应多套屏幕尺寸，`px` 就不太适用了



### 响应式布局

#### 栅格布局
#### 流式布局
#### flex布局
#### 媒体查询
#### rem/em布局

https://www.jianshu.com/p/090ada2f3080


## 附录

