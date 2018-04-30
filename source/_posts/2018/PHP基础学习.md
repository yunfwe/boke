---
title: PHP基础学习
date: 2018-03-12 11:12:00
categories: 
    - PHP
tags:
    - php
photos:
    - /uploads/photos/bba99e9e78b632000050.jpg
---

## 简介
> PHP全称PHP Hypertext Preprocessor，是一种通用开源脚本语言。语法吸收了C语言、Java和Perl的特点，利于学习，使用广泛，主要适用于Web开发领域。PHP 独特的语法混合了C、Java、Perl以及PHP自创的语法。它可以比CGI或者Perl更快速地执行动态网页。用PHP做出的动态页面与其他的编程语言相比，PHP是将程序嵌入到HTML文档中去执行，执行效率比完全生成HTML标记的CGI要高许多；PHP还可以执行编译后代码，编译可以达到加密和优化代码运行，使代码运行更快。
<!-- more -->

## 环境

### 搭建Windows开发环境
> 系统环境为`Windows 10`，这里使用当前最新版，Windows版PHP下载地址为：[点此打开](http://windows.php.net/download/)

+ 当前最新版PHP为`7.2.3` [点此下载](http://windows.php.net/downloads/releases/php-7.2.3-nts-Win32-VC15-x64.zip)
+ F盘中创建`phpstudy`目录
+ 在`phpstudy`目录中创建`php-7.2.3`、`src`目录
+ 将下载好的`php-7.2.3-nts-Win32-VC15-x64.zip`解压到`php-7.2.3`目录中
+ 将`php-7.2.3`目录下的`php.ini-development`重命名为`php.ini`
+ 创建`start.bat`文件，并写入以下内容
```bat
F:\phpstudy\php-7.2.3\php.exe -S 127.0.0.1:8088 -t F:\phpstudy\src
```

当前目录结构应该如下所示：
![](/uploads/2018/php/ihpp259ge84l7z8a.png)

双击`start.bat`会打开一个cmd窗口 显示内容如下：

    F:\phpstudy>F:\phpstudy\php-7.2.3\php.exe -S 127.0.0.1:8088 -t F:\phpstudy\src
    PHP 7.2.3 Development Server started at Tue Mar  6 13:00:13 2018
    Listening on http://127.0.0.1:8088
    Document root is F:\phpstudy\src
    Press Ctrl-C to quit.

+ 在`src`目录下创建`phpinfo.php`文件，并写入以下内容
```php
<?php
    phpinfo();
?>
```

+ 打开浏览器访问: `http://127.0.0.1:8088/phpinfo.php` 出现如下信息 PHP开发环境就搭建完成了。
![](/uploads/2018/php/n88y0ui8xb35a6p0.png)


## 语法

### 基本语法

#### PHP标记

PHP只会解析文档中`<?php ... ?>`代码块的内容，其他的内容都会忽略

如果文件内容是纯PHP代码，最好在文件末尾删除PHP的结束标记，这样可以避免在PHP结束标记之后万一意外加入了空格或者换行符，会导致 PHP 开始输出这些空白，而脚本中此时并无输出的意图。

```php
<?php
    echo "Hello World";
    // Other Code
    echo "Last statement"
    // 脚本结束，不需要 ?> 作为结束标记
```

PHP还有一种标记方式
```php
<script language="php">
        echo 'Hello World';
</script>
```

显然`<?php ... ?>`的方式更为方便

#### 嵌入到HTML文档

因为PHP只会解析文档中的PHP标记，所以可以很方便的将PHP嵌入到HTML文档中
```php
<p>This is going to be ignored by PHP and displayed by the browser.</p>
<?php echo 'While this is going to be parsed.'; ?>
<p>This will also be ignored by PHP and displayed by the browser.</p>
```

将文档保存为`src`目录下的`index.php`，然后浏览器访问`http://127.0.0.1:8088/`。
可以看到三条语句都被打印出来了，但是通过PHP的`echo`打印的语句需要先解析，所以速度肯定是比较慢的。

PHP解析器遇到`?>`结束标记时就简单的将其后内容原样输出直到再碰到下一个`<?php`标记。例外的是出于条件语句中间时，PHP解析器会根据条件判断来决定哪些输出，哪些跳过。如下所示：
```php
<?php if (true): ?>
  This will show if the expression is true.
<?php else: ?>
  Otherwise this will show.
<?php endif; ?>
```

当`if`的条件为`true`时，输出`This will show if the expression is true.`，否则输出`Otherwise this will show.`。要输出大段文本时，跳出PHP解析模式通常比将文本通过`echo`或`print`输出更有效率。

#### 指令分隔符

PHP和C或者Perl一样，每条语句的末尾使用分号结束指令。如果指令是PHP代码的最后一行，则可以省略掉分号。

```php
<?php
echo "First line<br>";
echo "Last line"
?>
```

如果想要省略掉`?>` 则最后一行语句必须有分号
```php
<?php
echo "First line<br>";
echo "Last line";
```

#### 注释

PHP支持三种注释方法
```
<?php
// This is a one-line c++ style comment

/*
This is a multi line comment
yet another line of comment
*/

# This is a one-line shell-style comment
?>
```

### 类型

> PHP支持9种原始数据类型，其中有四种标量类型，三种复合类型，两种特殊类型

#### 标量类型

##### boolean 布尔型

要指定一个布尔值，使用常量`TRUE`和`FALSE`，两个都**不区分大小写**。

```php
<?php
$a = true;
$b = false;
?>
```

当整数和浮点数的零，空字符串，空数组，NULL，从空标记生成的SimpleXML对象转换为布尔型时 都会认为是FALSE，其他的值都被认为是TRUE

```php
<?php
var_dump((bool) "");
var_dump((bool) 0);
var_dump((bool) 0.0);
var_dump((bool) []);
var_dump((bool) NULL);
?>
```

##### integer 整型

所有的正整数和负整数都属于整数

```
<?php
$a = 1234;          // 十进制数
$a = -123;          // 负数
$a = 0123;          // 八进制数 (等于十进制 83)
$a = 0x1A;          // 十六进制数 (等于十进制 26)
$a = 0b11111111;    // 二进制数字 (等于十进制 255)
?>
```

其他类型转为整数时，FALSE会转为0，TRUE会转为1，浮点型会向下取整。

**注意**：32位平台整数最大为2147483647，64位平台整数最大为9223372036854775807。溢出后将自动转为浮点型。

##### float 浮点型

浮点型就是带小数位的数，可以用以下任一语法定义：
```php
<?php
$a = 1.234; 
$b = 1.2e3; 
$c = 7E-10;
?>
```


##### string 字符串

一个字符串就是由一系列的字符组成，其中每个字符等同于一个字节。这意味着PHP只能支持256的字符集，因此不支持Unicode 。

PHP的字符串有四种方式表达

+ 单引号
+ 双引号
+ heredoc语法结构
+ nowdoc语法结构 (PHP 5.3.0 起)

###### 单引号

定义一个字符串的最简单的方法是用单引号把它包围起来（字符 '）。

要表达一个单引号自身，需在它的前面加个反斜线（\）来转义。要表达一个反斜线自身，则用两个反斜线（\\\\）。其它任何方式的反斜线都会被当成反斜线本身：也就是说如果想使用其它转义序列例如 \r 或者 \n，并不代表任何特殊含义，就单纯是这两个字符本身。

```php
<?php
echo 'this is a simple string';
echo 'You can also have embedded newlines in 
strings this way as it is
okay to do';
echo 'Arnold once said: "I\'ll be back"';
echo 'You deleted C:\\*.*?';
echo 'You deleted C:\*.*?';
echo 'This will not expand: \n a newline';
echo 'Variables do not $expand $either';
?>
```

输出：

    this is a simple string
    You can also have embedded newlines in strings this way as it is okay to do
    Arnold once said: "I'll be back"
    You deleted C:\*.*?
    You deleted C:\*.*?
    This will not expand: \n a newline
    Variables do not $expand $either


###### 双引号

如果字符串是包围在双引号`(")`中， PHP 将对一些特殊的字符进行解析：

<center>**转义字符**</center>

<table><thead><tr><th width="180">序列</th><th>含义</th></tr></thead><tbody><tr><td>\n</td><td>换行（ASCII 字符集中的 LF 或 0x0A）</td></tr><tr><td>\r</td><td>回车（ASCII 字符集中的 CR 或 0x0D）</td></tr><tr><td>\t</td><td>水平制表符（ASCII 字符集中的 HT 或 0x09）</td></tr><tr><td>\v</td><td>垂直制表符（ASCII 字符集中的 VT 或 0x0B）（自PHP 5.2.5 起）</td></tr><tr><td>\e</td><td>Escape（ASCII 字符集中的 ESC 或 0x1B）（自PHP 5.4.0 起）</td></tr><tr><td>\f</td><td>换页（ASCII 字符集中的 FF 或 0x0C）（自PHP 5.2.5 起）</td></tr><tr><td>\\</td><td>反斜线</td></tr><tr><td>\$</td><td>美元标记</td></tr><tr><td>\”</td><td>双引号</td></tr><tr><td>\[0-7]{1,3}</td><td>符合该正则表达式序列的是一个以八进制方式来表达的字符</td></tr><tr><td>\x[0-9A-Fa-f]{1,2}</td><td>符合该正则表达式序列的是一个以十六进制方式来表达的字符</td></tr></tbody></table>


用双引号定义的字符串最重要的特征是变量会被解析

```php
<?php
$a = "World";
echo "Hello $a";
?>
```

输出：

    Hello World


###### Heredoc结构

第三种表达字符串的方法是用 heredoc 句法结构：`<<<`。在该运算符之后要提供一个标识符，然后换行。接下来是字符串 string 本身，最后要用前面定义的标识符作为结束标志。

结束时所引用的标识符必须在该行的第一列，而且，标识符的命名也要像其它标签一样遵守 PHP 的规则：只能包含字母、数字和下划线，并且必须以字母和下划线作为开头。

```php
<?php
$str = <<<END
Example of string
spanning multiple lines</br>
END;
echo $str;

$name = 'MyName';
echo <<<END
My name is $name.
END;
?>
```

输出：

    Example of string spanning multiple lines.
    My name is MyName.

自 PHP 5.3.0 起还可以在 Heredoc 结构中用双引号来声明标识符：

```php
<?php
echo <<<"FOOBAR"
Hello World!
FOOBAR;
?>
```

###### Nowdoc 结构

就象 heredoc 结构类似于双引号字符串，Nowdoc 结构是类似于单引号字符串的。Nowdoc 结构很象 heredoc 结构，但是 nowdoc 中不进行解析操作。

一个 nowdoc 结构也用和 heredocs 结构一样的标记`<<<`， 但是跟在后面的标识符要用单引号括起来，即` <<<'END'`。Heredoc 结构的所有规则也同样适用于 Nowdoc 结构，尤其是结束标识符的规则。

```php
<?php
$str = <<<'END'
Example of string
spanning multiple lines</br>
END;
echo $str;

$name = 'MyName';
echo <<<'END'
My name is $name.
END;
?>
```

输出：

    Example of string spanning multiple lines
    My name is $name.

###### 变量解析

当使用双引号或者Heredoc结构定义时，其中的变量将会解析。

变量解析有两种语法规则，一种简单规则，一种复杂规则。简单规则最常见和方便，它可以用最少的代码在一个string中嵌入一个变量、一个array的值、或一个object的属性。

复杂规则是用花括号包围的表达式。

**简单规则**

```php
<?php
$name = 'Tom';
echo "Hello $name</br>";
$juices = array("apple", "orange", "koolaid1" => "purple");
echo "He drank some $juices[0] juice.</br>";
echo "He drank some $juices[koolaid1] juice.</br>";

class people {
    public $john = "John Smith";
}

$people = new people();
echo "My name is $people->john.";
?>
```

输出：

    Hello Tom
    He drank some apple juice.
    He drank some purple juice.
    My name is John Smith.

**复杂规则**

复杂语法不是因为其语法复杂而得名，而是因为它可以使用复杂的表达式。

任何具有 string 表达的标量变量，数组单元或对象属性都可使用此语法。只需简单地像在 string 以外的地方那样写出表达式，然后用花括号把它括起来即可。

```
<?php
$name = 'Tom';
echo "Hello {$name}</br>";
$juices = array("apple", "orange", "koolaid1" => "purple");
echo "He drank some {$juices[0]} juice.</br>";
echo "He drank some {$juices['koolaid1']} juice.</br>";

class people {
    public $john = "John Smith";
}

$people = new people();
echo "My name is {$people->john}.";
?>
```

**注意**：只有通过花括号才能正确解析带引号的键名`{$juices['koolaid1']}`

输出：

    Hello Tom
    He drank some apple juice.
    He drank some purple juice.
    My name is John Smith.


###### 存取和修改字符串

string 中的字符可以通过一个从 0 开始的下标，用类似 array 结构中的方括号包含对应的数字来访问和修改，比如 `$str[42]`。可以把 string 当成字符组成的 array。函数 `substr()` 和 `substr_replace()` 可用于操作多于一个字符的情况。

小提示：string 也可用花括号访问，比如 `$str{42}`。

```php
<?php
$str = 'This is a test';
echo "First: $str[1]</br>";
$last = $str[strlen($str)-1];
echo "Last: $last</br>";

$str = 'Look at the sea';
$str[strlen($str)-1] = 'e';
echo "$str";
?>
```

输出：

    First: h
    Last: t
    Look at the see


#### 复合类型

##### array 数组

PHP 中的数组实际上是一个有序映射。映射是一种把 values 关联到 keys 的类型。此类型在很多方面做了优化，因此可以把它当成真正的数组，或列表（向量），散列表（是映射的一种实现），字典，集合，栈，队列以及更多可能性。由于数组元素的值也可以是另一个数组，树形结构和多维数组也是允许的。

定义数组：可以用 `array()` 语言结构来新建一个数组。它接受任意数量用逗号分隔的 `键（key） => 值（value）`对。

数组的键可以是一个整数或字符串，值可以是任意类型的值。自 5.4 开始可以使用`[]`代替`array()`。

```php
<?php
$array = array(
    "foo" => "bar",
    "bar" => "foo",
);

// 自 5.4 开始
$array = [
    "foo" => "bar",
    "bar" => "foo",
];

// 没有键名的索引数组
$array = ["foo", "bar", 6=>"hello", "world"];
var_dump($array);
?>
```

如果键名重复，则会使用最后一个键名，前面的都被覆盖了。没有键名的索引数组，键名默认从0开始，如果只对部分单元指定键名，其后面的键名会根据这个单元的键名开始。

输出：

    array(4) { 
        [0]=> string(3) "foo" 
        [1]=> string(3) "bar" 
        [6]=> string(5) "hello" 
        [7]=> string(5) "world" 
    }

使用方括号访问和修改数组单元

```php
<?php
$array = array(
    "foo" => "bar",
    42    => 24,
    "multi" => array(
         "dimensional" => array(
             "array" => "foo"
         )
    )
);
echo "\$array['foo'] = {$array['foo']}</br>";
echo "\$array[42] = $array[42]</br>";
echo "\$array['multi']['dimensional']['array'] = 
    {$array['multi']['dimensional']['array']}</br>";
?>
```

输出：

    $array['foo'] = bar
    $array[42] = 24
    $array['multi']['dimensional']['array'] = foo

小提示：和字符串一样 数组也可以使用花括号访问单元 例如 `array{'foo'}`

要修改某个值，通过其键名给该单元赋一个新值，要删除某个键值对，对其调用`unset()`函数。

```php
<?php
$arr = array(5 => 1, 12 => 2);
$arr[] = 56;    // This is the same as $arr[13] = 56;
                // at this point of the script
$arr["x"] = 42; // This adds a new element to
                // the array with key "x"       
unset($arr[5]); // This removes the element from the array
unset($arr);    // This deletes the whole array
?>
```

##### object 对象

要创建一个新的对象 object，使用 new 语句实例化一个类：

```php
<?php
class foo
{
    function do_foo()
    {
        echo "Doing foo."; 
    }
}
$bar = new foo;
$bar->do_foo();
?>
```

##### callable 可调用

一些函数如 `call_user_func()` 或 `usort()` 可以接受用户自定义的回调函数作为参数。回调函数不止可以是简单函数，还可以是对象的方法，包括静态类方法。除了普通的用户自定义函数外，也可传递匿名函数给回调参数。

#### 特殊类型

##### resource 资源

资源 resource 是一种特殊变量，保存了到外部资源的一个引用。资源是通过专门的函数来建立和使用的。由于资源类型变量保存有为打开文件、数据库连接、图形画布区域等的特殊句柄，因此将其它类型的值转换为资源没有意义。引用计数系统是 Zend 引擎的一部分，可以自动检测到一个资源不再被引用了（和 Java 一样）。这种情况下此资源使用的所有外部资源都会被垃圾回收系统释放。因此，很少需要手工释放内存。

##### NULL 无类型

特殊的 NULL 值表示一个变量没有值。NULL 类型唯一可能的值就是 NULL。

在下列情况下一个变量被认为是 NULL：

+ 被赋值为 NULL。
+ 尚未被赋值。
+ 被 unset()。


PHP 包括几个函数可以判断变量的类型，例如：`gettype()`，`is_array()`，`is_float()`，`is_int()`，`is_object()` 和 `is_string()`

### 变量

#### 基础

PHP 中的变量用一个美元符号后面跟变量名来表示。变量名是区分大小写的。`$this` 是一个特殊的变量，它不能被赋值。

```php
<?php
$var = 'Bob';
$Var = 'Joe';
echo "$var, $Var";      // 输出 "Bob, Joe"

$4site = 'not yet';     // 非法变量名；以数字开头
$_4site = 'not yet';    // 合法变量名；以下划线开头
$i站点is = 'mansikka';  // 合法变量名；可以用中文
?>
```

PHP 也提供了另外一种方式给变量赋值：引用赋值。这意味着新的变量简单的引用了原始变量。改动新的变量将影响到原始变量，反之亦然。
使用引用赋值，简单地将一个 `&` 符号加到将要赋值的变量前。例如，下列代码片断将输出“My name is Bob”两次：

```php
<?php
$foo = 'Bob';              // 将 'Bob' 赋给 $foo
$bar = &$foo;              // 通过 $bar 引用 $foo
$bar = "My name is $bar";  // 修改 $bar 变量
echo "$bar</br>";
echo $foo;                 // $foo 的值也被修改
?>
```

#### 预定义变量

对于全部脚本而言，PHP 提供了大量的预定义变量。这些变量将所有的外部变量表示成内建环境变量，并且将错误信息表示成返回头。

+ 超全局变量 — 超全局变量是在全部作用域中始终可用的内置变量
+ $GLOBALS — 引用全局作用域中可用的全部变量
+ $_SERVER — 服务器和执行环境信息
+ $_GET — HTTP GET 变量
+ $_POST — HTTP POST 变量
+ $_FILES — HTTP 文件上传变量
+ $_REQUEST — HTTP Request 变量
+ $_SESSION — Session 变量
+ $_ENV — 环境变量
+ $_COOKIE — HTTP Cookies
+ $php_errormsg — 前一个错误信息
+ $HTTP\_RAW\_POST_DATA — 原生POST数据
+ $http\_response\_header — HTTP 响应头
+ $argc — 传递给脚本的参数数目
+ $argv — 传递给脚本的参数数组

#### 变量范围

一个局部函数范围将被引入。任何用于函数内部的变量按缺省情况将被限制在局部函数范围内。例如：

```php
<?php
$a = 1; /* global scope */
function Test()
{
    echo $a; /* reference to local scope variable */
}
Test();
?>
```

这个脚本不会有任何输出，因为 echo 语句引用了一个局部版本的变量 $a，而且在这个范围内，它并没有被赋值。你可能注意到 PHP 的全局变量和 C 语言有一点点不同，在 C 语言中，全局变量在函数中自动生效，除非被局部变量覆盖。这可能引起一些问题，有些人可能不小心就改变了一个全局变量。PHP 中全局变量在函数中使用时必须声明为 `global`。

```php
<?php
$a = 1;
$b = 2;
function Sum()
{
    global $a, $b;
    $b = $a + $b;
}
Sum();
echo $b;
?>
```

在全局范围内访问变量的第二个办法，是用特殊的 PHP 自定义` $GLOBALS` 数组。前面的例子可以写成：

```php
<?php
$a = 1;

function Sum()
{
    $GLOBALS['b'] = $GLOBALS['a'] + $GLOBALS['b'];
}
Sum();
echo $b;
?>
```

`$GLOBALS` 是一个关联数组，每一个变量为一个元素，键名对应变量名，值对应变量的内容。`$GLOBALS` 之所以在全局范围内存在，是因为 `$GLOBALS` 是一个超全局变量。

#### 可变变量

可变变量，就是一个变量的变量名可以动态的设置和使用。语法形式是PHP的特殊语法，其他语言中少见。

```php
<?php
$a = 'hello';
$$a = 'world';  // 相当于$hello = 'world'
echo "$a ${$a}</br>";
echo "$a $hello";
?>
```

输出：

    hello world
    hello world

#### 来自PHP之外的变量

##### HTML表单（GET和POST）

当一个表单提交给 PHP 脚本时，表单中的信息会自动在脚本中可用。有很多方法访问此信息，例如：

test.html
```html
<html>
<body>
    <form action="welcome.php" method="post">
        Name: <input type="text" name="name"><br>
        E-mail: <input type="text" name="email"><br>
        <input type="submit">
    </form>
</body>
</html>
```

welcome.php
```php
<html>
<body>
    Welcome <?php echo $_POST["name"]; ?><br>
    Your email address is: <?php echo $_POST["email"]; ?>
</body>
</html>
```

访问 `http://127.0.0.1:8088/test.html`，输入信息后提交，可以看到跳转到了`http://127.0.0.1:8088/welcome.php`页面，并且前面输入的数据已经被PHP通过`_POST`获取了。


GET也类似，只需要将`test.html`中的`method="post"`改为`method="get"`，然后将`welcome.php`中的`$_POST`改为`$_GET`就可以了。但是在上传敏感数据的时候比如用户密码时最好使用POST方法，GET方法会将数据编码到URL上，这样其他用户也可能会获取密码信息了。

##### IMAGE SUBMIT 变量名

当提交表单时，可以用一幅图像代替标准的提交按钮，用类似这样的标记：

```html
<input type="image" src="image.gif" name="sub" />
```

当用户点击到图像中的某处时，相应的表单会被传送到服务器，并加上两个变量 sub_x 和 sub_y。它们包含了用户点击图像的坐标。有经验的用户可能会注意到被浏览器发送的实际变量名包含的是一个点而不是下划线（即 sub.x 和 sub.y），但 PHP 自动将点转换成了下划线。

##### HTTP Cookies

使用`$_COOKIE`可以获取HTTP Cookies数据，在获取前可以使用`setcookie()`函数设定cookies。

```php
<?php
if (isset($_COOKIE['count'])) {
    $count = $_COOKIE['count'] + 1;
} else {
    $count = 1;
}
setcookie('count', $count, time()+3600);
echo $count;
?>
```

浏览器访问然后刷新数据，可以看到每刷新一次数字就增加1。

### 常量

常量表示脚本执行期间不能改变值。传统上常量标识符总是大写的。

可以使用`const`关键字定义常量，而且一旦定义就不可以再修改或者取消定义。常量只能包含boolean、integer、float、string，虽然也可以定义resource常量，但应该尽量避免。与变量不同，不应该在常量前面加上`$`符号。用`get_defined_constants()`获取所有已定义的常量列表。

```php
<?php
define("CONSTANT", "Hello world1.</br>");
echo CONSTANT;
const CONSTANT2 = 'Hello world2.</br>';
echo CONSTANT2;
?>
```

输出：

    Hello world1.
    Hello world2.

小提示：和使用 `define()` 来定义常量相反的是，使用 `const` 关键字定义常量必须处于最顶端的作用区域，因为用此方法是在编译时定义的。这就意味着不能在函数内，循环内以及 if 语句之内用 const 来定义常量。

#### 魔法常量

PHP 向它运行的任何脚本提供了大量的预定义常量。不过很多常量都是由不同的扩展库定义的，只有在加载了这些扩展库时才会出现，或者动态加载后，或者在编译时已经包括进去了。

有八个魔术常量它们的值随着它们在代码中的位置改变而改变。例如 `__LINE__` 的值就依赖于它在脚本中所处的行来决定。这些特殊的常量不区分大小写，如下：

|名称|说明|
|-|-|
|`__LINE__`|	文件中的当前行号。|
|`__FILE__`|	文件的完整路径和文件名。|
|`__DIR__`|	文件所在的目录。|
|`__FUNCTION__`|	函数名称。|
|`__CLASS__`	|类的名称。|
|`__TRAIT__`|	Trait 的名字。Trait 名包括其被声明的作用区域。|
|`__METHOD__`|	类的方法名。返回该方法被定义时的名字。|
|`__NAMESPACE__`|	当前命名空间的名称。|


### 运算符

#### 运算符优先级

下表按照优先级从高到低列出了运算符。同一行中的运算符具有相同优先级，此时它们的结合方向决定求值顺序。

<table><thead><tr><th width="150">结合方向</th><th>运算符</th><th>附加信息</th></tr></thead><tbody><tr><td>无</td><td>`clone` `new`</td><td>clone 和 new</td></tr><tr><td>左</td><td><code>[</code></td><td><span>array()</span></td></tr><tr><td>右</td><td>`**`</td><td>算术运算符</td></tr><tr><td>右</td><td><code>++</code><code>--</code></td><td>类型和递增／递减</td></tr><tr><td>无</td><td><code>instanceof</code></td><td>类型</td></tr><tr><td>右</td><td><code>!</code></td><td>逻辑运算符</td></tr><tr><td>左</td><td><code>*</code><code>/</code><code>%</code></td><td>算术运算符</td></tr><tr><td>左</td><td><code>+</code><code>-</code><code>.</code></td><td>算术运算符和字符串运算符</td></tr><tr><td>左</td><td><code>&lt;&lt;</code><code>&gt;&gt;</code></td><td>位运算符</td></tr><tr><td>无</td><td><code>&lt;</code><code>&lt;=</code><code>&gt;</code><code>&gt;=</code></td><td>比较运算符</td></tr><tr><td>无</td><td><code>== </code><code>!=</code><code>===</code><code>!==</code><code>&lt;&gt;</code><code>&lt;=&gt;</code></td><td>比较运算符</td></tr><tr><td>左</td><td><code>&amp;</code></td><td>位运算符和引用</td></tr><tr><td>左</td><td><code>^</code></td><td>位运算符</td></tr><tr><td>左</td><td><code>|</code></td><td>位运算符</td></tr><tr><td>左</td><td><code>&amp;&amp;</code></td><td>逻辑运算符</td></tr><tr><td>左</td><td><code>||</code></td><td>逻辑运算符</td></tr><tr><td>左</td><td><code>??</code></td><td>比较运算符</td></tr><tr><td>左</td><td><code>?:</code></td><td>三元运算符</td></tr><tr><td>右</td><td><code>=</code><code>+=</code><code>-=</code><code>*=</code><code>**=</code><code>/=</code><code>.=</code><code>%=</code><code>&amp;=</code><code>|=</code><code>^=</code><code>&lt;&lt;=</code><code>&gt;&gt;=</code></td><td>赋值运算符</td></tr><tr><td>左</td><td><code>and</code></td><td>逻辑运算符</td></tr><tr><td>左</td><td><code>xor</code></td><td>逻辑运算符</td></tr><tr><td>左</td><td><code>or</code></td><td>逻辑运算符</td></tr></tbody></table>



#### 算术运算符

|例子|	名称|	结果|
|-|-|-|
|-$a|	取反|	$a 的负值。|
|$a + $b|	加法|	$a 和 $b 的和。|
|$a - $b|	减法|	$a 和 $b 的差。|
|$a * $b|	乘法|	$a 和 $b 的积。|
|$a / $b|	除法|	$a 除以 $b 的商。|
|$a % $b|	取模|	$a 除以 $b 的余数。|
|$a ** $b| 取幂	|	$a 的 $b 次方。|


#### 赋值运算符

基本的赋值运算符是“=”。一开始可能会以为它是“等于”，其实不是的。它实际上意味着把右边表达式的值赋给左边的运算数。

赋值运算表达式的值也就是所赋的值。也就是说，“$a = 3”的值是 3。这样就可以做一些小技巧：
```php
<?php
$a = ($b = 4) + 5; // $a 现在成了 9，而 $b 成了 4。
?>
```

在基本赋值运算符之外，还有适合于所有二元算术，数组集合和字符串运算符的“组合运算符”，这样可以在一个表达式中使用它的值并把表达式的结果赋给它，例如：

```php
<?php
$a = 3;
$a += 5; // sets $a to 8, as if we had said: $a = $a + 5;
$b = "Hello ";
$b .= "There!"; // 将 $b 的值设置为 "Hello There!", 相当于 $b = $b . "There!";
?>
```

小提示：`.`在PHP中用作两个字符串连接。

PHP 支持引用赋值，使用“$var = &$othervar;”语法。引用赋值意味着两个变量指向了同一个数据，没有拷贝任何东西。

```php
<?php
$a = 3;
$b = &$a; // $b 是 $a 的引用
print "$a\n"; // 输出 3
print "$b\n"; // 输出 3
$a = 4; // 修改 $a
print "$a\n"; // 输出 4
print "$b\n"; // 也输出 4，因为 $b 是 $a 的引用，因此也被改变
?>
```


#### 位运算符

<table ><thead><tr><th width="110">例子</th><th width="130">名称</th><th>结果</th></tr></thead><tbody ><tr><td>$a &amp; $b</td><td>And（按位与）</td><td>将把 <var ><var >$a</var></var> 和 <var ><var >$b</var></var> 中都为 1 的位设为 1。</td></tr><tr><td>$a | $b</td><td>Or（按位或）</td><td>将把 <var ><var >$a</var></var> 和 <var ><var >$b</var></var> 中任何一个为 1 的位设为 1。</td></tr><tr><td>$a ^ $b</td><td>Xor（按位异或）</td><td>将把 <var ><var >$a</var></var> 和 <var ><var >$b</var></var> 中一个为 1 另一个为 0 的位设为 1。</td></tr><tr><td>~ $a</td><td>Not（按位取反）</td><td>将 <var ><var >$a</var></var> 中为 0 的位设为 1，反之亦然。</td></tr><tr><td>$a &lt;&lt; $b</td><td>Shift left（左移）</td><td>将 <var ><var >$a</var></var> 中的位向左移动 <var ><var >$b</var></var> 次（每一次移动都表示“乘以 2”）。</td></tr><tr><td>$a &gt;&gt; $b</td><td>Shift right（右移）</td><td>将 <var ><var >$a</var></var> 中的位向右移动 <var ><var >$b</var></var> 次（每一次移动都表示“除以 2”）。</td></tr></tbody></table>

#### 比较运算符

<table><thead><tr><th width="120">例子</th><th width="120">名称</th><th>结果</th></tr></thead><tbody><tr><td>$a == $b</td><td>等于</td><td>TRUE，如果类型转换后 $a 等于 $b。</td></tr><tr><td>$a === $b</td><td>全等</td><td>TRUE，如果 $a 等于 $b，并且它们的类型也相同。</td></tr><tr><td>$a != $b</td><td>不等</td><td>TRUE，如果类型转换后 $a 不等于 $b。</td></tr><tr><td>$a &lt;&gt; $b</td><td>不等</td><td>TRUE，如果类型转换后 $a 不等于 $b。</td></tr><tr><td>$a !== $b</td><td>不全等</td><td>TRUE，如果 $a 不等于 $b，或者它们的类型不同。</td></tr><tr><td>$a &lt; $b</td><td>小与</td><td>TRUE，如果 $a 严格小于 $b。</td></tr><tr><td>$a &gt; $b</td><td>大于</td><td>TRUE，如果 $a 严格大于 $b。</td></tr><tr><td>$a &lt;= $b</td><td>小于等于</td><td>TRUE，如果 $a 小于或者等于 $b。</td></tr><tr><td>$a &gt;= $b</td><td>大于等于</td><td>TRUE，如果 $a 大于或者等于 $b。</td></tr><tr><td>$a &lt;=&gt; $b</td><td>太空船运算符</td><td>当$a小于、等于、大于$b时 分别返回一个小于、等于、大于0的integer 值。 PHP7开始提供.</td></tr><tr><td>$a ?? $b ?? $c</td><td>NULL 合并操作符</td><td>从左往右第一个存在且不为 NULL 的操作数。如果都没有定义且不为 NULL，则返回 NULL。PHP7开始提供。</td></tr></tbody></table>

#### 错误控制运算符

PHP 支持一个错误控制运算符：@。当将其放置在一个 PHP 表达式之前，该表达式可能产生的任何错误信息都被忽略掉。

如果用 `set_error_handler()` 设定了自定义的错误处理函数，仍然会被调用，但是此错误处理函数可以（并且也应该）调用 `error_reporting()`，而该函数在出错语句前有 @ 时将返回 0。

`@` 运算符只对表达式有效。

#### 执行运算符

PHP 支持一个执行运算符：反引号（\`\`）。注意这不是单引号！PHP 将尝试将反引号中的内容作为 shell 命令来执行，并将其输出信息返回。使用反引号运算符\`的效果与函数 shell_exec() 相同。

```php
<?php
echo `ipconfig`;
?>
```

注意：反引号运算符在激活了安全模式或者关闭了 `shell_exec()` 时是无效的。

#### 递增／递减运算符

|例子|	名称|	效果|
|-|-|-|
|++$a	|前加|	$a 的值加一，然后返回 $a。|
|$a++	|后加|	返回 $a，然后将 $a 的值加一。|
|--$a	|前减|	$a 的值减一， 然后返回 $a。|
|$a--	|后减	|返回 $a，然后将 $a 的值减一。|

#### 逻辑运算符

<table><thead><tr><th width="150">例子</th><th width="150">名称</th><th>结果</th></tr></thead><tbody><tr><td>$a and $b</td><td>And（逻辑与）</td><td><code>TRUE</code>，如果 <var><var>$a</var></var> 和 <var><var>$b</var></var> 都为 <code>TRUE</code>。</td></tr><tr><td>$a or $b</td><td>Or（逻辑或）</td><td><code>TRUE</code>，如果 <var><var>$a</var></var> 或 <var><var>$b</var></var> 任一为 <code>TRUE</code>。</td></tr><tr><td>$a xor $b</td><td>Xor（逻辑异或）</td><td><code>TRUE</code>，如果 <var><var>$a</var></var> 或 <var><var>$b</var></var> 任一为 <code>TRUE</code>，但不同时是。</td></tr><tr><td>!$a</td><td>Not（逻辑非）</td><td><code>TRUE</code>，如果 <var><var>$a</var></var> 不为 <code>TRUE</code>。</td></tr><tr><td>$a &amp;&amp;$b</td><td>And（逻辑与）</td><td><code>TRUE</code>，如果 <var><var>$a</var></var> 和 <var><var>$b</var></var> 都为 <code>TRUE</code>。</td></tr><tr><td>$a || $b</td><td>Or（逻辑或）</td><td><code>TRUE</code>，如果 <var><var>$a</var></var> 或 <var><var>$b</var></var> 任一为 <code>TRUE</code>。</td></tr></tbody></table>

#### 字符串运算符

有两个字符串（string）运算符。第一个是连接运算符 `.`，它返回其左右参数连接后的字符串。第二个是连接赋值运算符 `.=`，它将右边参数附加到左边的参数之后。

```php
<?php
$a = "Hello ";
$b = $a . "World!"; // 现在 $b 等于 "Hello World!"

$a = "Hello ";
$a .= "World!";     // 现在 $a 等于 "Hello World!"
?>
```

#### 数组运算符

<table><thead><tr><th width="150">例子</th><th width="150">名称</th><th>结果</th></tr></thead><tbody><tr><td>$a + $b</td><td>联合</td><td><var><var>$a</var></var> 和 <var><var>$b</var></var> 的联合。</td></tr><tr><td>$a == $b</td><td>相等</td><td>如果 <var><var>$a</var></var> 和 <var><var>$b</var></var> 具有相同的键／值对则为 <code>TRUE</code>。</td></tr><tr><td>$a === $b</td><td>全等</td><td>如果 <var><var>$a</var></var> 和 <var><var>$b</var></var> 具有相同的键／值对并且顺序和类型都相同则为 <code>TRUE</code>。</td></tr><tr><td>$a != $b</td><td>不等</td><td>如果 <var><var>$a</var></var> 不等于 <var><var>$b</var></var> 则为 <code>TRUE</code>。</td></tr><tr><td>$a &lt;&gt;$b</td><td>不等</td><td>如果 <var><var>$a</var></var> 不等于 <var><var>$b</var></var> 则为 <code>TRUE</code>。</td></tr><tr><td>$a !== $b</td><td>不全等</td><td>如果 <var><var>$a</var></var> 不全等于 <var><var>$b</var></var> 则为 <code>TRUE</code>。</td></tr></tbody></table>

#### 类型运算符

`instanceof` 用于确定一个 PHP 变量是否属于某一类 class 的实例：

```php
<?php
class MyClass {}
class NotMyClass{}
$a = new MyClass;
var_dump($a instanceof MyClass);
echo '</br>';
var_dump($a instanceof NotMyClass);
?>
```

输出：

    bool(true) 
    bool(false)

### 流程控制

任何 PHP 脚本都是由一系列语句构成的。一条语句可以是一个赋值语句，一个函数调用，一个循环，一个条件语句或者甚至是一个什么也不做的语句（空语句）。语句通常以分号结束。此外，还可以用花括号将一组语句封装成一个语句组。语句组本身可以当作是一行语句。

#### 条件判断

##### if

语法：

    <?php
    if (expr) {
        statement
    }
    ?>

如果有多个表达式，使用花括号括起来

例子：

```php
<?php
if ($a > $b) {
    echo "a is greater than b";
}
?>
```


##### if-else

语法：

    <?php
    if (expr) {
        statement
    } else {
        statement
    }
    ?>

例子：

```php
<?php
$a = 2;
$b = 4;
if ($a > $b) {
  echo "a is greater than b";
} else {
  echo "a is NOT greater than b";
}
?>
```

##### if-elseif-else

语法：

    <?php
    if (expr) {
        statement
    } elseif (expr) {
        statement
    } else {
        statement
    }
    ?>

例子：

```php
<?php
$a = 2;
$b = 2;
if ($a > $b) {
    echo "a is bigger than b";
} elseif ($a == $b) {
    echo "a is equal to b";
} else {
    echo "a is smaller than b";
}
?>
```

在同一个 if 语句中可以有多个 elseif 部分，其中第一个表达式值为 TRUE 的 elseif 部分将会执行。在 PHP 中，也可以写成"else if"，它和"elseif"的行为完全一样。

#### 流程控制的替代语法

PHP 提供了一些流程控制的替代语法，包括 if，while，for，foreach 和 switch。替代语法的基本形式是把左花括号 `{` 换成冒号 `:` ，把右花括号 `}` 分别换成 endif;，endwhile;，endfor;，endforeach; 以及 endswitch;。

```php
<?php $a = 5; ?>
<?php if ($a == 5): ?>
    A is equal to 5
<?php endif; ?>
```

同样还可以用在 else 和 elseif 中

```php
<?php
$a = 6;
if ($a == 5):
    echo "a equals 5";
    echo "...";
elseif ($a == 6):
    echo "a equals 6";
    echo "!!!";
else:
    echo "a is neither 5 nor 6";
endif;
?>
```

注意：不支持在同一个控制块内混合使用两种语法。

#### 循环

##### while循环

while 循环是 PHP 中最简单的循环类型。它和 C 语言中的 while 表现地一样。while 语句的基本格式是：

    while (expr) {
        statement
    }
        
如果表达式只有一句 也可以将花括号省略掉。

while 语句的含义很简单，只要 while 的表达式值为 TRUE ，就重复执行嵌套中的循环语句，表达式的值在每次开始循环时检查，直到表达式为 FALSE 为止。

```php
<?php
$a = 0;
while ($i <= 10) {
    echo $i++;
}
?>
```

##### do-while循环

do-while 循环是先循环 后判断，所以 do-while 不管表达式是否为 TRUE 都会至少循环一次。

```php
<?php
$i = 0;
do {
   echo $i++;
} while ($i <= 10);
?>
```

##### for循环

for循环是相对比较复杂但同时更强大的循环方法。for循环的语法是：

    for (expr1; expr2; expr3) {
        statement
    }

第一个表达式(expr1)在循环前执行一次。第二个表达式在每次循环开始前执行，如果值为 TRUE 则继续执行，FALSE 则跳出循环。第三个表达式在每次循环之后被执行。

每个表达式都可以为空或包括逗号分隔的多个表达式，表达式 expr2 中，所有用逗号分隔的表达式都会计算，但只取最后一个结果。expr2 为空意味着将无限循环下去。如果死循环，可以在循环语句中使用break跳出去。

```php
<?php
for ($i = 1; $i <= 10; $i++) {
    echo $i;
}
echo "</br>";
for ($i = 1; ; $i++) {
    if ($i > 10) {
        break;
    }
    echo $i;
}
?>
```

PHP 也支持用冒号的 for 循环的替代语法。

    for (expr1; expr2; expr3):
        statement;
        ...
    endfor;

##### foreach

foreach 语法结构提供了遍历数组的简单方式。foreach 仅能够应用于数组和对象，如果尝试应用于其他数据类型的变量，或者未初始化的变量将发出错误信息。有两种语法：

    foreach (array_expression as $value)
        statement
    foreach (array_expression as $key => $value)
        statement

第一种格式遍历给定的 array_expression 数组。每次循环中，当前单元的值被赋给 $value 并且数组内部的指针向前移一步（因此下一次循环中将会得到下一个单元）。

第二种格式做同样的事，只除了当前单元的键名也会在每次循环中被赋给变量 $key。

可以很容易地通过在 $value 之前加上 & 来修改数组的元素。此方法将以引用赋值而不是拷贝一个值。

```php
<?php
$arr = array(1, 2, 3, 4);
foreach ($arr as &$value) {
    $value = $value * 2;
}
// $arr is now array(2, 4, 6, 8)
unset($value); // 最后取消掉引用
?>
```

PHP 5.5 增添了遍历一个数组的数组的功能并且把嵌套的数组解包到循环变量中，只需将 list() 作为值提供。

```php
<?php
$array = [
    [1, 2],
    [3, 4],
];

foreach ($array as list($a, $b)) {
    // $a contains the first element of the nested array,
    // and $b contains the second element.
    echo "A: $a; B: $b\n";
}
?>
```

list() 中的单元可以少于嵌套数组的，此时多出来的数组单元将被忽略。如果 list() 中列出的单元多于嵌套数组则会发出一条消息级别的错误信息。

#### break 跳出循环

break 结束当前 for，foreach，while，do-while 或者 switch 结构的执行。

break 可以接受一个可选的数字参数来决定跳出几重循环。

```php
<?php
$arr = array('one', 'two', 'three', 'four', 'stop', 'five');
while (list (, $val) = each($arr)) {
    if ($val == 'stop') {
        break;    /* You could also write 'break 1;' here. */
    }
    echo "$val<br />\n";
}

/* 使用可选参数 */

$i = 0;
while (++$i) {
    switch ($i) {
    case 5:
        echo "At 5<br />\n";
        break 1;  /* 只退出 switch. */
    case 10:
        echo "At 10; quitting<br />\n";
        break 2;  /* 退出 switch 和 while 循环 */
    default:
        break;
    }
}
?>
```
注意：在PHP 5.4.0 之后，取消变量作为参数传递（例如 `$num = 2; break $num;`）。

#### continue 跳出本次循环

continue 在循环结构用用来跳过本次循环中剩余的代码并在条件求值为真时开始执行下一次循环。

小提示：注意在 PHP 中 switch 语句被认为是可以使用 continue 的一种循环结构。
continue 接受一个可选的数字参数来决定跳过几重循环到循环结尾。默认值是 1，即跳到当前循环末尾。


```php
<?php
while (list ($key, $value) = each($arr)) {
    if (!($key % 2)) { // skip odd members
        continue;
    }
    do_something_odd($value);
}

$i = 0;
while ($i++ < 5) {
    echo "Outer<br />\n";
    while (1) {
        echo "Middle<br />\n";
        while (1) {
            echo "Inner<br />\n";
            continue 3;
        }
        echo "This never gets output.<br />\n";
    }
    echo "Neither does this.<br />\n";
}
?>
```

注意：在PHP 5.4.0 之后，取消变量作为参数传递（例如 `$num = 2; continue $num;`）。

#### switch 分支选择

switch 语句类似于具有同一个表达式的一系列 if 语句。很多场合下需要把同一个变量（或表达式）与很多不同的值比较，并根据它等于哪个值来执行不同的代码。这正是 switch 语句的用途。

小提示：注意和其它语言不同，continue 语句作用到 switch 上的作用类似于 break。如果在循环中有一个 switch 并希望 continue 到外层循环中的下一轮循环，用 continue 2。

switch 结构示例：

```php
<?php
switch ($i) {
    case 0:
        echo "i equals 0";
        break;
    case 1:
        echo "i equals 1";
        break;
    case 2:
        echo "i equals 2";
        break;
    default:
        echo "i is not equal to 0, 1 or 2";
}
?>
```

switch 结构中 case 的目标还可以是字符串。case 会依次执行。如果没有 break 将会继续执行下面的 case 代码。default 是所有的 case 都没有匹配时执行。

#### declare

declare 结构用来设定一段代码的执行指令。declare 的语法和其它流程控制结构相似：

    declare (directive)
        statement

directive 部分允许设定 declare 代码段的行为。目前只认识两个指令：ticks 以及 encoding，declare 调试内部程序使用.

`declare(ticks=n)` 和 `register_tick_function('handel_function')` 一般是配合使用的。`ticks` 参数表示运行多少语句调用一次 `register_tick_function` 的函数。并且declare支持两种写法：

```php
declare(ticks = 1); //整个脚本

declare(ticks = 1) { 
    ......  // 内部的代码做记录
}
```

例如：

```php
<?php

declare(ticks=1);

// A function called on each tick event
function tick_handler()
{
    echo "tick_handler() called\n";
}
register_tick_function('tick_handler');
$a = 1;
if ($a > 0) {
    $a += 2;
    print($a);
}
?>
```

encoding 指令来对每段脚本指定其编码方式。

```php
<?php
declare(encoding='ISO-8859-1');
// code here
?>
```

在 PHP 5.3 中除非在编译时指定了 `--enable-zend-multibyte`，否则 declare 中的 encoding 值会被忽略。

#### return

如果在一个函数中调用 return 语句，将立即结束此函数的执行并将它的参数作为函数的值返回。return 也会终止 eval() 语句或者脚本文件的执行。

如果在全局范围中调用，则当前脚本文件中止运行。如果当前脚本文件是被 include 的或者 require 的，则控制交回调用文件。此外，如果当前脚本是被 include 的，则 return 的值会被当作 include 调用的返回值。如果在主脚本文件中调用 return，则脚本中止运行。如果当前脚本文件是在 php.ini 中的配置选项 `auto_prepend_file` 或者 `auto_append_file `所指定的，则此脚本文件中止运行。

#### require

require 和 include 几乎完全一样，除了处理失败的方式不同之外。require 在出错时产生 `E_COMPILE_ERROR` 级别的错误。换句话说将导致脚本中止而 include 只产生警告 `E_WARNING` ，脚本会继续运行。

还有一个和 require 作用完全相同的是 `require_once`，不同的是如果这个文件已经被包含，`require_once` 则不会再次包含这个文件。

#### include

被包含文件先按参数给出的路径寻找，如果没有给出目录（只有文件名）时则按照 `include_path` 指定的目录寻找。如果在 `include_path` 下没找到该文件则 include 最后才在调用脚本文件所在的目录和当前工作目录下寻找。如果最后仍未找到文件则 include 结构会发出一条警告；这一点和 require 不同，后者会发出一个致命错误。`include_path` 是在 `php.ini` 配置文件中定义的。

如果定义了路径——不管是绝对路径还是当前目录的相对路径 `include_path` 都会被完全忽略。例如一个文件以 `../` 开头，则解析器会在当前目录的父目录下寻找该文件。

当一个文件被包含时，其中所包含的代码继承了 include 所在行的变量范围。从该处开始，调用文件在该行处可用的任何变量在被调用的文件中也都可用。不过所有在包含文件中定义的函数和类都具有全局作用域。


vars.php
```php
<?php
$color = 'green';
$fruit = 'apple';
?>
```

test.php
```php
<?php
echo "A $color $fruit"; // A
include 'vars.php';
echo "A $color $fruit"; // A green apple
?>
```

如果 include 出现于调用文件中的一个函数里，则被调用的文件中所包含的所有代码将表现得如同它们是在该函数内部定义的一样。所以它将遵循该函数的变量范围。

test2.php
```php
<?php
function foo() {
    global $color;
    include 'vars.php';
    echo "A $color $fruit";
}
foo();                      // A green apple
echo "A $color $fruit";     // A green
?>
```

`include_once` 可以用于在脚本执行期间同一个文件有可能被包含超过一次的情况下，想确保它只被包含一次以避免函数重定义，变量重新赋值等问题。


#### goto 跳转

goto 操作符可以用来跳转到程序中的另一位置。该目标位置可以用目标名称加上冒号来标记，而跳转指令是 goto 之后接上目标位置的标记。PHP 中的 goto 有一定限制，目标位置只能位于同一个文件和作用域，也就是说无法跳出一个函数或类方法，也无法跳入到另一个函数。也无法跳入到任何循环或者 switch 结构中。可以跳出循环或者 switch，通常的用法是用 goto 代替多层的 break。

```php
<?php
goto a;
echo 'Foo';
 
a:
echo 'Bar';
?>
```

跳出循环示例：

```php
<?php
for($i=0,$j=50; $i<100; $i++) {
  while($j--) {
    if($j==17) goto end; 
  }  
}
echo "i = $i";
end:
echo 'j hit 17';
?>
```

goto 可以跳出循环 而不可以跳进循环内。

### 函数

#### 自定义函数

任何有效的 PHP 代码都有可能出现在函数内部，甚至包括其它函数和类定义。

```php
<?php
foo();
bar();
function foo() {
    function bar() {
        echo "I don't exist until foo() is called.";
    }
}
?>
```

可以看到，函数并非只有定义后才能调用。而且bar()函数只有foo()函数调用后才会创建的。

PHP 中的所有函数和类都具有全局作用域，可以定义在一个函数之内而在之外调用，反之亦然。PHP 不支持函数重载，也不可能取消定义或者重定义已声明的函数。PHP 的函数支持可变数量的参数和默认参数。

在 PHP 中还可以递归调用函数，但是要避免递归超过100-200层，因为可能会使堆栈崩溃从而使当前脚本终止。 无限递归可视为编程错误。

#### 函数参数

##### 普通参数

通过参数列表可以传递信息到函数。

```php
<?php
function takes_array($input)
{
    echo "$input[0] + $input[1] = ", $input[0]+$input[1];
}
takes_array([2, 4]);
?>
```

##### 传递引用

默认情况下，函数参数通过值传递。如果希望允许函数修改它的参数值，必须通过引用传递参数。

```php
<?php
function add_some_extra(&$string)
{
    $string .= 'and something extra.';
}
$str = 'This is a string, ';
add_some_extra($str);
echo $str;    // outputs 'This is a string, and something extra.'
?>
```

##### 参数默认值

在函数中可以给参数提供一个默认值

```php
<?php
function makecoffee($type = "cappuccino")
{
    return "Making a cup of $type.\n";
}
echo makecoffee();
echo makecoffee(null);
echo makecoffee("espresso");
?>
```

默认值必须是常量表达式，不能是诸如变量，类成员，或者函数调用等。

注意：当使用默认参数时，任何默认参数必须放在任何非默认参数的右侧。否则，函数将不会按照预期的情况工作。

比如下面代码将不能正确运行：

```php
<?php
function makeyogurt($type = "acidophilus", $flavour)
{
    return "Making a bowl of $type $flavour.\n";
}
echo makeyogurt("raspberry");   // won't work as expected
?>
```

##### 类型声明

类型声明允许函数在调用时要求参数为特定类型。 如果给出的值类型不对，那么将会产生一个错误： 在PHP 5中，这将是一个可恢复的致命错误，而在PHP 7中将会抛出一个TypeError异常。

为了指定一个类型声明，类型应该加到参数名前。这个声明可以通过将参数的默认值设为NULL来实现允许传递NULL。

可用类型：

|类型	|描述	|最低PHP版本|
|-|-|-|
|类/接口名	|参数必须是特定的类或接口的名称	|PHP 5.0.0|
|self	|参数必须是自身的方法	|PHP 5.0.0
|array	|参数必须是一个数组	|PHP 5.1.0|
|callable	|参数必须是一个可调用对象	|PHP 5.4.0|
|bool|	参数必须是一个布尔值	|PHP 7.0.0|
|float|	参数必须是一个浮点数|	PHP 7.0.0|
|int	|参数必须是一个整型|PHP 7.0.0|
|string	|参数必须是一个字符串|PHP 7.0.0|


基础类类型声明：
```php
<?php
class C {}
class D extends C {}

// This doesn't extend C.
class E {}

function f(C $c) {
    echo get_class($c)."\n";
}

f(new C);
f(new D);
f(new E);       // 这里会报错，因为f()只接受C类和C类的子类的实例
?>
```

##### 可变参数

PHP 在用户自定义函数中支持可变数量的参数列表。在 PHP 5.6 及以上的版本中，由 `...` 语法实现；在 PHP 5.5 及更早版本中，使用函数 `func_num_args()`，`func_get_arg()`，和 `func_get_args()` 。

在 PHP 5.6+
```php
<?php
function sum(...$numbers) {
    $acc = 0;
    foreach ($numbers as $n) {
        $acc += $n;
    }
    return $acc;
}
echo sum(1, 2, 3, 4);
?>
```

还可以使用 `...` 来提供参数

```php
<?php
function add($a, $b) {
    return $a + $b;
}
echo add(...[1, 2]);
?>
```

在 PHP 5.5 和之前版本访问参数列表

```php
<?php
function sum() {
    $acc = 0;
    foreach (func_get_args() as $n) {
        $acc += $n;
    }
    return $acc;
}
echo sum(1, 2, 3, 4);
?>
```

#### 返回值

值通过使用可选的返回语句返回。可以返回包括数组和对象的任意类型。返回语句会立即中止函数的运行，并且将控制权交回调用该函数的代码行。如果省略了 return，则返回值为 NULL。

示例：

```php
<?php
function square($num)
{
    return $num * $num;
}
echo square(4);   // outputs '16'.
?>
```

函数不能返回多个值，但可以通过返回一个数组来得到类似的效果。

```php
<?php
function small_numbers()
{
    return array (0, 1, 2);
}
list ($zero, $one, $two) = small_numbers();
?>
```

从函数返回一个引用，必须在函数声明和指派返回值给一个变量时都使用引用运算符 &：

```php
<?php
function &returns_reference()
{
    return $someref;
}
$newref =& returns_reference();
?>
```

返回一个对象：

```php
<?php
class C {}
function getC(): C {
    return new C;
}
var_dump(getC());
?>
```

#### 可变函数

PHP 支持可变函数的概念。这意味着如果一个变量名后有圆括号，PHP 将寻找与变量的值同名的函数，并且尝试执行它。可变函数可以用来实现包括回调函数，函数表在内的一些用途。

可变函数不能用于例如 echo，print，unset()，isset()，empty()，include，require 以及类似的语言结构。需要使用自己的包装函数来将这些结构用作可变函数。

示例：
```php
<?php
function foo() {
    echo "In foo()<br />\n";
}
function bar($arg = '') {
    echo "In bar(); argument was '$arg'.<br />\n";
}
// 使用 echo 的包装函数
function echoit($string)
{
    echo $string;
}
$func = 'foo';
$func();        // 将调用 foo()
$func = 'bar';
$func('test');  // 将调用 bar()
$func = 'echoit';
$func('test');  // 将调用 echoit()
?>
```

也可以用可变函数的语法来调用一个对象的方法。

```php
<?php
class Foo {
    function Variable() {
        $name = 'Bar';
        $this->$name(); // This calls the Bar() method
    }

    function Bar() {
        echo "This is Bar";
    }
}

$foo = new Foo();
$funcname = "Variable";
$foo->$funcname();   // This calls $foo->Variable()
?>
```

#### 内置函数

PHP 有很多标准的函数和结构。还有一些函数需要和特定地 PHP 扩展模块一起编译，否则在使用它们的时候就会得到一个致命的“未定义函数”错误。例如，要使用 image 函数中的 `imagecreatetruecolor()`，需要在编译 PHP 的时候加上 GD 的支持。或者，要使用 `mysql_connect()` 函数，就需要在编译 PHP 的时候加上 MySQL 支持。有很多核心函数已包含在每个版本的 PHP 中如字符串和变量函数。调用 `phpinfo()` 或者 `get_loaded_extensions()` 可以得知 PHP 加载了那些扩展库。


#### 匿名函数

匿名函数也叫闭包函数，就是创建一个没有函数名的函数。最经常用作回调函数。

闭包函数也可以作为变量的值来使用。PHP 会自动把此种表达式转换成内置类 Closure 的对象实例。把一个 closure 对象赋值给一个变量的方式与普通变量赋值的语法是一样的，最后也要加上分号：

```php
<?php
$greet = function($name)
{
    printf("Hello %s\r\n", $name);
};
$greet('World');
$greet('PHP');
?>
```

闭包可以从父作用域中继承变量。 任何此类变量都应该用 use 语言结构传递进去。 PHP 7.1 起，不能传入此类变量： superglobals、 $this 或者和参数重名。

从父作用域继承变量
```php
<?php
$message = 'hello';

// 没有 "use"
$example = function () {
    var_dump($message);
};
echo $example()."</br>";

// 继承 $message
$example = function () use ($message) {
    var_dump($message);
};
echo $example()."</br>";

// 继承变量的值是在定义函数时，而不是在调用时定义的
$message = 'world';
echo $example()."</br>";

// 重新设置 $message
$message = 'hello';

// 继承引用
$example = function () use (&$message) {
    var_dump($message);
};
echo $example()."</br>";

// 父作用域中的更改值反映在函数调用中。
$message = 'world';
echo $example()."</br>";

// 匿名函数也可以接受参数。
$example = function ($arg) use ($message) {
    var_dump($arg . ' ' . $message);
};
$example("hello");
?>
```

输出：

    Notice: Undefined variable: message in F:\phpstudy\src\index.php on line 6
    NULL 
    string(5) "hello" 
    string(5) "hello" 
    string(5) "hello" 
    string(5) "world" 
    string(11) "hello world"

这些变量都必须在函数或类的头部声明。 从父作用域中继承变量与使用全局变量是不同的。全局变量存在于一个全局的范围，无论当前在执行的是哪个函数。而闭包的父作用域是定义该闭包的函数。

小提示：可以在闭包中使用 `func_num_args()`，`func_get_arg()` 和 `func_get_args()`。

### 类与对象

自 PHP 5 起完全重写了对象模型以得到更佳性能和更多特性。这是自 PHP 4 以来的最大变化。PHP 5 具有完整的对象模型。
PHP 5 中的新特性包括访问控制，抽象类和 final 类与方法，附加的魔术方法，接口，对象复制和类型约束。
PHP 对待对象的方式与引用和句柄相同，即每个变量都持有对象的引用，而不是整个对象的拷贝。

#### 基本概念

每个类的定义都以关键字 class 开头，后面跟着类名，后面跟着一对花括号，里面包含有类的属性与方法的定义。
一个类可以包含有属于自己的常量，变量（称为"属性"）以及函数（称为"方法"）。

##### 类的定义

一个简单的类定义：
```php
<?php
class SimpleClass
{
    // 属性声明
    public $var = 'a default value';

    // 方法声明
    public function displayVar() {
        echo $this->var;
    }
}
?>
```

##### $this 伪变量

当一个方法在类定义内部被调用时，有一个可用的伪变量 $this。$this 是一个到主叫对象的引用

$this 的使用示例：
```php
<?php
class A {
    function foo() {
        if (isset($this)) {
            echo '$this is defined (';
            echo get_class($this);
            echo ")\n";
        } else {
            echo "\$this is not defined.\n";
        }
    }
}

class B {
    function bar() {
        A::foo();
    }
}

$a = new A();
$a->foo();
A::foo();
$b = new B();
$b->bar();
B::bar();
?>
```

输出：

    $this is defined (A) 
    $this is not defined. 
    $this is not defined. 
    $this is not defined.


##### new 创建实例

要创建一个类的实例，必须使用 new 关键字。当创建新对象时该对象总是被赋值，除非该对象定义了构造函数并且在出错时抛出了一个异常。

如果在 new 之后跟着的是一个包含有类名的字符串，则该类的一个实例被创建。如果该类属于一个名字空间，则必须使用其完整名称。

创建一个实例：
```php
<?php
$instance = new SimpleClass();

// 也可以这样做
$className = 'Foo';
$instance = new $className(); // Foo()
?>
```

当把一个对象已经创建的实例赋给一个新变量时，新变量会访问同一个实例，就和用该对象赋值一样。此行为和给函数传递入实例时一样。可以用克隆给一个已创建的对象建立一个新实例。

```php
<?php
class SimpleClass {};

$instance = new SimpleClass();
$assigned   =  $instance;
$reference  =& $instance;
$instance->var = '$assigned will have this value';
$instance = null; // $instance and $reference become null

var_dump($instance);
echo '</br>';
var_dump($reference);
echo '</br>';
var_dump($assigned);
?>
```

输出：

    NULL 
    NULL 
    object(SimpleClass)#1 (1) { 
        ["var"]=> string(30) "$assigned will have this value" 
    }



##### ::class

自 PHP 5.5 起，关键词 class 也可用于类名的解析。使用 `ClassName::class` 你可以获取一个字符串，包含了类 ClassName 的完全限定名称。这对使用了 命名空间 的类尤其有用。

示例：
```php
<?php
namespace NS {
    class ClassName { }
    echo ClassName::class;
}
?>
```

输出：

    NS\ClassName


#### 属性

类的变量成员叫做"属性"，属性声明是由关键字 `public`，`protected` 或者 `private` 开头，然后跟一个普通的变量声明来组成。属性中的变量可以初始化，但是初始化的值必须是常数，这里的常数是指 PHP 脚本在编译阶段时就可以得到其值，而不依赖于运行时的信息才能求值。

在类的成员方法里面，可以用 `->`（对象运算符）：`$this->property`（其中 property 是该属性名）这种方式来访问非静态属性。静态属性则是用 `::`（双冒号）：`self::$property` 来访问。更多静态属性与非静态属性的区别参见 static 关键字。

属性声明：

```php
<?php
class SimpleClass
{
   // 错误的属性声明
   public $var1 = 'hello ' . 'world';
   public $var2 = <<<EOD
hello world
EOD;
   public $var3 = 1+2;
   public $var4 = self::myStaticMethod();
   public $var5 = $myVar;

   // 正确的属性声明
   public $var6 = myConstant;
   public $var7 = array(true, false);

   //在 PHP 5.3.0 及之后，下面的声明也正确
   public $var8 = <<<'EOD'
hello world
EOD;
}
?>
```

#### 类常量

可以把在类中始终保持不变的值定义为常量。在定义和使用常量的时候不需要使用 $ 符号。常量的值必须是一个定值，不能是变量，类属性，数学运算的结果或函数调用。

定义和使用一个常量：
```php
<?php
class MyClass
{
    const constant = 'constant value';

    function showConstant() {
        echo  self::constant . "\n";
    }
}

echo MyClass::constant . "\n";

$classname = "MyClass";
echo $classname::constant . "\n"; // 自 5.3.0 起

$class = new MyClass();
$class->showConstant();

echo $class::constant."\n"; // 自 PHP 5.3.0 起
?>
```

#### 类的自动加载

在编写面向对象程序时，很多开发者为每个类新建一个 PHP 文件。 这会带来一个烦恼：每个脚本的开头，都需要 include 一个长长的列表。

在 PHP 5 中，已经不再需要这样了。 `spl_autoload_register()` 函数可以注册任意数量的自动加载器，当使用尚未被定义的类和接口时自动去加载。通过注册自动加载器，脚本引擎在 PHP 出错失败前有了最后一个机会加载所需的类。

尝试分别从 MyClass1.php 和 MyClass2.php 文件中加载 MyClass1 和 MyClass2 类。

MyClass1.php
```php
<?php
class MyClass1 {
    const VAR = 'MyClass1</br>';
};
?>
```

MyClass2.php
```php
<?php
class MyClass2 {
    const VAR = 'MyClass2</br>';
};
?>
```

MyClass3.php
```php
<?php
spl_autoload_register(function ($class_name) {
    require_once $class_name . '.php';
});

$obj  = new MyClass1();
$obj2 = new MyClass2();
echo $obj::VAR;
echo $obj2::VAR;
?>
```

当 new 一个尚未定义的类 MyClass1 时，将自动寻找文件名为类名的 php 文件，也就是 MyClass1.php 文件。

当加载的类文件不存在时，将抛出一个异常，可以用 `try/catch` 进行异常处理

抛出一个异常并在 `try/catch` 语句块中演示：
```php
<?php
spl_autoload_register(function ($name) {
    echo "Want to load $name.\n";
    throw new Exception("Unable to load $name.");
});

try {
    $obj = new NonLoadableClass();
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
?>
```

输出：

    Want to load NonLoadableClass.
    Unable to load NonLoadableClass.


#### 构造函数和析构函数

##### 构造函数

PHP 5 允行开发者在一个类中定义一个方法作为构造函数。具有构造函数的类会在每次创建新对象时先调用此方法，所以非常适合在使用对象之前做一些初始化工作。

如果子类中定义了构造函数则不会隐式调用其父类的构造函数。要执行父类的构造函数，需要在子类的构造函数中调用 `parent::__construct()`。如果子类没有定义构造函数则会如同一个普通的类方法一样从父类继承。


```php
<?php
class BaseClass {
    function __construct() {
        print "In BaseClass constructor</br>";
    }
}

class SubClass extends BaseClass {
    function __construct() {
        parent::__construct();
        print "In SubClass constructor</br>";
    }
}

class OtherSubClass extends BaseClass { }

$obj = new BaseClass();
$obj = new SubClass();
$obj = new OtherSubClass();
?>
```

输出：

    In BaseClass constructor
    In BaseClass constructor
    In SubClass constructor
    In BaseClass constructor

为了实现向后兼容性，如果 PHP 5 在类中找不到 `__construct()` 函数并且也没有从父类继承一个的话，它就会尝试寻找旧式的构造函数，也就是和类同名的函数。因此唯一会产生兼容性问题的情况是：类中已有一个名为 `__construct()` 的方法却被用于其它用途时。

与其它方法不同，当 `__construct()` 被与父类 `__construct()` 具有不同参数的方法覆盖时，PHP 不会产生一个 E_STRICT 错误信息。

自 PHP 5.3.3 起，在命名空间中，与类名同名的方法不再作为构造函数。这一改变不影响不在命名空间中的类。

##### 析构函数

PHP 5 引入了析构函数的概念，这类似于其它面向对象的语言，如 C++。析构函数会在到某个对象的所有引用都被删除或者当对象被显式销毁时执行。

```php
<?php
class MyDestructableClass {
   function __construct() {
       print "In constructor</br>";
       $this->name = "MyDestructableClass";
   }

   function __destruct() {
       print "Destroying " . $this->name . "</br>";
   }
}

$obj = new MyDestructableClass();
?>
```

和构造函数一样，父类的析构函数不会被引擎暗中调用。要执行父类的析构函数，必须在子类的析构函数体中显式调用 `parent::__destruct()`。此外也和构造函数一样，子类如果自己没有定义析构函数则会继承父类的。

析构函数即使在使用 `exit()` 终止脚本运行时也会被调用。在析构函数中调用 `exit()` 将会中止其余关闭操作的运行。


#### 访问控制

对属性或方法的访问控制，是通过在前面添加关键字 `public`（公有），`protected`（受保护）或 `private`（私有）来实现的。被定义为公有的类成员可以在任何地方被访问。被定义为受保护的类成员则可以被其自身以及其子类和父类访问。被定义为私有的类成员则只能被其定义所在的类访问。

##### 属性的访问控制

类属性必须定义为公有，受保护，私有之一。如果没有定义 默认是公有。

```php
<?php
/**
 * Define MyClass
 */
class MyClass {
    public $public = 'Public';
    protected $protected = 'Protected';
    private $private = 'Private';

    function printHello() {
        echo $this->public;
        echo $this->protected;
        echo $this->private;
    }
}

$obj = new MyClass();
echo $obj->public; // 这行能被正常执行
echo $obj->protected; // 这行会产生一个致命错误
echo $obj->private; // 这行也会产生一个致命错误
$obj->printHello(); // 输出 Public、Protected 和 Private


/**
 * Define MyClass2
 */
class MyClass2 extends MyClass {
    // 可以对 public 和 protected 进行重定义，但 private 而不能
    protected $protected = 'Protected2';
    function printHello() {
        echo $this->public;
        echo $this->protected;
        echo $this->private;
    }
}

$obj2 = new MyClass2();
echo $obj2->public; // 这行能被正常执行
echo $obj2->private; // 未定义 private
echo $obj2->protected; // 这行会产生一个致命错误
$obj2->printHello(); // 输出 Public、Protected2 和 Undefined
?>
```

##### 方法的访问控制

类中的方法可以被定义为公有，私有或受保护。如果没有设置这些关键字，则该方法默认为公有。

```php
<?php
/**
 * Define MyClass
 */
class MyClass {
    // 声明一个公有的构造函数
    public function __construct() { }
    // 声明一个公有的方法
    public function MyPublic() { }
    // 声明一个受保护的方法
    protected function MyProtected() { }
    // 声明一个私有的方法
    private function MyPrivate() { }
    // 此方法为公有
    function Foo() {
        $this->MyPublic();
        $this->MyProtected();
        $this->MyPrivate();
    }
}

$myclass = new MyClass;
$myclass->MyPublic(); // 这行能被正常执行
$myclass->MyProtected(); // 这行会产生一个致命错误
$myclass->MyPrivate(); // 这行会产生一个致命错误
$myclass->Foo(); // 公有，受保护，私有都可以执行


/**
 * Define MyClass2
 */
class MyClass2 extends MyClass
{
    // 此方法为公有
    function Foo2() {
        $this->MyPublic();
        $this->MyProtected();
        $this->MyPrivate(); // 这行会产生一个致命错误
    }
}

$myclass2 = new MyClass2;
$myclass2->MyPublic(); // 这行能被正常执行
$myclass2->Foo2(); // 公有的和受保护的都可执行，但私有的不行

class Bar 
{
    public function test() {
        $this->testPrivate();
        $this->testPublic();
    }

    public function testPublic() {
        echo "Bar::testPublic</br>";
    }
    
    private function testPrivate() {
        echo "Bar::testPrivate</br>";
    }
}

class Foo extends Bar 
{
    public function testPublic() {
        echo "Foo::testPublic</br>";
    }
    
    private function testPrivate() {
        echo "Foo::testPrivate</br>";
    }
}

$myFoo = new foo();
$myFoo->test(); // 输出：Bar::testPrivate 
                // 输出：Foo::testPublic
?>
```

#### 对象继承

继承已为大家所熟知的一个程序设计特性，PHP 的对象模型也使用了继承。继承将会影响到类与类，对象与对象之间的关系。比如，当扩展一个类，子类就会继承父类所有公有的和受保护的方法。除非子类覆盖了父类的方法，被继承的方法都会保留其原有功能。 继承对于功能的设计和抽象是非常有用的，而且对于类似的对象增加新功能就无须重新再写这些公用的功能。

一个类可以在声明中用 extends 关键字继承另一个类的方法和属性。PHP不支持多重继承，一个类只能继承一个基类。被继承的方法和属性可以通过用同样的名字重新声明被覆盖。但是如果父类定义方法时使用了 final，则该方法不可被覆盖。可以通过 `parent::` 来访问被覆盖的方法或属性。当覆盖方法时，参数必须保持一致否则 PHP 将发出 E_STRICT 级别的错误信息。但构造函数例外，构造函数可在被覆盖时使用不同的参数。

简单的继承示例：

```php
<?php
class foo {
    public function printItem($string)  {
        echo 'Foo: ' . $string . '</br>';
    }
    
    public function printPHP() {
        echo 'PHP is great.' . '</br>';
    }
}

class bar extends foo {
    public function printItem($string) {
        echo 'Bar: ' . $string . '</br>';
    }
}

$foo = new foo();
$bar = new bar();
$foo->printItem('baz'); // Output: 'Foo: baz'
$foo->printPHP();       // Output: 'PHP is great' 
$bar->printItem('baz'); // Output: 'Bar: baz'
$bar->printPHP();       // Output: 'PHP is great'
?>
```

继承后可以重新定义父类的方法

```php
<?php
class SimpleClass {
    function displayVar() {
        echo 'a default value';
    }
}
class ExtendClass extends SimpleClass {
    // 重新定义父类方法
    function displayVar() {
        echo "Extending class</br>";
        parent::displayVar();
    }
}

$extended = new ExtendClass();
$extended->displayVar();
?>
```

输出：

    Extending class
    a default value

#### 范围解析操作符(::)

范围解析操作符或者更简单地说是一对冒号，可以用于访问静态成员，类常量，还可以用于覆盖类中的属性和方法。

当在类定义之外引用到这些项目时，要使用类名。

在类的外部使用`::`操作符
```php
<?php
class MyClass {
    const CONST_VALUE = 'A constant value</br>';
}

$classname = 'MyClass';
echo $classname::CONST_VALUE; // 自 PHP 5.3.0 起

echo MyClass::CONST_VALUE;
?>
```

输出：

    A constant value
    A constant value

在类的内部使用`::`操作符
```php
<?php
class MyClass {
    const CONST_VALUE = 'A constant value</br>';
}
class OtherClass extends MyClass {
    public static $my_static = 'static var';

    public static function doubleColon() {
        echo parent::CONST_VALUE;
        echo self::$my_static . "</br>";
    }
}

$classname = 'OtherClass';
$classname::doubleColon(); // 自 PHP 5.3.0 起
OtherClass::doubleColon();
?>
```

输出：

    A constant value
    static var
    A constant value
    static var


#### static 关键字

声明类属性或方法为静态，就可以不实例化类而直接访问。静态属性不能通过一个类已实例化的对象来访问（但静态方法可以）。
如果没有指定访问控制，属性和方法默认为公有。
由于静态方法不需要通过对象即可调用，所以伪变量 `$this` 在静态方法中不可用。
静态属性不可以由对象通过 `->` 操作符来访问。
用静态方式调用一个非静态方法会导致一个 `E_STRICT` 级别的错误。
就像其它所有的 PHP 静态变量一样，静态属性只能被初始化为文字或常量，不能使用表达式。所以可以把静态属性初始化为整数或数组，但不能初始化为另一个变量或函数返回值，也不能指向一个对象。
可以用一个变量来动态调用类。但该变量的值不能为关键字 self，parent 或 static。

静态属性示例：

```php
<?php
class Foo {
    public static $my_static = 'foo';
    public function staticValue() {
        return self::$my_static;
    }
}

class Bar extends Foo {
    public function fooStatic() {
        return parent::$my_static;
    }
}

print Foo::$my_static . "</br>";

$foo = new Foo();
print $foo->staticValue() . "</br>";
print $foo->my_static . "</br>";      // Undefined "Property" my_static 

print $foo::$my_static . "</br>";
$classname = 'Foo';
print $classname::$my_static . "</br>"; // As of PHP 5.3.0

print Bar::$my_static . "</br>";
$bar = new Bar();
print $bar->fooStatic() . "</br>";
?>
```

静态方法示例:

```php
<?php
class Foo {
    public static function aStaticMethod() { }
}

Foo::aStaticMethod();
$classname = 'Foo';
$classname::aStaticMethod(); // 自 PHP 5.3.0 起
?>
```

#### 抽象类

PHP 5 支持抽象类和抽象方法。定义为抽象的类不能被实例化。任何一个类，如果它里面至少有一个方法是被声明为抽象的，那么这个类就必须被声明为抽象的。被定义为抽象的方法只是声明了其调用方式（参数），不能定义其具体的功能实现。

继承一个抽象类的时候，子类必须定义父类中的所有抽象方法；另外，这些方法的访问控制必须和父类中一样（或者更为宽松）。例如某个抽象方法被声明为受保护的，那么子类中实现的方法就应该声明为受保护的或者公有的，而不能定义为私有的。此外方法的调用方式必须匹配，即类型和所需参数数量必须一致。例如，子类定义了一个可选参数，而父类抽象方法的声明里没有，则两者的声明并无冲突。 这也适用于 PHP 5.4 起的构造函数。在 PHP 5.4 之前的构造函数声明可以不一样的。

抽象类示例：
```php
<?php
abstract class AbstractClass {
    // 强制要求子类定义这些方法
    abstract protected function getValue();
    abstract protected function prefixValue($prefix);

    // 普通方法（非抽象方法）
    public function printOut() {
        print $this->getValue() . "</br>";
    }
}

class ConcreteClass1 extends AbstractClass {
    protected function getValue() {
        return "ConcreteClass1";
    }

    public function prefixValue($prefix) {
        return "{$prefix}ConcreteClass1";
    }
}

class ConcreteClass2 extends AbstractClass {
    public function getValue() {
        return "ConcreteClass2";
    }

    public function prefixValue($prefix) {
        return "{$prefix}ConcreteClass2";
    }
}

$class1 = new ConcreteClass1;
$class1->printOut();
echo $class1->prefixValue('FOO_') ."</br>";

$class2 = new ConcreteClass2;
$class2->printOut();
echo $class2->prefixValue('FOO_') ."</br>";
?>
```

输出：

    ConcreteClass1
    FOO_ConcreteClass1
    ConcreteClass2
    FOO_ConcreteClass2

子类定义可选参数

```php
<?php
abstract class AbstractClass {
    // 我们的抽象方法仅需要定义需要的参数
    abstract protected function prefixName($name);
}

class ConcreteClass extends AbstractClass {
    // 我们的子类可以定义父类签名中不存在的可选参数
    public function prefixName($name, $separator = ".") {
        if ($name == "Pacman") {
            $prefix = "Mr";
        } elseif ($name == "Pacwoman") {
            $prefix = "Mrs";
        } else {
            $prefix = "";
        }
        return "{$prefix}{$separator} {$name}";
    }
}

$class = new ConcreteClass;
echo $class->prefixName("Pacman"), "</br>";
echo $class->prefixName("Pacwoman"), "</br>";
?>
```

输出：

    Mr. Pacman
    Mrs. Pacwoman


#### 对象接口

使用接口，可以指定某个类必须实现哪些方法，但不需要定义这些方法的具体内容。
接口是通过 `interface` 关键字来定义的，就像定义一个标准的类一样，但其中定义所有的方法都是空的。
接口中定义的所有方法都必须是公有，这是接口的特性。

要实现一个接口，使用 `implements` 操作符。类中必须实现接口中定义的所有方法，否则会报一个致命错误。类可以实现多个接口，用逗号来分隔多个接口的名称。

实现多个接口时，接口中的方法不能有重名。
接口也可以继承其他接口，通过使用 extends 操作符，接口允许多继承。
类要实现接口，必须使用和接口中所定义的方法完全一致的方式。否则会导致致命错误。


##### 实现接口

接口示例：

```php
<?php
// 声明一个'iTemplate'接口
interface iTemplate {
    public function setVariable($name, $var);
    public function getHtml($template);
}
// 实现接口
// 下面的写法是正确的
class Template implements iTemplate
{
    private $vars = array();
    public function setVariable($name, $var) {
        $this->vars[$name] = $var;
    }
  
    public function getHtml($template) {
        foreach($this->vars as $name => $value) {
            $template = str_replace('{' . $name . '}', $value, $template);
        }
        return $template;
    }
}

// 下面的写法是错误的，会报错，因为没有实现 getHtml()：
// Fatal error: Class BadTemplate contains 1 abstract methods
// and must therefore be declared abstract (iTemplate::getHtml)
class BadTemplate implements iTemplate {
    private $vars = array();
    public function setVariable($name, $var) {
        $this->vars[$name] = $var;
    }
}
?>
```

##### 继承多个接口

```php
<?php
interface a {
    public function foo();
}
interface b {
    public function bar();
}
interface c extends a, b {
    public function baz();
}
class d implements c {
    public function foo() {}
    public function bar() {}
    public function baz() {}
}
?>
```

##### 使用接口常量

```php
<?php
interface a {
    const b = 'Interface constant';
}

// 输出接口常量
echo a::b;

// 错误写法，因为常量不能被覆盖。接口常量的概念和类常量是一样的。
class b implements a {
    const b = 'Class constant';
}
?>
```


#### Trait

自 PHP 5.4.0 起，PHP 实现了一种代码复用的方法，称为 trait。可以将多个类中，共用的一些属性和方法提取出来做来公共trait类，就像是装配汽车的配件，如果你的类中要用到这些配件，就直接用 use 导入就可以了，相当于把 trait 中的代码复制到当前类中。因为 trait 不是类，所以不能有静态成员，类常量，当然也不可能被实例化。

##### trait 使用

示例：
```php
<?php
trait sayHello {
    public function say(){
        echo 'Hello';
    }
}

class Base {
    use sayHello;
}

$b = new Base();
$b->say();
?>
```

输出：

    Hello

##### 优先级

从基类继承的成员会被 trait 插入的成员所覆盖。优先顺序是：当前类成员 > trait的方法 > 当前类继承的方法

```php
<?php
class Base {
    public function sayHello() {
        echo 'Hello ';
    }
}

trait SayWorld {
    public function sayHello() {
        parent::sayHello();
        echo 'World!';
    }
}

class MyHelloWorld extends Base {
    use SayWorld;
}

$o = new MyHelloWorld();
$o->sayHello();
?>
```

输出：

    Hello World!

##### 多个 trait

通过逗号分隔，在 use 声明列出多个 trait，可以都插入到一个类中。

```php
<?php
trait Hello {
    public function sayHello() {
        echo 'Hello ';
    }
}

trait World {
    public function sayWorld() {
        echo 'World';
    }
}

class MyHelloWorld {
    use Hello, World;
    public function sayExclamationMark() {
        echo '!';
    }
}

$o = new MyHelloWorld();
$o->sayHello();
$o->sayWorld();
$o->sayExclamationMark();
?>
```

输出：

    Hello World!

##### 同名冲突

如果两个 trait 都插入了一个同名的方法，如果没有明确解决冲突将会产生一个致命错误。
为了解决多个 trait 在同一个类中的命名冲突，需要使用 `insteadof` 操作符来明确指定使用冲突方法中的哪一个。
以上方式仅允许排除掉其它方法，`as` 操作符可以 为某个方法引入别名。 注意：`as` 操作符不会对方法进行重命名，也不会影响其方法。

```php
<?php
trait A {
    public function smallTalk() {
        echo 'a';
    }
    public function bigTalk() {
        echo 'A';
    }
}

trait B {
    public function smallTalk() {
        echo 'b';
    }
    public function bigTalk() {
        echo 'B';
    }
}

class Talker {
    use A, B {
        B::smallTalk insteadof A;
        A::bigTalk insteadof B;
    }
}

class Aliased_Talker {
    use A, B {
        B::smallTalk insteadof A;
        A::bigTalk insteadof B;
        B::bigTalk as talk;
    }
}

$a = new Aliased_Talker();
$a->smallTalk();    // 输出 b
$a->bigTalk();      // 输出 A
$a->talk();         // 输出 B
?>
```

##### 修改方法的访问控制

使用 as 语法还可以用来调整方法的访问控制。

```php
<?php
trait HelloWorld {
    public function sayHello() {
        echo 'Hello World!';
    }
}

// 修改 sayHello 的访问控制
class MyClass1 {
    use HelloWorld { sayHello as protected; }
}

// 给方法一个改变了访问控制的别名
// 原版 sayHello 的访问控制则没有发生变化
class MyClass2 {
    use HelloWorld { sayHello as private myPrivateHello; }
}
?>
```

##### 从 trait 来组成 trait

正如 class 能够使用 trait 一样，其它 trait 也能够使用 trait。在 trait 定义时通过使用一个或多个 trait，能够组合其它 trait 中的部分或全部成员。

```php
<?php
trait Hello {
    public function sayHello() {
        echo 'Hello ';
    }
}

trait World {
    public function sayWorld() {
        echo 'World!';
    }
}

trait HelloWorld {
    use Hello, World;
}

class MyHelloWorld {
    use HelloWorld;
}

$o = new MyHelloWorld();
$o->sayHello();
$o->sayWorld();
?>
```

输出：

    Hello World!

##### trait 的抽象成员

为了对使用的类施加强制要求，trait 支持抽象方法的使用。

```php
<?php
trait Hello {
    public function sayHelloWorld() {
        echo 'Hello '.$this->getWorld();
    }
    abstract public function getWorld();
}

class MyHelloWorld {
    private $world;
    use Hello;
    public function getWorld() {
        return $this->world;
    }
    public function setWorld($val) {
        $this->world = $val;
    }
}

$a = new MyHelloWorld();
$a->setWorld("World!");
$a->sayHelloWorld();
?>
```

输出：

    Hello World!

##### trait 的静态成员

Traits 可以定义静态变量和静态方法

```php
<?php
trait StaticExample {
    public function inc() {
        static $c = 0;
        $c = $c + 1;
        echo "$c\n";
    }
    public static function doSomething() {
        return 'Doing something';
    }
}

class Example {
    use StaticExample;
}
$a = new Example();
$a->inc();
echo '</br>';
echo Example::doSomething();
?>
```

输出：

    1 
    Doing something

##### 定义属性

Trait 同样可以定义属性。

```php
<?php
trait PropertiesTrait {
    public $x = 1;
}

class PropertiesExample {
    use PropertiesTrait;
}

$example = new PropertiesExample;
echo $example->x;       // 输出 1
?>
```

Trait 定义了一个属性后，类就不能定义同样名称的属性，否则会产生 fatal error。 有种情况例外：属性是兼容的（同样的访问可见度、初始默认值）。 在 PHP 7.0 之前，属性是兼容的，则会有 E_STRICT 的提醒。

```php
<?php
trait PropertiesTrait {
    public $same = true;
    public $different = false;
}

class PropertiesExample {
    use PropertiesTrait;
    public $same = true; // PHP 7.0.0 后没问题，之前版本是 E_STRICT 提醒
    public $different = true; // 致命错误
}
?>
```

#### 匿名类

PHP 7 开始支持匿名类。 匿名类很有用，可以创建一次性的简单对象。

```php
<?php
// PHP 7 之前的代码
class Logger {
    public function log($msg) {
        echo $msg;
    }
}

$util->setLogger(new Logger());

// 使用了 PHP 7+ 后的代码
$util->setLogger(new class {
    public function log($msg) {
        echo $msg;
    }
});
```

可以传递参数到匿名类的构造器，也可以 extend 其他类、实现接口，以及像其他普通的类一样使用 trait。

```php
<?php
class SomeClass {}
interface SomeInterface {}
trait SomeTrait {}

var_dump(new class(10) extends SomeClass implements SomeInterface {
    private $num;
    public function __construct($num)
    {
        $this->num = $num;
    }
    use SomeTrait;
});
```

匿名类被嵌套进普通 Class 后，不能访问这个外部类的 private、protected方法或者属性。为了访问外部类 protected 属性或方法，匿名类可以 extend 此外部类。 为了使用外部类的 private 属性，必须通过构造器传进来。

```php
<?php
class Outer
{
    private $prop = 1;
    protected $prop2 = 2;
    protected function func1() {
        return 3;
    }
    public function func2() {
        return new class($this->prop) extends Outer {
            private $prop3;
            public function __construct($prop) {
                $this->prop3 = $prop;
            }
            public function func3() {
                return $this->prop2 + $this->prop3 + $this->func1();
            }
        };
    }
}
echo (new Outer)->func2()->func3();     // 输出 6
?>
```

#### 重载

PHP中的"重载"与其它绝大多数面向对象语言不同。传统的"重载"是用于提供多个同名的类方法，但各方法的参数类型和个数不同。
PHP所提供的"重载"是指动态地"创建"类属性和方法。我们是通过魔术方法（magic methods）来实现的。当调用当前环境下未定义或不可见的类属性或方法时，重载方法会被调用。
所有的重载方法都必须被声明为 public。

##### 属性重载

`public void __set ( string $name , mixed $value )`
`public mixed __get ( string $name )`
`public bool __isset ( string $name )`
`public void __unset ( string $name )`

注：mixed 说明一个参数可以接受多种不同的类型。

在给不可访问属性赋值时，`__set()` 会被调用。
读取不可访问属性的值时，`__get()` 会被调用。
当对不可访问属性调用 isset() 或 `empty()` 时，`__isset()` 会被调用。
当对不可访问属性调用 unset() 时，`__unset()` 会被调用。
参数 `$name` 是指要操作的变量名称。`__set()` 方法的 `$value` 参数指定了 `$name` 变量的值。
属性重载只能在对象中进行。在静态方法中，这些魔术方法将不会被调用。所以这些方法都不能被 声明为 static。从 PHP 5.3.0 起, 将这些魔术方法定义为 static 会产生一个警告。

示例：

```php
<?php
class PropertyTest {
     /**  被重载的数据保存在此  */
    private $data = array();
     /**  重载不能被用在已经定义的属性  */
    public $declared = 1;
     /**  只有从类外部访问这个属性时，重载才会发生 */
    private $hidden = 2;
    public function __set($name, $value)  {
        echo "Setting '$name' to '$value'\n";
        $this->data[$name] = $value;
    }

    public function __get($name) {
        echo "Getting '$name'\n";
        if (array_key_exists($name, $this->data)) {
            return $this->data[$name];
        } else {
            return 'Not exists';
        }
    }
    public function __isset($name) {
        echo "Is '$name' set?\n";
        return isset($this->data[$name]);
    }
    public function __unset($name) {
        echo "Unsetting '$name'\n";
        unset($this->data[$name]);
    }
    /**  非魔术方法  */
    public function getHidden() {
        return $this->hidden;
    }
}

echo "<pre>\n";
$obj = new PropertyTest;
$obj->a = 1;
echo $obj->a . "\n\n";

var_dump(isset($obj->a));
unset($obj->a);
var_dump(isset($obj->a));
echo "\n";

echo $obj->declared . "\n\n";

echo "Let's experiment with the private property named 'hidden':\n";
echo "Privates are visible inside the class, so __get() not used...\n";
echo $obj->getHidden() . "\n";
echo "Privates not visible outside of class, so __get() is used...\n";
echo $obj->hidden . "\n";
?>
```

输出：

    Setting 'a' to '1'
    Getting 'a'
    1

    Is 'a' set?
    bool(true)
    Unsetting 'a'
    Is 'a' set?
    bool(false)

    1

    Let's experiment with the private property named 'hidden':
    Privates are visible inside the class, so __get() not used...
    2
    Privates not visible outside of class, so __get() is used...
    Getting 'hidden'
    Not exists


##### 方法重载

`public mixed __call ( string $name , array $arguments )`
`public static mixed __callStatic ( string $name , array $arguments )`

在对象中调用一个不可访问方法时，`__call()` 会被调用。
在静态上下文中调用一个不可访问方法时，`__callStatic()` 会被调用。
$name 参数是要调用的方法名称。$arguments 参数是一个枚举数组，包含着要传递给方法 $name 的参数。

```php
<?php
class MethodTest {
    public function __call($name, $arguments) {
        // 注意: $name 的值区分大小写
        echo "Calling object method '$name' "
             . implode(', ', $arguments). "\n";
    }
    /**  PHP 5.3.0之后版本  */
    public static function __callStatic($name, $arguments) {
        // 注意: $name 的值区分大小写
        echo "Calling static method '$name' "
             . implode(', ', $arguments). "\n";
    }
}

echo '<pre>';
$obj = new MethodTest;
$obj->runTest('in object context');

MethodTest::runTest('in static context');  // PHP 5.3.0之后版本
?>
```

输出：

    Calling object method 'runTest' in object context
    Calling static method 'runTest' in static context


#### 遍历对象

PHP 5 提供了一种定义对象的方法使其可以通过单元列表来遍历，例如用 foreach 语句。默认情况下，所有可见属性都将被用于遍历。

##### 简单遍历

```php
<?php
class MyClass {
    public $var1 = 'value 1';
    public $var2 = 'value 2';
    public $var3 = 'value 3';

    protected $protected = 'protected var';
    private   $private   = 'private var';

    function iterateVisible() {
       echo "MyClass::iterateVisible:\n";
       foreach($this as $key => $value) {
           print "$key => $value\n";
       }
    }
}

$class = new MyClass();
echo '<pre>';
foreach($class as $key => $value) {
    print "$key => $value\n";
}
$class->iterateVisible();
?>
```

输出：

    var1 => value 1
    var2 => value 2
    var3 => value 3
    MyClass::iterateVisible:
    var1 => value 1
    var2 => value 2
    var3 => value 3
    protected => protected var
    private => private var

##### 实现 iterator 接口

更进一步，可以实现 Iterator 接口。可以让对象自行决定如何遍历以及每次遍历时那些值可用。

```php
<?php
class MyIterator implements Iterator {
    private $var = array();

    public function __construct($array) {
        if (is_array($array)) {
            $this->var = $array;
        }
    }

    public function rewind() {
        echo "rewinding\n";
        reset($this->var);
    }

    public function current() {
        $var = current($this->var);
        echo "current: $var\n";
        return $var;
    }

    public function key() {
        $var = key($this->var);
        echo "key: $var\n";
        return $var;
    }

    public function next() {
        $var = next($this->var);
        echo "next: $var\n";
        return $var;
    }

    public function valid() {
        $var = $this->current() !== false;
        echo "valid: {$var}\n";
        return $var;
    }
}

$values = array(1,2,3);
$it = new MyIterator($values);
echo '<pre>';
foreach ($it as $a => $b) {
    print "$a: $b\n";
}
?>
```

输出：

    rewinding
    current: 1
    valid: 1
    current: 1
    key: 0
    0: 1
    next: 2
    current: 2
    valid: 1
    current: 2
    key: 1
    1: 2
    next: 3
    current: 3
    valid: 1
    current: 3
    key: 2
    2: 3
    next: 
    current: 
    valid: 


##### 通过实现 IteratorAggregate

可以用 `IteratorAggregate` 接口以替代实现所有的 Iterator 方法。`IteratorAggregate` 只需要实现一个方法 `IteratorAggregate::getIterator()`，其应返回一个实现了 Iterator 的类的实例。

```php
<?php
<?php
class MyIterator implements Iterator {
    private $var = array();

    public function __construct($array) {
        if (is_array($array)) {
            $this->var = $array;
        }
    }

    public function rewind() {
        echo "rewinding\n";
        reset($this->var);
    }

    public function current() {
        $var = current($this->var);
        echo "current: $var\n";
        return $var;
    }

    public function key() {
        $var = key($this->var);
        echo "key: $var\n";
        return $var;
    }

    public function next() {
        $var = next($this->var);
        echo "next: $var\n";
        return $var;
    }

    public function valid() {
        $var = $this->current() !== false;
        echo "valid: {$var}\n";
        return $var;
    }
}

class MyCollection implements IteratorAggregate {
    private $items = array();
    private $count = 0;
    // Required definition of interface IteratorAggregate
    public function getIterator() {
        return new MyIterator($this->items);
    }
    public function add($value) {
        $this->items[$this->count++] = $value;
    }
}

$coll = new MyCollection();
$coll->add('value 1');
$coll->add('value 2');
$coll->add('value 3');

foreach ($coll as $key => $val) {
    echo "key/value: [$key -> $val]\n\n";
}
?>
```

#### 魔术方法

`__construct()`， `__destruct()`， `__call()`， `__callStatic()`， `__get()`， `__set()`， `__isset()`， `__unset()`， `__sleep()`， `__wakeup()`， `__toString()`， `__invoke()`， `__set_state()`，` __clone()` 和 `__debugInfo()` 等方法在 PHP 中被称为"魔术方法"（Magic methods）。在命名自己的类方法时不能使用这些方法名，除非是想使用其魔术功能。

PHP 将所有以 `__`（两个下划线）开头的类方法保留为魔术方法。所以在定义类方法时，除了上述魔术方法，建议不要以 `__` 为前缀。

|魔法方法|说明|
|-|-|
|\_\_sleep|序列化对象前被调用，可用于清理对象|
|\_\_wakeup|反序列化前被调用|
|\_\_toString|可以将对象当成字符串 比如echo一个对象时调用|
|\_\_invoke|可以让对象当函数进行调用|
|\_\_set\_state|调用 var_export() 导出类时此方法被调用|
|\_\_debugInfo|调用 var_dump() 打印对象时被调用 PHP 5.6可用|

简单例子：

```php
<?php
class foo {
    public function __toString() {
        return "This is " . self::class . "</br>";
    }
    public function __debugInfo() {
        return ["message"=>"called __debugInfo()"];
    }
    public function __invoke() {
        return "called __invoke()</br>";
    }
}

$f = new foo;
echo $f;
echo $f();
var_dump($f);
?>
```

#### final 关键字

PHP 5 新增了一个 final 关键字。如果父类中的方法被声明为 final，则子类无法覆盖该方法。如果一个类被声明为 final，则不能被继承。

final 方法：

```php
<?php
class BaseClass {
   public function test() {
       echo "BaseClass::test() called\n";
   }
   
   final public function moreTesting() {
       echo "BaseClass::moreTesting() called\n";
   }
}

class ChildClass extends BaseClass {
   public function moreTesting() {
       echo "ChildClass::moreTesting() called\n";
   }
}
// Results in Fatal error: Cannot override final method BaseClass::moreTesting()
?>
```


final 类：
```php
<?php
final class BaseClass {
   public function test() {
       echo "BaseClass::test() called\n";
   }
   
   // 这里无论你是否将方法声明为final，都没有关系
   final public function moreTesting() {
       echo "BaseClass::moreTesting() called\n";
   }
}

class ChildClass extends BaseClass {
}
// 产生 Fatal error: Class ChildClass may not inherit from final class (BaseClass)
?>
```

#### 对象复制

在多数情况下，我们并不需要完全复制一个对象来获得其中属性。但有一个情况下确实需要：如果你有一个 GTK 窗口对象，该对象持有窗口相关的资源。你可能会想复制一个新的窗口，保持所有属性与原来的窗口相同，但必须是一个新的对象（因为如果不是新的对象，那么一个窗口中的改变就会影响到另一个窗口）。还有一种情况：如果对象 A 中保存着对象 B 的引用，当你复制对象 A 时，你想其中使用的对象不再是对象 B 而是 B 的一个副本，那么你必须得到对象 A 的一个副本。

对象复制可以通过 clone 关键字来完成（如果可能，这将调用对象的 `__clone()` 方法）。对象中的 `__clone()` 方法不能被直接调用。

当对象被复制后，PHP 5 会对对象的所有属性执行一个浅复制（shallow copy）。所有的引用属性 仍然会是一个指向原来的变量的引用。

示例：
```php
<?php
class MyCloneable {
    public $val = "val";
    public function __clone() {
        echo "called __clone()</br>";
    }
}

$obj = new MyCloneable();
$obj2 = clone $obj;
echo "obj => ".$obj->val.'</br>';
echo "obj2 => ".$obj2->val.'</br>';
$obj2->val = "val2";
echo "obj => ".$obj->val.'</br>';
echo "obj2 => ".$obj2->val.'</br>';
?>
```

#### 对象比较

当使用比较运算符（==）比较两个对象变量时，比较的原则是：如果两个对象的属性和属性值都相等，而且两个对象是同一个类的实例，那么这两个对象变量相等。

而如果使用全等运算符（===），这两个对象变量一定要指向某个类的同一个实例（即同一个对象）。

```php
<?php
class BaseClass {}
$b1 = new BaseClass;
$b2 = new BaseClass;
$b3 = $b2;
echo '<pre>';
var_dump($b1 == $b2);       // true
var_dump($b1 === $b2);      // false
var_dump($b2 === $b3);      // true
var_dump($b2 == $b3);       // false
?>
```


#### 类型约束

PHP 5 可以使用类型约束。函数的参数可以指定必须为对象（在函数原型里面指定类的名字），接口，数组（PHP 5.1 起）或者 callable（PHP 5.4 起）。不过如果使用 NULL 作为参数的默认值，那么在调用函数的时候依然可以使用 NULL 作为实参。

如果一个类或接口指定了类型约束，则其所有的子类或实现也都如此。

类型约束不能用于标量类型如 int 或 string。Traits 也不允许。

示例：
```php
<?php
class MyClass
{
    // 测试函数 第一个参数必须为 OtherClass 类的一个对象
    public function test(OtherClass $otherclass) {
        echo $otherclass->var;
    }
    // 另一个测试函数 第一个参数必须为数组 
    public function test_array(array $input_array) {
        print_r($input_array);
    }
}
    // 第一个参数必须为递归类型
    public function test_interface(Traversable $iterator) {
        echo get_class($iterator);
    }
    // 第一个参数必须为回调类型
    public function test_callable(callable $callback, $data) {
        call_user_func($callback, $data);
    }
}
// OtherClass 类定义
class OtherClass {
    public $var = 'Hello World';
}

$myclass = new MyClass;
$otherclass = new OtherClass;

// 致命错误：第一个参数必须是 OtherClass 类的一个对象
$myclass->test('hello');

// 致命错误：第一个参数必须为 OtherClass 类的一个实例
$foo = new stdClass;
$myclass->test($foo);

// 致命错误：第一个参数不能为 null
$myclass->test(null);

// 正确：输出 Hello World 
$myclass->test($otherclass);

// 致命错误：第一个参数必须为数组
$myclass->test_array('a string');

// 正确：输出数组
$myclass->test_array(array('a', 'b', 'c'));

// 正确：输出 ArrayObject
$myclass->test_interface(new ArrayObject(array()));

// 正确：输出 int(1)
$myclass->test_callable('var_dump', 1);
?>
```

类型约束不只是用在类的成员函数里，也能使用在函数里：

```php
<?php
// 如下面的类
class MyClass {
    public $var = 'Hello World';
}

// 测试函数 第一个参数必须是 MyClass 类的一个对象
function MyFunction (MyClass $foo) {
    echo $foo->var;
}

// 正确
$myclass = new MyClass;
MyFunction($myclass);
?>
```

类型约束允许 NULL 值：

```php
<?php
/* 接受 NULL 值 */
function test(stdClass $obj = NULL) { }
test(NULL);
test(new stdClass);
?>
```

#### 后期静态绑定

自 PHP 5.3.0 起，PHP 增加了一个叫做后期静态绑定的功能，用于在继承范围内引用静态调用的类。

准确说，后期静态绑定工作原理是存储了在上一个"非转发调用"（non-forwarding call）的类名。当进行静态方法调用时，该类名即为明确指定的那个（通常在 :: 运算符左侧部分）；当进行非静态方法调用时，即为该对象所属的类。所谓的"转发调用"（forwarding call）指的是通过以下几种方式进行的静态调用：`self::`，`parent::`，`static::` 以及 `forward_static_call()`。可用 `get_called_class()` 函数来得到被调用的方法所在的类名，`static::` 则指出了其范围。

该功能从语言内部角度考虑被命名为"后期静态绑定"。"后期绑定"的意思是说，static:: 不再被解析为定义当前方法所在的类，而是在实际运行时计算的。也可以称之为"静态绑定"，因为它可以用于（但不限于）静态方法的调用。

##### self:: 的限制

```php
<?php
class A {
    public static function who() {
        echo __CLASS__;
    }
    public static function test() {
        self::who();
    }
}

class B extends A {
    public static function who() {
        echo __CLASS__;
    }
}

B::test();
?>
```

输出：

    A

##### 后期静态绑定的用法

```php
<?php
class A {
    public static function who() {
        echo __CLASS__;
    }
    public static function test() {
        static::who(); // 后期静态绑定从这里开始
    }
}

class B extends A {
    public static function who() {
        echo __CLASS__;
    }
}

B::test();
?>
```

输出：

    B

在非静态环境下，所调用的类即为该对象实例所属的类。由于 $this-> 会在同一作用范围内尝试调用私有方法，而 static:: 则可能给出不同结果。另一个区别是 static:: 只能用于静态属性。


#### 对象和引用

在php5 的对象编程经常提到的一个关键点是“默认情况下对象是通过引用传递的”。但其实这不是完全正确的。下面通过一些例子来说明。

PHP 的引用是别名，就是两个不同的变量名字指向相同的内容。在 PHP 5，一个对象变量已经不再保存整个对象的值。只是保存一个标识符来访问真正的对象内容。 当对象作为参数传递，作为结果返回，或者赋值给另外一个变量，另外一个变量跟原来的不是引用的关系，只是他们都保存着同一个标识符的拷贝，这个标识符指向同一个对象的真正内容。

```php
<?php
class A {
    public $foo = 1;
}  
$a = new A;
$b = $a;     // $a ,$b都是同一个标识符的拷贝
             // ($a) = ($b) = <id>
$b->foo = 2;
echo $a->foo."</br>";

$c = new A;
$d = &$c;    // $c ,$d是引用
             // ($c,$d) = <id>
$d->foo = 2;
echo $c->foo."</br>";

$e = new A;
function foo($obj) {
    // ($obj) = ($e) = <id>
    $obj->foo = 2;
}

foo($e);
echo $e->foo."</br>";
?>
```

输出：

    2
    2
    2


#### 对象序列化

所有php里面的值都可以使用函数serialize()来返回一个包含字节流的字符串来表示。unserialize()函数能够重新把字符串变回php原来的值。 序列化一个对象将会保存对象的所有变量，但是不会保存对象的方法，只会保存类的名字。

为了能够unserialize()一个对象，这个对象的类必须已经定义过。如果序列化类A的一个对象，将会返回一个跟类A相关，而且包含了对象所有变量值的字符串。 如果要想在另外一个文件中解序列化一个对象，这个对象的类必须在解序列化之前定义，可以通过包含一个定义该类的文件或使用函数`spl_autoload_register()`来实现。

classa.inc
```php
<?php
class A {
    public $one = 1;
    public function show_one() {
        echo $this->one;
    }
}
?>
```

page1.php
```php
<?php
include("classa.inc");
$a = new A;
$s = serialize($a);
// 把变量$s保存起来以便文件page2.php能够读到
file_put_contents('store', $s);
?>
```

page2.php
```php
<?php
// 要正确了解序列化，必须包含下面一个文件
include("classa.inc");
$s = file_get_contents('store');
$a = unserialize($s);
// 现在可以使用对象$a里面的函数 show_one()
$a->show_one();
?>
```

先执行 page1.php 再执行 page2.php 就可以看到结果了。

### 命名空间

#### 命名空间概述

什么是命名空间？从广义上来说，命名空间是一种封装事物的方法。在很多地方都可以见到这种抽象概念。例如，在操作系统中目录用来将相关文件分组，对于目录中的文件来说，它就扮演了命名空间的角色。具体举个例子，文件 foo.txt 可以同时在目录/home/greg 和 /home/other 中存在，但在同一个目录中不能存在两个 foo.txt 文件。另外，在目录 /home/greg 外访问 foo.txt 文件时，我们必须将目录名以及目录分隔符放在文件名之前得到 /home/greg/foo.txt。这个原理应用到程序设计领域就是命名空间的概念。

在PHP中，命名空间用来解决在编写类库或应用程序时创建可重用的代码如类或函数时碰到的两类问题：

1. 用户编写的代码与PHP内部的类/函数/常量或第三方类/函数/常量之间的名字冲突。
2. 为很长的标识符名称(通常是为了缓解第一类问题而定义的)创建一个别名（或简短）的名称，提高源代码的可读性。

PHP 命名空间提供了一种将相关的类、函数和常量组合到一起的途径。

#### 定义命名空间

虽然任意合法的PHP代码都可以包含在命名空间中，但只有以下类型的代码受命名空间的影响，它们是：类（包括抽象类和traits）、接口、函数和常量。

命名空间通过关键字namespace 来声明。如果一个文件中包含命名空间，它必须在其它所有代码之前声明命名空间，除了一个以外：declare关键字。

```php
<?php
namespace MyProject;
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }
?>
```

在声明命名空间之前唯一合法的代码是用于定义源文件编码方式的 declare 语句。另外，所有非 PHP 代码包括空白符都不能出现在命名空间的声明之前：

```php
<html>
<?php
namespace MyProject; // 致命错误 -　命名空间必须是程序脚本的第一条语句
?>
```

另外，与PHP其它的语言特征不同，同一个命名空间可以定义在多个文件中，即允许将同一个命名空间的内容分割存放在不同的文件中。

#### 定义子命名空间

与目录和文件的关系很象，PHP 命名空间也允许指定层次化的命名空间的名称。因此，命名空间的名字可以使用分层次的方式定义：

```php
<?php
namespace MyProject\Sub\Level;
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }
?>
```

上面的例子创建了常量 `MyProject\Sub\Level\CONNECT_OK`，类 `MyProject\Sub\Level\Connection` 和函数 `MyProject\Sub\Level\connect`。


#### 同一个文件多个命名空间

也可以在同一个文件中定义多个命名空间。在同一个文件中定义多个命名空间有两种语法形式。

简单组合语法：
```php
<?php
namespace MyProject;
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }

