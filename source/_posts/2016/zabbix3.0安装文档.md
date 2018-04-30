---
title: Zabbix3.0安装文档
date: 2016-04-02 10:12:00
categories: 
    - Zabbix
tags:
    - zabbix
    - 监控
    - LNMP
---
## <font color='#5CACEE'>简介</font>
>zabbix是一个基于WEB界面的提供分布式系统监视以及网络监视功能的企业级的开源解决方案。
zabbix能监视各种网络参数，保证服务器系统的安全运营；并提供灵活的通知机制以让系统管理员快速定位/解决存在的各种问题。
zabbix由2部分构成，zabbix server与可选组件zabbix agent。
zabbix server可以通过SNMP，zabbix agent，ping，端口监视等方法提供对远程服务器/网络状态的监视，数据收集等功能，它可以运行在Linux，Solaris，HP-UX，AIX，Free BSD，Open BSD，OS X等平台上
[<font color='#AAAAAA'>百度百科</font>](http://baike.baidu.com/link?url=j3tIKvRZKMKpBkPLSXFs-lhgWSCI3Yh13Ohk7y2WOkzfLsRnZG3zZ3nHZKDKxNnl8EL6Jt37OkqEwH6DxRMfJq)
<!-- more -->


	
## <font color='#5CACEE'>环境</font>
> 在Linux下编译安装 zabbix3.0版对PHP最低版本要求是5.4 其他软件包无要求 

### <font color='#CDAA7D'>主机环境</font>
|      身份      |      系统     |       IP       |
| -------------  |:-------------:| --------------:|
| MySQL 服务器   |   CentOS 6.7  |   172.17.0.2   |
| PHP-fpm 服务器 |   CentOS 6.7  |   172.17.0.3   | 
| Nginx 服务器   |   CentOS 6.7  |   172.17.0.4   |
| Zabbix Server  |   CentOS 6.7  |   172.17.0.5   |
| Zabbix Agent1  |   CentOS 6.7  |   172.17.0.6   |
| Zabbix Agent2  |   Windows     |   172.17.0.7   |
  
### <font color='#CDAA7D'>软件环境</font>

|软件名称|版本号|下载地址|
|-|:-:|-:|
|php|5.6.19|[<font color='#AAAAAA'>下载地址</font>](http://cn2.php.net/distributions/php-5.6.19.tar.xz)|
|nginx|1.9.13|[<font color='#AAAAAA'>点击下载</font>](http://nginx.org/download/nginx-1.9.13.tar.gz)|
|mysql|5.6.28|[<font color='#AAAAAA'>点击下载</font>](http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz)|
|zabbix|3.0.1|[<font color='#AAAAAA'>点击下载</font>](http://ufpr.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.1/zabbix-3.0.1.tar.gz)|
|zabbix agent win版|3.0.0|[<font color='#AAAAAA'>点击下载</font>](http://www.zabbix.com/downloads/3.0.0/zabbix_agents_3.0.0.win.zip)|


## <font color='#5CACEE'>步骤</font>
### <font color='#CDAA7D'>搭建LNMP环境</font>
> 由于zabbix自带的web管理界面需要PHP环境 所以只需要提供一个PHP版本不低于5.4的web环境即可
以下是在Linux上搭建LNMP环境

|服务器|安装文档地址|
|-|:-:|-|
|Nginx|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/03/31/nginx/nginx编译安装)|
|MySQL|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/mysql/MySQL编译安装)|
|PHP-fpm|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/php/php-fpm编译安装)|
|LNMP|[<font color='#AAAAAA'>点击打开文档内容</font>](/2016/04/01/lnmp/LNMP环境部署)|

### <font color='#CDAA7D'>编译安装Zabbix</font>
> 需要系统先初始化开发环境 以及安装需要的程序开发包

	yum -y install gcc mysql-devel libxml2-devel net-snmp-devel libssh2-devel curl-devel
	
```bash
tar xf zabbix-3.0.1.tar.gz
cd zabbix-3.0.1
./configure --prefix=/usr/local/zabbix \
--enable-server --enable-agent \
--with-mysql --with-net-snmp \
--with-libcurl --with-libxml2 --with-ssh2
make -j4 && make install
```

### <font color='#CDAA7D'>配置zabbix server</font>
> 还需要给zabbix server配置防火墙安全策略 数据库 web服务等

#### <font color='#DDA0DD'>配置防火墙</font>
	关闭或者配置服务器的iptables和SElinux策略
	service iptables stop
	setenforce 0
	vim /etc/selinux/config
		修改SELINUX=disabled

#### <font color='#DDA0DD'>导入数据库</font>
	mysql授权zabbix用户以及创建zabbix库
	mysql -uroot -h172.17.0.2 -p
	mysql> grant all privileges on zabbix.* to zabbix@"%" identified by "123.com";
	mysql> create database zabbix default charset utf8;

```bash
mysql -uzabbix -h172.17.0.2 -p123.com zabbix < schema.sql
mysql -uzabbix -h172.17.0.2 -p123.com zabbix < images.sql
mysql -uzabbix -h172.17.0.2 -p123.com zabbix < data.sql
```

#### <font color='#DDA0DD'>启动zabbix服务</font>
	
	修改zabbix_server.conf
	vim /usr/local/zabbix/etc/zabbix_server.conf
	
	DBName=zabbix
	DBHost=172.17.0.2		# 这里就是MySQL服务器的地址
	DBUser=zabbix
	DBPassword=123.com
	DBPort=3306
	ListenPort=10051
	LogFile=/usr/local/zabbix/log/zabbix_server.log
	LogFileSize=100
	DebugLevel=2
	Timeout=30
	PidFile=/usr/local/zabbix/var/zabbix_server.pid
	StartPollers=20
	StartPollersUnreachable=5
	StartTrappers=5

	
```bash
mkdir /usr/local/zabbix/{log,var}
useradd -M -s /sbin/nologin zabbix		# 创建zabbix运行用户
chown -R zabbix:zabbix /usr/local/zabbix/
cp misc/init.d/fedora/core/{zabbix_server,zabbix_agentd} /etc/init.d/
chmod +x /etc/init.d/{zabbix_server,zabbix_agentd}		#服务控制脚本
# 修改/etc/init.d/zabbix_server 和 /etc/init.d/zabbix_agentd 
# 确保BASEDIR的路径正确 BASEDIR=/usr/local/zabbix
/usr/local/zabbix/sbin/zabbix_server	# 这里直接使用绝对路径启动程序
```

	检测zabbix_server是否正常启动监听 监听端口10051
	[root@7938190c2002 zabbix-3.0.1]# netstat -anpt |grep 10051
	tcp     0    0 0.0.0.0:10051       0.0.0.0:*        LISTEN      - 
	
	如果没有正常启动服务 请查看日志 /usr/local/zabbix/log/zabbix_server.log

#### <font color='#DDA0DD'>配置web管理界面</font>

	修改php-fpm服务的配置文件 修改为zabbix需要的值
	vim php.ini			# 本环境中 php.ini位置在/usr/local/php/lib/php.ini
	
		date.timezone = Asia/Shanghai
		post_max_size = 32M
		max_execution_time = 300
		max_input_time = 300
		always_populate_raw_post_data = -1		# php5.6以上版本会出现这个
	
	重启php-fpm服务
	service php-fpm restart

```bash
# 注意 是将php目录复制到php-fpm能访问到的路径 根据实际情况决定
# 本环境已经通过NFS让zabbix, nginx 和 php-fpm 共享/var/www/html目录
cp -rf frontends/php/ /var/www/html/zabbix
chmod -R 777 /var/www/html/zabbix/conf		# php页面需要将配置信息写到这个目录
```

打开浏览器 输入zabbix页面的地址 http://172.17.0.4/zabbix

点击 Next step 进入 Check of pre-requisites 页面
确定 Check of pre-requisites 一页都是绿色 然后 Next step

进入 Configure DB connection 页面 输入mysql连接信息
如果mysql服务在本地 可以输入使用默认的localhost 然后 Next step

![Configure DB connection](/uploads/2016/zabbix/20160402001321.png)

配置zabbix server的信息 输入zabbix server的IP地址 端口 还有名称
如果zabbix server在本机 Host使用默认的localhost即可 然后 Next step

![Zabbix server details](/uploads/2016/zabbix/20160402001814.png)

确认一次信息是否有误 如果无误就 Next step 完成安装
此时所有的信息保存在 /var/www/html/zabbix/conf/zabbix.conf.php 中

![Zabbix server details](/uploads/2016/zabbix/20160402002133.png)

进入登陆页面 初始用户名和密码是 admin/zabbix

![Zabbix server details](/uploads/2016/zabbix/20160402002624.png)

至此 zabbix server 安装安装完成 如果配置的有错误 还可以重新访问配置页面进行重新配置
http://172.17.0.4/zabbix/setup.php
	
#### <font color='#DDA0DD'>web管理界面中文支持</font>

zabbix官方提供了中文支持 但是需要修改php页面开启

	vim /var/www/html/zabbix/include/locales.inc.php 
	找到 'zh_CN' => array('name' => _('Chinese (zh_CN)'),   'display' => false],
	修改 'display' => true
	
在web管理界面 点击右上角的小人图标 或直接访问 `http://172.17.0.4/zabbix/profile.php`
此时已经打开了zabbix的设置界面 语言选择中找到中文语言 如果中文选择是灰色
说明当前系统并未支持`zh_CN`字符集 需要先安装`zh_CN`的支持才能正常选择中文

	localedef  -f UTF-8 -i zh_CN zh_CN.UTF8
	
通过 `locale -a` 可以查看当前系统已经支持的字符集
	
添加字符集后需要重启`php-fpm`服务 

如果想应用以及配置好的字符集 可以通过配置环境变量:

	export LANG='zh_CN.UTF-8'
	export LANGUANE='zh_CN.UTF-8'
	
如果想设置为系统默认字符集 可以将环境变量写入到配置文件

	CentOS系列: vim /etc/sysconfig/i18n
	
其实只要将已经添加好中文字符集的其他机器的 `locale-archive` 文件替换到自己目录即可
文件路径: `/usr/lib/locale/locale-archive` 但是这样 系统可能会缺乏相应的字体 所以并不推荐
	
自带的中文字体可能会出现乱码 这时需要自己替换中文字体解决
从Windows系统 `c:\windows\fonts` 或网上找一个自己喜欢的字体
复制到 `/var/www/html/zabbix/fonts/` 中 这里用 `msyh.ttf`
	
	sed -i 's/DejaVuSans/msyh/g' /var/www/html/zabbix/include/defines.inc.php

将默认的 `DejaVuSans` 替换成自己的 `msyh` 然后刷新网页
	
	
### <font color='#CDAA7D'>配置zabbix Agentd</font>
> 通过--enable-agent选项可以安装zabbix_agent 因此 zabbix_server安装的时候已经启用zabbix_agent
不需另行安装 其他客户端安装则不需过多编译选项 只需启用--enable-agent即可
	
#### <font color='#DDA0DD'>Linux主机安装Agentd</font>
> 以下操作是在Zabbix Agent1主机上进行编译

```bash
useradd -M -s /sbin/nologin zabbix
tar xf zabbix-2.2.10.tar.gz
cd zabbix-2.2.10
./configure --prefix=/usr/local/zabbix_agent --enable-agent
make && make install
mkdir /usr/local/zabbix_agent/{log,var}
chown -R zabbix:zabbix /usr/local/zabbix_agent/
/usr/local/zabbix_agent/etc/zabbix_agentd.conf	
```
	vim /usr/local/zabbix_agent/etc/zabbix_agentd.conf	
	
	LogFile=/usr/local/zabbix_agent/log/zabbix_agentd.log
	PidFile=/usr/local/zabbix_agent/var/zabbix_agentd.pid
	DebugLevel=3
	Server=127.0.0.1,172.17.0.5			# 配置允许连接的zabbix_server
	ServerActive=127.0.0.1,172.17.0.5	  # 配置允许主动连接的zabbix_server
	StartAgents=8
	Hostname=localhost
	Timeout=30
	UnsafeUserParameters=1
	根据实际情况修改配置文件参数的值
	
	

	
```bash
# 配置服务启动脚本在zabbix_server中已经介绍 agent端只需要zabbix_agentd脚本即可
# /usr/local/zabbix/sbin/zabbix_agentd		# Server端启动zabbix_agentd
/usr/local/zabbix_agent/sbin/zabbix_agentd   	# Agent端启动zabbix_agentd

```
	
	检测 10050 端口是否正常监听
	[root@13262019d57f ~]# netstat -anpt |grep 10050
	tcp     0    0 0.0.0.0:10050       0.0.0.0:*        LISTEN   -
	
	zabbix Agent端自我检测是否可以正常获取监控数据
	/usr/local/zabbix_agent/bin/zabbix_get -s 127.0.0.1 -k agent.ping
	
	zabbix Server端检测是否可以正常获取Agent端的数据
	/usr/local/zabbix/bin/zabbix_get -s 172.17.0.6 -k agent.ping
	
	都返回 1 则正常 这样就可以在web界面上添加server对agent的监控了
	
#### <font color='#DDA0DD'>Windows主机安装Agentd</font>	
> 当前操作在Zabbix Agent2上进行 Zabbix Agent2是一台windows主机

	获取Windwos版zabbix-agent安装包
	zabbix_agents_3.0.0.win.zip
	
	解压文件到任意安装目录
	这里解压到 C:\Program Files\zabix
	
	配置文件的修改方法大体和Linux下相同
	编辑 C:\Program Files\zabix\conf\zabbix_agent.win.conf
	
		Server=127.0.0.1,172.17.0.5
		ServerActive=127.0.0.1,172.17.0.5
		StartAgents=8
		Hostname=windows
		Timeout=30
		UnsafeUserParameters=1
	
	将zabbix_agentd注册为服务
	以管理员身份运行cmd 到zabbix_agentd.exe的目录下 注意选好32位还是64位的exe
	> zabbix_agentd.exe --install -c "C:\Program Files\zabix\conf\zabbix_agent.win.conf"
	因为路径中有空格 所以用双引号扩起 出现installed successfully则安装成功
	
	可以在服务管理界面启动和停止 "zabbix agent" 也可以用net命令控制
	管理员身份运行cmd 控制启动和关闭服务
	> net start "zabbix agent"
	> net stop "zabbix agent"
	
	服务端检测是否正常获取数据
	/usr/local/zabbix/bin/zabbix_get -s 172.17.0.7 -k agent.ping
	返回1 服务端正常获取数据
	
## <font color='#5CACEE'>附录</font>
### <font color='#CDAA7D'>常见故障处理</font>
#### <font color='#DDA0DD'>编译配置报错</font>

	检测依赖包是否正常安装 gcc等编译工具是否正常安装
	
#### <font color='#DDA0DD'>无法打开Web界面</font>

	检查LNMP环境是否正常 以及是否配置了正确的防火墙规则等
	
#### <font color='#DDA0DD'>Web界面出现 Zabbix server is not running ...</font>

	检测是否关闭Selinux 
	setenforce 0
	
	检测zabbix_server的IP地址和端口号在web界面中是否正确配置
	
	如果zabbix_server在本地 看主机是否正常解析localhost域名
	# telnet localhost 10051
	
	如果不能正常解析 
	# vim /var/www/html/zabbix/conf/zabbix.conf.php
	将$ZABBIX_SERVER = 'localhost' 换成 '127.0.0.1' 或者修改host文件
	添加 localhost 到 127.0.0.1 的域名解析
	127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
	
#### <font color='#DDA0DD'>数据库mysql.sock文件无法找到</font>
	如果MySQL服务器和php-fpm服务器在同一台主机 php-fpm可能会通过mysql.sock套接字和MySQL服务通信
	
	如果有如下错误提醒:
	Database error: Error connecting to database [Can't connect to local 
	MySQL server through socket '/var/lib/mysql/mysql.lock']
	
	确保/var/lib/mysql/mysql.lock存在 
	如果实际mysql.sock位置与报错中的位置不符 修改zabbix_server.conf中的DBSocket配置
	DBSocket的值要为真实mysql.sock的绝对路径 然后重启服务
	
#### <font color='#DDA0DD'>禁用guests账号 防止非法访问</font>
	在web管理界面上操作
	管理 >> 用户 >> Guests >> 状态:停用的

### <font color='#CDAA7D'>zabbix总览</font>
	
	zabbix_get              server和agent之间数据获取
		-s                  远程agent的主机名或IP地址
		-p                  远程agent的端口 默认10050
		-I                  如果有多块网卡 本机出去的IP地址
		-k                  获取远程agent数据用的KEY
		
	zabbix_get -s 127.0.0.1 -p 10050 -k agent.ping
		
	zabbix_server           zabbix服务端的核心程序
	zabbix_proxy            abbix代理服务的程序 用于分布式监控proxy模式中
	zabbix_agent            用超级服务方式启动用的程序
	zabbix_agentd           独立进程方式启动用的程序
	zabbix_java_gateway     zabbix的java采集服务端
	zabbix_sender           将采集到的数据定时发送给zabbix_server

	