namespace AnotherProject;
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }
?>
```

不建议使用这种语法在单个文件中定义多个命名空间。建议使用下面的大括号形式的语法。

大括号语法：
```php
<?php
namespace MyProject {
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }
}

namespace AnotherProject {
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }
}
?>
```

在实际的编程实践中，非常不提倡在同一个文件中定义多个命名空间。这种方式的主要用于将多个 PHP 脚本合并在同一个文件中。

将全局的非命名空间中的代码与命名空间中的代码组合在一起，只能使用大括号形式的语法。全局代码必须用一个不带名称的 namespace 语句加上大括号括起来，例如：

```php
<?php
namespace MyProject {
const CONNECT_OK = 1;
class Connection { /* ... */ }
function connect() { /* ... */  }
}

namespace { // global code
session_start();
$a = MyProject\connect();
echo MyProject\Connection::start();
}
?>
```

除了开始的declare语句外，命名空间的括号外不得有任何PHP代码。

#### 使用命名空间：基础

在讨论如何使用命名空间之前，必须了解 PHP 是如何知道要使用哪一个命名空间中的元素的。可以将 PHP 命名空间与文件系统作一个简单的类比。在文件系统中访问一个文件有三种方式：

1. 相对文件名形式如foo.txt。它会被解析为 `currentdirectory/foo.txt`，其中 `currentdirectory` 表示当前目录。因此如果当前目录是 `/home/foo`，则该文件名被解析为 `/home/foo/foo.txt`。
2. 相对路径名形式如 `subdirectory/foo.txt`。它会被解析为 `currentdirectory/subdirectory/foo.txt`。
3. 绝对路径名形式如 `/main/foo.txt`。它会被解析为 `/main/foo.txt`。

PHP 命名空间中的元素使用同样的原理。例如，类名可以通过三种方式引用：
1. 非限定名称，或不包含前缀的类名称，例如 `$a=new foo()`; 或 `foo::staticmethod();`。如果当前命名空间是 `currentnamespace`，foo 将被解析为 `currentnamespace\foo`。如果使用 foo 的代码是全局的，不包含在任何命名空间中的代码，则 foo 会被解析为 foo。 警告：如果命名空间中的函数或常量未定义，则该非限定的函数名称或常量名称会被解析为全局函数名称或常量名称。
2. 限定名称，或包含前缀的名称，例如 `$a = new subnamespace\foo()`; 或 `subnamespace\foo::staticmethod()`;。如果当前的命名空间是 `currentnamespace`，则 foo 会被解析为 `currentnamespace\subnamespace\foo`。如果使用 foo 的代码是全局的，不包含在任何命名空间中的代码，foo 会被解析为 `subnamespace\foo`。
3. 完全限定名称，或包含了全局前缀操作符的名称，例如，`$a = new \currentnamespace\foo();` 或 `\currentnamespace\foo::staticmethod();`。在这种情况下，foo 总是被解析为代码中的文字名 `currentnamespace\foo`。

示例：

file1.php
```php
<?php
namespace Foo\Bar\subnamespace;
const FOO = 1;
function foo() {}
class foo {
    static function staticmethod() {}
}
?>
```

file2.php
```php
<?php
namespace Foo\Bar;
include 'file1.php';

const FOO = 2;
function foo() {}
class foo {
    static function staticmethod() {}
}

/* 非限定名称 */
foo(); // 解析为方法 Foo\Bar\foo 
foo::staticmethod(); // 解析为类 Foo\Bar\foo 的静态方法 staticmethod。
echo FOO; // 解析为常量 Foo\Bar\FOO

/* 限定名称 */
subnamespace\foo(); // 解析为函数 Foo\Bar\subnamespace\foo
subnamespace\foo::staticmethod(); // 解析为类 Foo\Bar\subnamespace\foo 的静态方法 staticmethod
echo subnamespace\FOO; // 解析为常量 Foo\Bar\subnamespace\FOO
                                  
/* 完全限定名称 */
\Foo\Bar\foo(); // 解析为函数 Foo\Bar\foo
\Foo\Bar\foo::staticmethod(); // 解析为类 Foo\Bar\foo, 以及类的方法 staticmethod
echo \Foo\Bar\FOO; // 解析为常量 Foo\Bar\FOO
?>
```

注意：访问任意全局类、函数或常量，都可以使用完全限定名称，例如 `\strlen()` 或 `\Exception` 或 `\INI_ALL`。



#### 命名空间和动态语言特征

PHP 命名空间的实现受到其语言自身的动态特征的影响。因此，如果要将下面的代码转换到命名空间中：

example1.php
```php
<?php
class classname {
    function __construct() {
        echo __METHOD__,"\n";
    }
}
function funcname() {
    echo __FUNCTION__,"\n";
}
const constname = "global";

$a = 'classname';
$obj = new $a; // prints classname::__construct
$b = 'funcname';
$b(); // prints funcname
echo constant('constname'), "\n"; // prints global
?>
```

必须使用完全限定名称（包括命名空间前缀的类名称）。注意因为在动态的类名称、函数名称或常量名称中，限定名称和完全限定名称没有区别，因此其前导的反斜杠是不必要的。

example2.php
```php
<?php
namespace namespacename;
class classname {
    function __construct() {
        echo __METHOD__,"\n";
    }
}
function funcname() {
    echo __FUNCTION__,"\n";
}
const constname = "namespaced";

include 'example1.php';

$a = 'classname';
$obj = new $a; // prints classname::__construct
$b = 'funcname';
$b(); // prints funcname
echo constant('constname'), "\n"; // prints global

/* note that if using double quotes, "\\namespacename\\classname" must be used */
$a = '\namespacename\classname';
$obj = new $a; // prints namespacename\classname::__construct
$a = 'namespacename\classname';
$obj = new $a; // also prints namespacename\classname::__construct
$b = 'namespacename\funcname';
$b(); // prints namespacename\funcname
$b = '\namespacename\funcname';
$b(); // also prints namespacename\funcname
echo constant('\namespacename\constname'), "\n"; // prints namespaced
echo constant('namespacename\constname'), "\n"; // also prints namespaced
?>
```

#### \_\_NAMESPACE\_\_常量

PHP支持两种抽象的访问当前命名空间内部元素的方法，`__NAMESPACE__` 魔术常量和 `namespace` 关键字。

`__NAMESPACE__` 示例：

```php
<?php
namespace MyProject;
echo __NAMESPACE__;     // 输出 MyProject
?>
```

全局代码：
```php
echo __NAMESPACE__;     // 输出空白 __NAMESPACE__为空字符串。
```

常量 `__NAMESPACE__` 在动态创建名称时很有用，例如：

```php
<?php
namespace MyProject;

function get($classname)
{
    $a = __NAMESPACE__ . '\\' . $classname;
    return new $a;
}
?>
```

#### namespace关键字

关键字 namespace 可用来显式访问当前命名空间或子命名空间中的元素。它等价于类中的 self 操作符。

```php
<?php
namespace MyProject;

use blah\blah as mine; // 查看下一节内容 使用命名空间：别名/导入

blah\mine(); // 调用函数 MyProject\blah\mine()
namespace\blah\mine(); // 调用函数 MyProject\blah\mine()

namespace\func(); // 调用函数 MyProject\func()
namespace\sub\func(); // 调用函数 MyProject\sub\func()
namespace\cname::method(); // 调用 MyProject\cname 类的静态方法 "method" of class 
$a = new namespace\sub\cname(); // MyProject\sub\cname 类的实例对象
$b = namespace\CONSTANT; // 将 MyProject\CONSTANT 的常量赋值给 $b
?>
```

#### 使用命名空间：别名/导入

允许通过别名引用或导入外部的完全限定名称，是命名空间的一个重要特征。这有点类似于在类 unix 文件系统中可以创建对其它的文件或目录的符号连接。

所有支持命名空间的PHP版本支持三种别名或导入方式：为类名称使用别名、为接口使用别名或为命名空间名称使用别名。PHP 5.6开始允许导入函数或常量或者为它们设置别名。

在PHP中，别名是通过操作符 use 来实现的. 下面是一个使用所有可能的五种导入方式的例子：

```php
<?php
namespace foo;
use My\Full\Classname as Another;

// 下面的例子与 use My\Full\NSname as NSname 相同
use My\Full\NSname;

// 导入一个全局类
use ArrayObject;

// importing a function (PHP 5.6+)
use function My\Full\functionName;

// aliasing a function (PHP 5.6+)
use function My\Full\functionName as func;

// importing a constant (PHP 5.6+)
use const My\Full\CONSTANT;

$obj = new namespace\Another; // 实例化 foo\Another 对象
$obj = new Another; // 实例化 My\Full\Classname　对象
NSname\subns\func(); // 调用函数 My\Full\NSname\subns\func
$a = new ArrayObject(array(1)); // 实例化 ArrayObject 对象
// 如果不使用 "use \ArrayObject" ，则实例化一个 foo\ArrayObject 对象
func(); // calls function My\Full\functionName
echo CONSTANT; // echoes the value of My\Full\CONSTANT
?>
```

注意对命名空间中的名称（包含命名空间分隔符的完全限定名称如 Foo\Bar以及相对的不包含命名空间分隔符的全局名称如 FooBar）来说，前导的反斜杠是不必要的也不推荐的，因为导入的名称必须是完全限定的，不会根据当前的命名空间作相对解析。
为了简化操作，PHP还支持在一行中使用多个use语句

```php
<?php
use My\Full\Classname as Another, My\Full\NSname;

$obj = new Another; // 实例化 My\Full\Classname 对象
NSname\subns\func(); // 调用函数 My\Full\NSname\subns\func
?>
```

导入操作是在编译执行的，但动态的类名称、函数名称或常量名称则不是。

导入和动态名称：
```php
<?php
use My\Full\Classname as Another, My\Full\NSname;

$obj = new Another; // 实例化一个 My\Full\Classname 对象
$a = 'Another';
$obj = new $a;      // 实际化一个 Another 对象
?>
```

另外，导入操作只影响非限定名称和限定名称。完全限定名称由于是确定的，故不受导入的影响。

导入和完全限定名称：
```php
<?php
use My\Full\Classname as Another, My\Full\NSname;

$obj = new Another;         // instantiates object of class My\Full\Classname
$obj = new \Another;        // instantiates object of class Another
$obj = new Another\thing;   // instantiates object of class My\Full\Classname\thing
$obj = new \Another\thing;  // instantiates object of class Another\thing
?>
```

#### 全局空间

如果没有定义任何命名空间，所有的类与函数的定义都是在全局空间，与 PHP 引入命名空间概念前一样。在名称前加上前缀 \ 表示该名称是全局空间中的名称，即使该名称位于其它的命名空间中时也是如此。

```php
<?php
namespace A\B\C;

/* 这个函数是 A\B\C\fopen */
function fopen() { 
     /* ... */
     $f = \fopen(...); // 调用全局的fopen函数
     return $f;
} 
?>
```

#### 后备全局函数/常量

在一个命名空间中，当 PHP 遇到一个非限定的类、函数或常量名称时，它使用不同的优先策略来解析该名称。类名称总是解析到当前命名空间中的名称。因此在访问系统内部或不包含在命名空间中的类名称时，必须使用完全限定名称，例如：

```php
<?php
namespace A\B\C;
class Exception extends \Exception {}

$a = new Exception('hi'); // $a 是类 A\B\C\Exception 的一个对象
$b = new \Exception('hi'); // $b 是类 Exception 的一个对象
$c = new ArrayObject; // 致命错误, 找不到 A\B\C\ArrayObject 类
?>
```

对于函数和常量来说，如果当前命名空间中不存在该函数或常量，PHP 会退而使用全局空间中的函数或常量。

```php
<?php
namespace A\B\C;

const E_ERROR = 45;
function strlen($str) {
    return \strlen($str) - 1;
}

echo E_ERROR, "\n"; // 输出 "45"
echo INI_ALL, "\n"; // 输出 "7" - 使用全局常量 INI_ALL

echo strlen('hi'), "\n"; // 输出 "1"
if (is_array('hi')) { // 输出 "is not array"
    echo "is array\n";
} else {
    echo "is not array\n";
}
?>
```

#### 名称解析规则

名称解析遵循下列规则：

1. 对完全限定名称的函数，类和常量的调用在编译时解析。例如 new \A\B 解析为类 A\B。
2. 所有的非限定名称和限定名称（非完全限定名称）根据当前的导入规则在编译时进行转换。例如，如果命名空间 A\B\C 被导入为 C，那么对 C\D\e() 的调用就会被转换为 A\B\C\D\e()。
3. 在命名空间内部，所有的没有根据导入规则转换的限定名称均会在其前面加上当前的命名空间名称。例如，在命名空间 A\B 内部调用 C\D\e()，则 C\D\e() 会被转换为 A\B\C\D\e() 。
4. 非限定类名根据当前的导入规则在编译时转换（用全名代替短的导入名称）。例如，如果命名空间 A\B\C 导入为C，则 new C() 被转换为 new A\B\C() 。
5. 在命名空间内部（例如A\B），对非限定名称的函数调用是在运行时解析的。例如对函数 foo() 的调用是这样解析的：
    1. 在当前命名空间中查找名为 A\B\foo() 的函数
    2. 尝试查找并调用 全局(global) 空间中的函数 foo()。
6. 在命名空间（例如A\B）内部对非限定名称或限定名称类（非完全限定名称）的调用是在运行时解析的。下面是调用 new C() 及 new D\E() 的解析过程： new C()的解析:
    1. 在当前命名空间中查找A\B\C类。
    2. 尝试自动装载类A\B\C。


new D\E()的解析:
1. 在类名称前面加上当前命名空间名称变成：A\B\D\E，然后查找该类。
2. 尝试自动装载类 A\B\D\E。


为了引用全局命名空间中的全局类，必须使用完全限定名称 new \C()。


### Errors

#### 错误基础

可悲的是，不管我们在写代码时多么小心，错误始终是有的。PHP将会为许多常见的我文件和运行问题提供错误，警告和一些通知，同时让我们知道如何检测和处理这些错误，使得调试程序容易的多。

PHP会报告与各种错误条件相对应的各种错误。

如果没有设置错误处理程序，则PHP将根据其配置处理错误。哪些错误报告或者哪些错误忽略是通过`error_reporting`指令控制（php.ini）。或者在运行时调用`error_reporting()`，但是不推荐这样配置，因为在脚本执行之前可能也会发生一些错误。

在开发环境，你应该配置`error_reporting`为`E_ALL`，因为你需要了解并解决PHP提出的问题。在生产环境，你可能希望将此设置的不太详细，比如 `E_ALL`, `E_NOTICE`, `E_STRICT`, `E_DEPRECATED`。但在许多情况下，`E_ALL`也是合适的，因为它可以提供潜在问题的早期预警。

PHP对错误的处理取决于两个 php.ini 指令。`display_errors` 控制是否将错误显示为脚本输出的一部分。应该始终在生产环境中禁用它，因为它可以包含诸如数据库密码之类的机密信息，但是它常常在开发环境启用，因为它可以确保立即报告问题。

除了显示错误，PHP也可以启用 `log_errors` 指令来记录错误日志。它将记录任何错误到错误日志文件，这在生产环境非常适用，你可以记录发生的错误，然后根据错误生成报告。

#### PHP 7 错误处理

PHP 7 改变了大多数错误的报告方式。不同于传统（PHP 5）的错误报告机制，现在大多数错误被作为 Error 异常抛出。

这种 Error 异常可以像 Exception 异常一样被第一个匹配的 `try / catch` 块所捕获。如果没有匹配的 catch 块，则调用异常处理函数（事先通过 `set_exception_handler()` 注册）进行处理。 如果尚未注册异常处理函数，则按照传统方式处理：被报告为一个致命错误（Fatal Error）。

Error 类并非继承自 Exception 类，所以不能用 `catch (Exception $e) { ... }` 来捕获 Error。你可以用 `catch (Error $e) { ... }`，或者通过注册异常处理函数 `set_exception_handler()` 来捕获 Error。


### 异常

#### 异常处理

PHP 5 有一个类似于其他语言的异常处理模型。在PHP中可以主动抛出和捕获一个异常。代码被包含在 try 代码块中以便可以捕获，每一个 try 代码块都至少要有一个 catch 代码块或者 finally 代码块。

可以使用多个 catch 块来捕获不同类别的异常，代码正常执行（try 代码块中没有抛出异常）则不会执行所有 catch 代码块的内容，异常也可以在 catch 代码块中重新抛出。
当抛出异常时，将不会继续执行下面的代码，PHP将尝试查找第一个匹配的 catch 块，如果一个异常没有捕捉到，将发出一个未捕捉的异常的消息，除非处理程序已定义了 `set_exception_handler()`。

在 PHP 5 和更高的版本，finally 代码块可以在最后一个 catch 块后指定，finally 块在 try 和 catch 执行完后总会执行的，不管是否抛出异常，finally 块的内容总会执行。

除了代码运行产生的异常 还可以使用 throw 主动抛出一个异常，抛出的异常需要是一个异常的类的对象。

示例：

```php
<?php
function inverse($x) {
    if (!$x) {
        throw new Exception('Division by zero.</br>');
    }
    return 1/$x;
}

try {
    echo inverse(5) . "</br>";
    echo inverse(0) . "</br>";
} catch (Exception $e) {
    echo 'Caught exception: ',  $e->getMessage();
} finally {
    echo "Second finally.</br>";
}

// Continue execution
echo "Hello World</br>";
?>
```

输出：

    0.2
    Caught exception: Division by zero.
    Second finally.
    Hello World


#### 自定义异常

可以通过继承异常类来自定义异常，`Exception` 是所有异常的基类。

Exception 类摘要：
```php
class Exception {
    /* 属性 */
    protected string $message ;     // 异常消息内容
    protected int $code ;           // 异常代码
    protected string $file ;        // 抛出异常的文件名
    protected int $line ;           // 抛出异常在该文件中的行号
    /* 方法 */
    public __construct ([ string $message = "" [, int $code = 0 [, Throwable $previous = NULL ]]] )
    final public string getMessage ( void )
    final public Throwable getPrevious ( void )
    final public int getCode ( void )
    final public string getFile ( void )
    final public int getLine ( void )
    final public array getTrace ( void )
    final public string getTraceAsString ( void )
    public string __toString ( void )
    final private void __clone ( void )
}
```

继承异常类：

```php
<?php
class MyException extends Exception { }

try {
    throw new MyException("自定义异常");
} catch (MyException $e) {
    echo $e . '</br>';
    echo "捕捉到了自定义异常</br>";
}
?>
```

输出：

    MyException: 自定义异常 in F:\phpstudy\src\index.php:5 Stack trace: #0 {main}
    捕捉到了自定义异常

### 生成器

#### 生成器总览

生成器提供了一种更容易的方法来实现简单的对象迭代，相比较定义类实现 Iterator 接口的方式，性能开销和复杂性大大降低。

生成器允许你在 foreach 代码块中写代码来迭代一组数据而不需要在内存中创建一个数组, 那会使你的内存达到上限，或者会占据可观的处理时间。相反，你可以写一个生成器函数，就像一个普通的自定义函数一样, 和普通函数只返回一次不同的是, 生成器可以根据需要 yield 多次，以便生成需要迭代的值。

一个简单的例子就是使用生成器来重新实现 range() 函数。 标准的 range() 函数需要在内存中生成一个数组包含每一个在它范围内的值，然后返回该数组, 结果就是会产生多个很大的数组。 比如，调用 range(0, 1000000) 将导致内存占用超过 100 MB。

做为一种替代方法, 我们可以实现一个 xrange() 生成器, 只需要足够的内存来创建 Iterator 对象并在内部跟踪生成器的当前状态，这样只需要不到1K字节的内存。

将 range() 实现为生成器：

```php
<?php
function xrange($start, $limit, $step = 1) {
    if ($start < $limit) {
        if ($step <= 0) {
            throw new LogicException('Step must be +ve');
        }
        for ($i = $start; $i <= $limit; $i += $step) {
            yield $i;
        }
    } else {
        if ($step >= 0) {
            throw new LogicException('Step must be -ve');
        }
        for ($i = $start; $i >= $limit; $i += $step) {
            yield $i;
        }
    }
}

// 注意下面range()和xrange()输出的结果是一样的。
echo 'Single digit odd numbers from range():  ';
foreach (range(0,10) as $number) {
    echo "$number ";
}
echo "</br>";
echo 'Single digit odd numbers from xrange(): ';
foreach (xrange(0,10) as $number) {
    echo "$number ";
}
?>
```

生成器对象：当第一次调用生成器的时候，返回生成器类的一个对象。这个对象与迭代器对象使用相同的方式实现了迭代器接口，并提供可以调用的方法来处理生成器的状态，包括从它返回值或者向它发送值。


#### 生成器语法

一个生成器函数看起来像一个普通的函数，不同的是普通函数返回一个值，而一个生成器可以yield生成许多它所需要的值。

当一个生成器被调用的时候，它返回一个可以被遍历的对象.当你遍历这个对象的时候(例如通过一个foreach循环)，PHP 将会在每次需要值的时候调用生成器函数，并在产生一个值之后保存生成器的状态，这样它就可以在需要产生下一个值的时候恢复调用状态。

一旦不再需要产生更多的值，生成器函数可以简单退出，而调用生成器的代码还可以继续执行，就像一个数组已经被遍历完了。

在一个生成器函数中不可以存在 return ，否则将产生一个错误。

##### yield 关键字

生成器函数的核心是yield关键字。它最简单的调用形式看起来像一个return申明，不同之处在于普通return会返回值并终止函数的执行，而yield会返回一个值给循环调用此生成器的代码并且只是暂停执行生成器函数。

示例：

```php
<?php
function gen_one_to_three() {
    for ($i = 1; $i <= 3; $i++) {
        //注意变量$i的值在不同的yield之间是保持传递的。
        yield $i;
    }
}
$generator = gen_one_to_three();
foreach ($generator as $value) {
    echo "$value</br>";
}
?>
```

输出：

    1
    2
    3


使用引用来生成值

生成函数可以像使用值一样来使用引用生成。这个和从函数返回一个引用一样：通过在函数名前面加一个引用符号。

```php
<?php
function &gen_reference() {
    $value = 3;
    while ($value > 0) {
        yield $value;
    }
}

// 我们可以在循环中修改$number的值，而生成器是使用的引用值来生成
// 所以gen_reference()内部的$value值也会跟着变化。

foreach (gen_reference() as &$number) {
    echo (--$number).'... ';
}
?>
```

输出：

    2... 1... 0... 


### 引用的解释

#### 引用是什么

在 PHP 中引用意味着用不同的名字访问同一个变量内容。这并不像 C 的指针：例如你不能对他们做指针运算，他们并不是实际的内存地址…… 替代的是，引用是符号表别名。注意在PHP 中，变量名和变量内容是不一样的， 因此同样的内容可以有不同的名字。最接近的比喻是 Unix 的文件名和文件本身——变量名是目录条目，而变量内容则是文件本身。引用可以被看作是 Unix 文件系统中的硬链接。

#### 引用做什么

PHP 的引用允许用两个变量来指向同一个内容。意思是，当这样做时：

```php
<?php
$a =& $b;
?>
```

这意味着 $a 和 $b 指向了同一个变量。

同样的语法可以用在函数中，它返回引用，以及用在 new 运算符中

```php
<?php
$bar =& new fooclass();
$foo =& find_var($bar);
?>
```

自 PHP 5 起，new 自动返回引用，因此在此使用 =& 已经过时了并且会产生 E_STRICT 级别的消息。

引用做的第二件事是用引用传递变量。这是通过在函数内建立一个本地变量并且该变量在呼叫范围内引用了同一个内容来实现的。例如：

```php
<?php
function foo(&$var) {
    $var++;
}
$a=5;
foo($a);
?>
```

将使 $a 变成 6。这是因为在 foo 函数中变量 $var 指向了和 $a 指向的同一个内容。

#### 引用不是什么

如前所述，引用不是指针。这意味着下面的结构不会产生预期的效果：

```php
<?php
function foo(&$var)
{
    $var =& $GLOBALS["baz"];
}
foo($bar);
?>
```

这将使 foo 函数中的 $var 变量在函数调用时和 $bar 绑定在一起，但接着又被重新绑定到了 $GLOBALS["baz"] 上面。不可能通过引用机制将 $bar 在函数调用范围内绑定到别的变量上面，因为在函数 foo 中并没有变量 $bar（它被表示为 $var，但是 $var 只有变量内容而没有调用符号表中的名字到值的绑定）。可以使用引用返回来引用被函数选择的变量。

#### 引用传递

可以将一个变量通过引用传递给函数，这样该函数就可以修改其参数的值。语法如下：

```php
<?php
function foo(&$var) {
    $var++;
}

$a=5;
foo($a);
// $a is 6 here
?>
```

以下内容可以通过引用传递：

+ 变量，例如 foo($a)
+ New 语句，例如 foo(new foobar())
+ 从函数中返回的引用，例如：

```php
<?php
function &bar() {
    $a = 5;
    return $a;
}
foo(bar());
?>
```

任何其它表达式都不能通过引用传递。


#### 引用返回

引用返回用在当想用函数找到引用应该被绑定在哪一个变量上面时。不要用返回引用来增加性能，引擎足够聪明来自己进行优化。仅在有合理的技术原因时才返回引用！要返回引用，使用此语法：

```php
<?php
class foo {
    public $value = 42;
    public function &getValue() {
        return $this->value;
    }
}

$obj = new foo;
$myValue = &$obj->getValue(); // $myValue 是 $obj->value 的引用，现在值是 42
$obj->value = 2;
echo $myValue;                // 打印 $obj->value 的值, 现在是 2
?>
```

#### 取消引用

当 unset 一个引用，只是断开了变量名和变量内容之间的绑定。这并不意味着变量内容被销毁了。例如：

```php
<?php
$a = 1;
$b =& $a;
unset($a);
?>
```

不会 unset $b，只是 $a。
再拿这个和 Unix 的 unlink 调用来类比一下可能有助于理解。

#### 引用定位

许多 PHP 的语法结构是通过引用机制实现的，所以上述有关引用绑定的一切也都适用于这些结构。一些结构，例如引用传递和返回，已经在上面提到了。其它使用引用的结构有：

+ global 引用

当用 global $var 声明一个变量时实际上建立了一个到全局变量的引用。也就是说和这样做是相同的：

```php
<?php
$var =& $GLOBALS["var"];
?>
```

这意味着，例如，unset $var 不会 unset 全局变量。

+ $this 在一个对象的方法中，$this 永远是调用它的对象的引用。

### 预定义变量

对于全部脚本而言，PHP 提供了大量的预定义变量。这些变量将所有的外部变量表示成内建环境变量，并且将错误信息表示成返回头。

#### 超全局变量

超全局变量 — 超全局变量是在全部作用域中始终可用的内置变量

PHP 中的许多预定义变量都是“超全局的”，这意味着它们在一个脚本的全部作用域中都可用。在函数或方法中无需执行 `global $variable;` 就可以访问它们。

这些超全局变量是：

+ $GLOBALS
+ $_SERVER
+ $_GET
+ $_POST
+ $_FILES
+ $_COOKIE
+ $_SESSION
+ $_REQUEST
+ $_ENV


#### $GLOBALS

`$GLOBALS` -- 引用全局作用域中可用的全部变量，一个包含了全部变量的全局组合数组。变量的名字就是数组的键。

示例：
```php
<?php
function test() {
    $foo = "local variable";

    echo '$foo in global scope: ' . $GLOBALS["foo"] . "\n";
    echo '$foo in current scope: ' . $foo . "\n";
}

$foo = "Example content";
test();
?>
```

#### $_SERVER

`$_SERVER` -- 服务器和执行环境信息。`$_SERVER` 是一个包含了诸如头信息(header)、路径(path)、以及脚本位置(script locations)等等信息的数组。这个数组中的项目由 Web 服务器创建。不能保证每个服务器都提供全部项目；服务器可能会忽略一些，或者提供一些没有在这里列举出来的项目。

+ `PHP_SELF` -- 当前执行脚本的文件名，与 `document root` 有关。例如，在地址为 `http://example.com/foo/bar.php` 的脚本中使用 `$_SERVER['PHP_SELF']` 将得到 `/foo/bar.php`。\_\_FILE\_\_ 常量包含当前(例如包含)文件的完整路径和文件名。 从 PHP 4.3.0 版本开始，如果 PHP 以命令行模式运行，这个变量将包含脚本名。之前的版本该变量不可用。

+ `argv` -- 传递给该脚本的参数的数组。当脚本以命令行方式运行时，argv 变量传递给程序 C 语言样式的命令行参数。当通过 GET 方式调用时，该变量包含query string。

+ `argc` -- 包含命令行模式下传递给该脚本的参数的数目(如果运行在命令行模式下)。

+ `GATEWAY_INTERFACE` -- 服务器使用的 CGI 规范的版本；例如，"CGI/1.1"。

+ `SERVER_ADDR` -- 当前运行脚本所在的服务器的 IP 地址。

+ `SERVER_NAME` -- 当前运行脚本所在的服务器的主机名。如果脚本运行于虚拟主机中，该名称是由那个虚拟主机所设置的值决定。

+ `SERVER_SOFTWARE` -- 服务器标识字符串，在响应请求时的头信息中给出。

+ `SERVER_PROTOCOL` -- 请求页面时通信协议的名称和版本。例如，"HTTP/1.0"。

+ `REQUEST_METHOD` -- 访问页面使用的请求方法；例如，"GET", "HEAD"，"POST"，"PUT"。

+ `REQUEST_TIME` -- 请求开始时的时间戳。从 PHP 5.1.0 起可用。

+ `REQUEST_TIME_FLOAT` -- 请求开始时的时间戳，微秒级别的精准度。 自 PHP 5.4.0 开始生效。

+ `QUERY_STRING` -- query string（查询字符串），如果有的话，通过它进行页面访问。

+ `DOCUMENT_ROOT` -- 当前运行脚本所在的文档根目录。在服务器配置文件中定义。

+ `HTTP_ACCEPT` -- 当前请求头中 Accept: 项的内容，如果存在的话。

+ `HTTP_ACCEPT_CHARSET` -- 当前请求头中 `Accept-Charset:` 项的内容，如果存在的话。例如：`iso-8859-1,*,utf-8`。

+ `HTTP_ACCEPT_ENCODING` -- 当前请求头中 `Accept-Encoding:` 项的内容，如果存在的话。例如：`gzip`。

+ `HTTP_ACCEPT_LANGUAGE` -- 当前请求头中 `Accept-Language:` 项的内容，如果存在的话。例如：`en`。

+ `HTTP_CONNECTION` -- 当前请求头中 `Connection:` 项的内容，如果存在的话。例如：`Keep-Alive`。

+ `HTTP_HOST` -- 当前请求头中 `Host:` 项的内容，如果存在的话。

+ `HTTP_REFERER` -- 引导用户代理到当前页的前一页的地址（如果存在）。由 user agent 设置决定。并不是所有的用户代理都会设置该项，有的还提供了修改 `HTTP_REFERER` 的功能。简言之，该值并不可信。

+ `HTTP_USER_AGENT` -- 当前请求头中 `User-Agent:` 项的内容，如果存在的话。该字符串表明了访问该页面的用户代理的信息。一个典型的例子是：`Mozilla/4.5 [en] (X11; U; Linux 2.2.9 i586)`。除此之外，你可以通过 `get_browser()` 来使用该值，从而定制页面输出以便适应用户代理的性能。

+ `HTTPS` -- 如果脚本是通过 HTTPS 协议被访问，则被设为一个非空的值。

+ `REMOTE_ADDR` -- 浏览当前页面的用户的 IP 地址。

+ `REMOTE_HOST` -- 浏览当前页面的用户的主机名。DNS 反向解析不依赖于用户的 `REMOTE_ADDR`。

+ `REMOTE_PORT` -- 用户机器上连接到 Web 服务器所使用的端口号。

+ `REMOTE_USER` -- 经验证的用户

+ `REDIRECT_REMOTE_USER` -- 验证的用户，如果请求已在内部重定向。

+ `SCRIPT_FILENAME` -- 当前执行脚本的绝对路径。

+ `SERVER_ADMIN` -- 该值指明了 Apache 服务器配置文件中的 `SERVER_ADMIN` 参数。如果脚本运行在一个虚拟主机上，则该值是那个虚拟主机的值。

+ `SERVER_PORT` -- Web 服务器使用的端口。默认值为 "80"。如果使用 SSL 安全连接，则这个值为用户设置的 HTTP 端口。

+ `SERVER_SIGNATURE` -- 包含了服务器版本和虚拟主机名的字符串。

+ `PATH_TRANSLATED` -- 当前脚本所在文件系统（非文档根目录）的基本路径。这是在服务器进行虚拟到真实路径的映像后的结果。

+ `SCRIPT_NAME` -- 包含当前脚本的路径。这在页面需要指向自己时非常有用。\_\_FILE\_\_ 常量包含当前脚本(例如包含文件)的完整路径和文件名。

+ `REQUEST_URI` -- URI 用来指定要访问的页面。例如 `/index.html`。

+ `PHP_AUTH_DIGEST` -- 当作为 Apache 模块运行时，进行 HTTP Digest 认证的过程中，此变量被设置成客户端发送的"Authorization" HTTP 头内容（以便作进一步的认证操作）。

+ `PHP_AUTH_USER` -- 当 PHP 运行在 Apache 或 IIS（PHP 5 是 ISAPI）模块方式下，并且正在使用 HTTP 认证功能，这个变量便是用户输入的用户名。

+ `PHP_AUTH_PW` -- 当 PHP 运行在 Apache 或 IIS（PHP 5 是 ISAPI）模块方式下，并且正在使用 HTTP 认证功能，这个变量便是用户输入的密码。

+ `AUTH_TYPE` -- 当 PHP 运行在 Apache 模块方式下，并且正在使用 HTTP 认证功能，这个变量便是认证的类型。

+ `PATH_INFO` -- 包含由客户端提供的、跟在真实脚本名称之后并且在查询语句（query string）之前的路径信息，如果存在的话。例如，如果当前脚本是通过 URL `http://www.example.com/php/path_info.php/some/stuff?foo=bar` 被访问，那么 `$_SERVER['PATH_INFO']` 将包含 `/some/stuff`。

+ `ORIG_PATH_INFO` -- 在被 PHP 处理之前，`PATH_INFO` 的原始版本。

示例：

```php
<?php
echo '<pre>';
echo $_SERVER['SERVER_NAME'];
echo $_SERVER['HTTP_USER_AGENT'];
?>
```

#### $_GET

`$_GET` -- HTTP GET 变量，通过 URL 参数传递给当前脚本的变量的数组。

示例：

```php
<?php
echo 'Hello ' . htmlspecialchars($_GET["name"]) . '!';
?>
```

浏览器访问：`http://127.0.0.1:8088/?name=World`


#### $_POST

`$_POST` HTTP POST 变量，当 HTTP POST 请求的 `Content-Type` 是 `application/x-www-form-urlencoded` 或 `multipart/form-data` 时，会将变量以关联数组形式传入当前脚本。

示例：

post.html
```html
<html>
<body>
    <form action="post.php" method="post">
        Name: <input type="text" name="name">
        <input type="submit">
    </form>
</body>
</html>
```

post.php
```php
<?php
echo 'Hello ' . htmlspecialchars($_POST["name"]) . '!';
?>
```

浏览器访问：`http://127.0.0.1:8088/post.html`，输入内容后提交。

#### $_FILES

`$_FILES` -- HTTP 文件上传变量，通过 HTTP POST 方式上传到当前脚本的项目的数组

示例：

file.html
```html
<html>
<body>
    <form action="file.php" enctype="multipart/form-data" method="post">
        File: <input type="file" name="name">
        <input type="submit">
    </form>
</body>
</html>
```

file.php
```php
<?php
var_dump($_FILES);
?>
```

#### $_REQUEST

`$_REQUEST` -- HTTP Request 变量，默认情况下包含了 `$_GET`，`$_POST` 和 `$_COOKIE` 的数组。

#### $_SESSION

`$_SESSION` -- Session 变量，当前脚本可用 SESSION 变量的数组。Session 是浏览器会话保持机制。

示例：

```php
<?php
session_start();
if (!isset($_SESSION['count'])) {
  $_SESSION['count'] = 0;
} else {
  $_SESSION['count']++;
}
echo $_SESSION['count'];
?>
```

然后不断的访问这个页面，可以看到数值不断增加。

#### $_ENV

`$_ENV` -- 环境变量，通过环境方式传递给当前脚本的变量的数组。

这些变量被从 PHP 解析器的运行环境导入到 PHP 的全局命名空间。很多是由支持 PHP 运行的 Shell 提供的，并且不同的系统很可能运行着不同种类的 Shell，所以不可能有一份确定的列表。请查看你的 Shell 文档来获取定义的环境变量列表。

其他环境变量包含了 CGI 变量，而不管 PHP 是以服务器模块还是 CGI 处理器的方式运行。

示例：

```php
<?php
var_dump($_ENV);
?>
```

#### $_COOKIE

`$_COOKIE` -- HTTP Cookies，通过 HTTP Cookies 方式传递给当前脚本的变量的数组。Cookie 也是浏览器会话保持机制，与 Session 不同的是，Session 的内容保存在服务器端，而 Cookie 的内容保存在浏览器，所以安全性不如 Session 。

示例：
```php
<?php
if (!isset($_COOKIE['count'])) {
    $count = 0;
    setcookie('count', $count, time()+3600);
} else {
    $count = ++$_COOKIE['count'];
    setcookie('count', $count, time()+3600);
}
echo $count;
?>
```

然后不断的访问这个页面，可以看到数值不断增加。

#### $http\_response\_header

`$http_response_header` -- HTTP 响应头，`$http_response_header` 将会被 HTTP 响应头信息填充。`$http_response_header` 将被创建于局部作用域中。

示例：

```php
<?php
function get_contents() {
  file_get_contents("http://www.baidu.com");
  var_dump($http_response_header);
}
get_contents();
echo '</br>';
var_dump($http_response_header);
?>
```

可以看到 `$http_response_header` 只在 `get_contents()` 中被创建。

#### $argc

`$argc` -- 传递给脚本的参数数目，仅在命令行执行有效。

注意：脚本的文件名总是作为参数传递给当前脚本，因此 $argc 的最小值为 1。

argc.php
```php
<?php
echo $argc;
echo "\r\n";
?>
```

在终端里运行：`php argc.php a a a a` 输出：5

#### $argv

`$argv` -- 传递给脚本的参数数组，仅在命令行执行有效。

argv.php
```php
<?php
var_dump($argv);
?>
```

在终端里运行：`php argv.php a b c d`
输出：

    array(5) {
    [0]=>
    string(8) "argv.php"
    [1]=>
    string(1) "a"
    [2]=>
    string(1) "b"
    [3]=>
    string(1) "c"
    [4]=>
    string(1) "d"
    }


### 预定义接口

#### Traversable 接口

Traversable（遍历）接口，检测一个类是否可以使用 foreach 进行遍历的接口。无法被单独实现的基本抽象接口。相反它必须由 IteratorAggregate 或 Iterator 接口实现。

接口摘要：

```php
Traversable { }
```

这个接口没有任何方法，它的作用仅仅是作为所有可遍历类的基本接口。

#### Iterator 接口

Iterator（迭代器）接口，可在内部迭代自己的外部迭代器或类的接口。

接口摘要：
```php
Iterator extends Traversable {
/* 方法 */
    abstract public mixed current ( void )
    abstract public scalar key ( void )
    abstract public void next ( void )
    abstract public void rewind ( void )
    abstract public bool valid ( void )
}
```

基本用法：

```php
<?php
class myIterator implements Iterator {
    private $position = 0;
    private $array = array(
        "firstelement",
        "secondelement",
        "lastelement",
    );  
    public function __construct() {
        $this->position = 0;
    }
    function rewind() {
        var_dump(__METHOD__);
        $this->position = 0;
    }
    function current() {
        var_dump(__METHOD__);
        return $this->array[$this->position];
    }
    function key() {
        var_dump(__METHOD__);
        return $this->position;
    }
    function next() {
        var_dump(__METHOD__);
        ++$this->position;
    }
    function valid() {
        var_dump(__METHOD__);
        return isset($this->array[$this->position]);
    }
}

$it = new myIterator;
foreach($it as $key => $value) {
    var_dump($key, $value);
    echo "\n";
}
?>
```

只要实现了 Iterator 这个接口的类，它的对象就可以使用 foreach 迭代了。

其中要实现的方法：

+ `Iterator::current` — 返回当前元素，此函数没有参数，可返回任何类型。
+ `Iterator::key` — 返回当前元素的键，此函数没有参数，成功返回标量，失败则返回 NULL。
+ `Iterator::next` — 向前移动到下一个元素，此函数没有参数，任何返回都将被忽略。
+ `Iterator::rewind` — 返回到迭代器的第一个元素，此函数没有参数，任何返回都将被忽略。
+ `Iterator::valid` — 检查当前位置是否有效，此函数没有参数，返回将被转换为布尔型。成功时返回 TRUE， 或者在失败时返回 FALSE。

#### IteratorAggregate 接口

IteratorAggregate（聚合式迭代器）接口，创建外部迭代器的接口。

接口摘要：
```php
IteratorAggregate extends Traversable {
    /* 方法 */
    abstract public Traversable getIterator ( void )
}
```

基本用法：
```php
<?php
class myData implements IteratorAggregate {
    public $property1 = "Public property one";
    public $property2 = "Public property two";
    public $property3 = "Public property three";

    public function __construct() {
        $this->property4 = "last property";
    }

    public function getIterator() {
        return new ArrayIterator($this);
    }
}

$obj = new myData;
foreach($obj as $key => $value) {
    var_dump($key, $value);
    echo "\n";
}
?>
```

方法：`IteratorAggregate::getIterator` 返回一个外部迭代器，此函数没有参数，返回实现了 Iterator 或 Traversable 接口的类的一个实例。

#### ArrayAccess 接口

ArrayAccess（数组式访问）接口，提供像访问数组一样访问对象的能力的接口。

接口摘要：

```php
ArrayAccess {
    /* 方法 */
    abstract public boolean offsetExists ( mixed $offset )
    abstract public mixed offsetGet ( mixed $offset )
    abstract public void offsetSet ( mixed $offset , mixed $value )
    abstract public void offsetUnset ( mixed $offset )
}
```

示例：
```php
<?php
class obj implements arrayaccess {
    private $container = array();
    public function __construct() {
        $this->container = array(
            "one"   => 1,
            "two"   => 2,
            "three" => 3,
        );
    }
    public function offsetSet($offset, $value) {
        if (is_null($offset)) {
            $this->container[] = $value;
        } else {
            $this->container[$offset] = $value;
        }
    }
    public function offsetExists($offset) {
        return isset($this->container[$offset]);
    }
    public function offsetUnset($offset) {
        unset($this->container[$offset]);
    }
    public function offsetGet($offset) {
        return isset($this->container[$offset]) ? $this->container[$offset] : null;
    }
}

$obj = new obj;

var_dump(isset($obj["two"]));
var_dump($obj["two"]);
unset($obj["two"]);
var_dump(isset($obj["two"]));
$obj["two"] = "A value";
var_dump($obj["two"]);
$obj[] = 'Append 1';
$obj[] = 'Append 2';
$obj[] = 'Append 3';
print_r($obj);
?>
```

+ `ArrayAccess::offsetExists` -- 检查一个偏移位置是否存在
+ `ArrayAccess::offsetGet` -- 获取一个偏移位置的值
+ `ArrayAccess::offsetSet` -- 设置一个偏移位置的值
+ `ArrayAccess::offsetUnset` -- 复位一个偏移位置的值

#### 序列化接口

Serializable 自定义序列化的接口。

实现此接口的类将不再支持 __sleep() 和 __wakeup()。不论何时，只要有实例需要被序列化，serialize 方法都将被调用。它将不会调用 `__destruct()` 或有其他影响，除非程序化地调用此方法。当数据被反序列化时，类将被感知并且调用合适的 `unserialize()` 方法而不是调用 `__construct()`。如果需要执行标准的构造器，你应该在这个方法中进行处理。

接口摘要：

```php
Serializable {
    /* 方法 */
    abstract public string serialize ( void )
    abstract public mixed unserialize ( string $serialized )
}
```

示例：

```php
<?php
class obj implements Serializable {
    private $data;
    public function __construct() {
        $this->data = "My private data";
    }
    public function serialize() {
        return serialize($this->data);
    }
    public function unserialize($data) {
        $this->data = unserialize($data);
    }
    public function getData() {
        return $this->data;
    }
}

$obj = new obj;
$ser = serialize($obj);
$newobj = unserialize($ser);
var_dump($newobj->getData());
?>
```

+ `Serializable::serialize` — 对象的字符串表示
+ `Serializable::unserialize` — 构造对象

#### Closure 类

用于代表匿名函数的类。

匿名函数会产生这个类型的对象。在过去，这个类被认为是一个实现细节，但现在可以依赖它做一些事情。自 PHP 5.4 起，这个类带有一些方法，允许在匿名函数创建后对其进行更多的控制。

除了此处列出的方法，还有一个 `__invoke` 方法。这是为了与其他实现了 `__invoke()` 魔术方法 的对象保持一致性，但调用匿名函数的过程与它无关。

类摘要：

```php
Closure {
    /* 方法 */
    __construct ( void )
    public static Closure bind ( Closure $closure , object $newthis [, mixed $newscope = 'static' ] )
    public Closure bindTo ( object $newthis [, mixed $newscope = 'static' ] )
}
```

+ `Closure::__construct` — 用于禁止实例化的构造函数
+ `Closure::bind` — 复制一个闭包，绑定指定的$this对象和类作用域。
+ `Closure::bindTo` — 复制当前闭包对象，绑定指定的$this对象和类作用域。

#### 生成器类

Generator 对象是从 generators 返回的，Generator 对象不能通过 new 实例化。

类摘要：

```php
Generator implements Iterator {
    /* 方法 */
    public mixed current ( void )
    public mixed key ( void )
    public void next ( void )
    public void rewind ( void )
    public mixed send ( mixed $value )
    public void throw ( Exception $exception )
    public bool valid ( void )
    public void __wakeup ( void )
}
```

+ `Generator::current` — 返回当前产生的值
+ `Generator::key` — 返回当前产生的键
+ `Generator::next` — 生成器继续执行
+ `Generator::rewind` — 重置迭代器
+ `Generator::send` — 向生成器中传入一个值
+ `Generator::throw` — 向生成器中抛入一个异常
+ `Generator::valid` — 检查迭代器是否被关闭
+ `Generator::__wakeup` — 序列化回调

## 附录  

到这里 PHP 的基础语法就结束了，想要用 PHP 去解决一些实际的事情就需要学习 PHP 如何应用了。

本篇根据整理学习 [PHP 官方手册](http://php.net/manual/zh/index.php) 完成。