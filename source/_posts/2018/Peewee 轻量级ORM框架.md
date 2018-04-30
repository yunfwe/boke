---
title: Peewee 轻量级ORM框架
date: 2018-03-20 10:12:00
categories: 
    - Python
tags:
    - peewee
    - python
photos:
    - /uploads/photos/d83h89da93d.jpg
---

<!-- created: 2018-03-13 10:12:00-->

## 简介
> Peewee 是Python的一款轻量级ORM框架。ORM 是对象-关系映射（Object-Relational Mapping），是一种为了解决面向对象与关系数据库存在的互不匹配的现象的技术。简单的说，ORM是通过使用描述对象和数据库之间映射的元数据，将程序中的对象自动持久化到关系数据库中。ORM 屏蔽了底层数据库操作的细节，使代码几乎不用修改即可支持不同的底层数据库存储。支持Python2.7和3.4以上的版本，内置对SQLite, MySQL和Postgresql的支持。本文通过阅读官方文档翻译而来。
<!-- more -->

## 环境

这里使用 Windows 版的 Python 3.6 和当前最新版的 peewee 3.1.3。

Github地址：https://github.com/coleifer/peewee

## 使用

### 安装

这里使用 pip 命令安装

```
pip install peewee
```

也可以将代码 git 下来 使用 setup 安装

```
git clone https://github.com/coleifer/peewee.git 
cd peewee 
python setup.py install
```

如果底层想要使用 MySQL 数据库需要安装 MySQL 的连接驱动：`pip install pymysql`，并且配置好一个可用的 MySQL 数据库。Postgres 同理，Postgres 的连接驱动：`pip install psycopg2`。


 SQLite 是 Python 标准库的模块，不需要额外安装和配置，也更简单方便，所以这里就以 SQLite 为例。


### 快速体验

先来体验一下 peewee 对数据交互带来的方便吧。

#### 创建数据模型

先理解下什么 ORM ，ORM 是将编程语言中的对象映射为数据库中的数据，比如说 可以将编程语言中的一个类，映射为数据库的一个表，这个类被称为模型类（Model class）。模型类的字段实例（Field instance），映射为数据库中表的字段。模型实例（Model instance）映射为数据库中表的每一行数据。

建议在命令行中执行下面的代码，这样就更直观的知道每一步都发生了什么。

在项目中使用 peewee 时，刚开始最好创建一个模型类，peewee 会自动根据这个模型类在数据库中创建好表。下面看看模型类如何定义的：

```python
from peewee import *

db = SqliteDatabase('people.db')

class Person(Model):
    name = CharField()
    birthday = DateField()
    is_relative = BooleanField()

    class Meta:
        database = db # This model uses the "people.db" database.
```

当我们使用外键建立模型之间的关系时，peewee 可以很容易的做到这一点。

```python
class Pet(Model):
    owner = ForeignKeyField(Person, backref='pets')
    name = CharField()
    animal_type = CharField()

    class Meta:
        database = db # this model uses the "people.db" database
```

现在创建好了模型，让我们连接到数据库。虽然在执行第一条查询的时候会自动连接数据库，但是手动连接可以立即显示数据库连接的任何错误，在使用完后手动关闭数据库连接也是个很好的习惯。

```python
db.connect()
```

首先在数据库中创建存储数据的表。这将创建具有适当列，索引，序列和外键约束的表：

```python
db.create_tables([Person, Pet])
```

可以看到 当前目录 已经出现了一个 `people.db` 的 SQLite 数据库文件。

#### 存储数据

现在开始存储一些数据，我们将使用 `save()` 和 `create()` 方法添加和修改表中的记录

```python
from datetime import date
uncle_bob = Person(name='Bob', birthday=date(1960, 1, 15), is_relative=True)
uncle_bob.save() # bob is now stored in the database. Returns: 1
```

调用 `save()` 将返回修改的行数。也可使用 `create()` 方法来添加一个人：

```python
grandma = Person.create(name='Grandma', birthday=date(1935, 3, 1), is_relative=True)
herb = Person.create(name='Herb', birthday=date(1950, 5, 5), is_relative=False)
```

如果想更改某行，修改模型实例的属性，然后调用 `save()` 方法就会同步到数据库了。

```python
grandma.name = 'Grandma L.'
grandma.save()
```

现在已经在数据库中存储了三个人，让我们给他们一些宠物。奶奶不喜欢宠物，但Herb是宠物的爱好者。

```python
bob_kitty = Pet.create(owner=uncle_bob, name='Kitty', animal_type='cat')
herb_fido = Pet.create(owner=herb, name='Fido', animal_type='dog')
herb_mittens = Pet.create(owner=herb, name='Mittens', animal_type='cat')
herb_mittens_jr = Pet.create(owner=herb, name='Mittens Jr', animal_type='cat')
```

经过漫长的时间后，Mittens 生病死亡了，现在从数据库中删的它。

```python
herb_mittens.delete_instance()
```
`delete_instance()` 方法也会返回删除的行数。

叔叔 Bob 觉得在 Herb 的房间死了太多动物，所以收养了他的狗 Fido。

```python
herb_fido.owner = uncle_bob
herb_fido.save()
bob_fido = herb_fido # rename our variable for clarity
```

#### 检索数据

数据库的优势在于可以通过SQL语句来检索数据，现在看看 peewee 中是如何检索数据的。

##### 查询一条记录

让我们从数据库中获取奶奶的记录，从数据库获取单条记录使用 `select.get()`

```python
grandma = Person.select().where(Person.name == 'Grandma L.').get()
```

我们也可以使用等效的缩写 `Model.get()`

```python
grandma = Person.get(Person.name == 'Grandma L.')
```

##### 列出记录

让我们列出所有人的记录

```python
for person in Person.select():
    print(person.name, person.is_relative)
```

输出：

    Bob True
    Grandma L. True
    Herb False


让我们列出所有的猫和它们主人的名字

```python
query = Pet.select().where(Pet.animal_type == 'cat')
for pet in query:
    print(pet.name, pet.owner.name)
```

输出：

    Kitty Bob
    Mittens Jr Herb

但是这样的查询有一个很大的问题，因为我们想要知道宠物主人的名字，但是 Pet 表中并没有这一个字段，所以当访问 `pet.owner.name` 的时候，peewee 不得不执行额外的查询来检索宠物的所有者，这样的情况通常应该是避免的。

我们应当使用 join 进行关联查询来避免额外的开销

```python
query = (Pet
         .select(Pet, Person)
         .join(Person)
         .where(Pet.animal_type == 'cat'))

for pet in query:
    print(pet.name, pet.owner.name)
```

输出：

    Kitty Bob
    Mittens Jr Herb

让我们看看 Bob 有哪些宠物

```python
for pet in Pet.select().join(Person).where(Person.name == 'Bob'):
    print(pet.name)
```

输出：

    Kitty
    Fido

我们还有一个很酷的方法获取 Bob 的宠物，因为我们已经有一个表示 Bob 的对象，所以我们可以这样做

```python
for pet in Pet.select().where(Pet.owner == uncle_bob):
    print(pet.name)
```

##### 排序

让我们添加一个 `order_by()` 方法来让它们按照字母顺序排序

```python
for pet in Pet.select().where(Pet.owner == uncle_bob).order_by(Pet.name):
    print(pet.name)
```

输出：

    Fido
    Kitty

让我们按照年纪 从年轻到年老列出人们

```python
for person in Person.select().order_by(Person.birthday.desc()):
    print(person.name, person.birthday)
```

输出：

    Bob 1960-01-15
    Herb 1950-05-05
    Grandma L. 1935-03-01

##### 结合过滤器表达式

Peewee 支持任意嵌套的表达式。让我们得到所有生日不一的人

1940之前的人（Grandma） 
1959年之后的人（Bob）

```python
d1940 = date(1940, 1, 1)
d1960 = date(1960, 1, 1)
query = (Person
         .select()
         .where((Person.birthday < d1940) | (Person.birthday > d1960)))

for person in query:
    print(person.name, person.birthday)
```

输出：

    Bob 1960-01-15
    Grandma L. 1935-03-01

现在看看生日在1940年至1960年之间的人

```python
query = (Person
         .select()
         .where(Person.birthday.between(d1940, d1960)))

for person in query:
    print(person.name, person.birthday)
```

输出：

    Herb 1950-05-05

##### 聚合和预获取

现在让我们列出所有的人和他们有多少宠物

```python
for person in Person.select():
    print(person.name, person.pets.count(), 'pets')
```

输出：

    Bob 2 pets
    Grandma L. 0 pets
    Herb 1 pets

在这种情况下，我们又为返回的每个人执行了附加查询！我们可以通过执行join并使用sql函数来聚合结果来避免这种情况。

```python
query = (Person
         .select(Person, fn.COUNT(Pet.id).alias('pet_count'))
         .join(Pet, JOIN.LEFT_OUTER)  # include people without pets.
         .group_by(Person)
         .order_by(Person.name))
for person in query:
    # "pet_count" becomes an attribute on the returned model instances.
    print(person.name, person.pet_count, 'pets')
```

输出：

    Bob 2 pets
    Grandma L. 0 pets
    Herb 1 pets

一只宠物只能有一个主人，所以当进行从 Pet 到 Person 的 join 操作时，它们通常都会进行一次匹配。当我们从 Person 到 Pet 的 join 时，情况会不同，因为一个人可能没有宠物，或者他们可能有几只宠物。因为我们使用关系数据库，当我们从 Person 到 Pet 的 join 时，那么每个宠物都会重复每个拥有多个宠物的人。

它看起来像这样：
```python
query = (Person
         .select(Person, Pet)
         .join(Pet, JOIN.LEFT_OUTER)
         .order_by(Person.name, Pet.name))
for person in query:
    # We need to check if they have a pet instance attached, since not all
    # people have pets.
    if hasattr(person, 'pet'):
        print(person.name, person.pet.name)
    else:
        print(person.name, 'no pets')
```

输出：

    Bob Fido
    Bob Kitty
    Grandma L. no pets
    Herb Mittens Jr


通常这种类型的重复是不可取的，我们可以使用一种 `prefetch()` 的特殊方法

```python
query = Person.select().order_by(Person.name).prefetch(Pet)
for person in query:
    print(person.name)
    for pet in person.pets:
        print('  *', pet.name)
```

##### SQL 函数

这将使用一个 SQL 方法来查找名字以大写或者小写 g 开头的人

```python
expression = fn.Lower(fn.Substr(Person.name, 1, 1)) == 'g'
for person in Person.select().where(expression):
    print(person.name)
```

输出：

    Grandma L.

这只是 peewee 的基础，你还可以使查询更复杂，其他的 SQL 子句也可以使用，比如 `group_by()`, `having()`, `limit()`, `offset()`


#### 关闭数据库

当使用完数据库，我们应该关闭它

```python
db.close()
```

#### 从数据库导出模型

如果已经存在的数据库，可以使用模型生成器 `pwiz` 自动生成 peewee 模型

比如将刚才 `people.db` 的数据再导出模型

```
python -m pwiz -e sqlite people.db
```

如果想导出 MySQL 库的数据 可以这样做：
```
python -m pwiz -e mysql -H localhost -p3306 -uuser -Ppassword  dbname > db.py
```

### 数据库

#### 连接数据库

Peewee 的 `Database` 对象表示到数据库的连接。`Database` 类将实例化打开的数据库连接所需的所有信息，这些信息可用于：

+ 打开和关闭连接
+ 执行查询请求
+ 事务管理
+ 内省表，列，索引和约束
+ 模型整合

peewee支持 SQLite, MySQL 和 Postgres。每个数据库类都提供了一些基本的数据库特定的配置选项

```python
from peewee import *

# SQLite database using WAL journal mode and 64MB cache.
sqlite_db = SqliteDatabase('/path/to/app.db', pragmas=(
    ('journal_mode', 'wal'),
    ('cache_size', -1024 * 64)))

# Connect to a MySQL database on network.
mysql_db = MySQLDatabase('dbname', user='root', password='db_password',
                         host='10.1.0.8', port=3306)

# Connect to a Postgres database.
pg_db = PostgresqlDatabase('my_app', user='postgres', password='secret',
                           host='10.1.0.9', port=5432)
```

Peewee 通过特定的扩展模块提供了对 SQLite 和 Postgres 的高级支持。要使用扩展功能，需要导入特殊数据库模块的 `Database` 类

```python
from playhouse.sqlite_ext import SqliteExtDatabase
# Use SQLite (will register a REGEXP function and set busy timeout to 3s).
db = SqliteExtDatabase('/path/to/app.db', regexp_function=True, timeout=3,
                       pragmas=(('journal_mode', 'wal'),))


from playhouse.postgres_ext import PostgresqlExtDatabase
# Use Postgres (and register hstore extension).
db = PostgresqlExtDatabase('dbname', user='postgres', register_hstore=True)
```

`Database` 类的初始化方法第一个参数是期望的数据库名称，剩下的参数将传给建立连接的底层数据库驱动程序

#### 使用URL连接数据库

`playhouse` 模块提供了一个 `connect()` 函数，它接受数据库URL 并返回一个数据库实例

示例：
```python
import os
from peewee import *
from playhouse.db_url import connect

# Connect to the database URL defined in the environment, falling
# back to a local Sqlite database if no database URL is specified.
db = connect(os.environ.get('DATABASE') or 'sqlite:///default.db')
class BaseModel(Model):
    class Meta:
        database = db
```

数据库URL示例：

+ `sqlite:///my_database.db` 将为 `my_database.db` 在当前目录创建 `SqliteDatabase` 实例。
+ `sqlite:///:memory` 将要创建在内存中的 `SqliteDatabase` 实例。
+ `postgresql://postgres:my_password@localhost:5432/my_database` 将创建一个 `PostgresqlDatabase` 实例。并提供用户名和密码以及连接的主机和端口
+ `mysql://user:passwd@ip:port/my_db` 将为本地 MySQL 数据库创建 `MySQLDatabase` 的实例。

#### 数据库运行时配置

有时候直到运行时数据库配置才会直到，这些值可以从配置文件或者环境变量获取。在这种情况下可以通过将 `None` 指定为数据库名来推迟数据库的初始化。

```python
database = SqliteDatabase(None)  # Un-initialized database.

class SomeModel(Model):
    class Meta:
        database = database
```

这时候尝试连接数据库时会抛出一个异常

```python
database.connect()
Exception: Error, database not properly initialized before opening connection
```

可以手动调用 init() 方法来初始化数据库

```python
database_name = raw_input('What is the name of the db? ')
database.init(database_name, host='localhost', user='postgres')
```

#### 动态定义数据库

为了更好地控制数据库的定义/初始化方式，可以使用 `Proxy()` 方法，`Proxy()` 方法充当占位符，然后在运行时您可以将其交换出一个不同的对象。

```python
database_proxy = Proxy()  # Create a proxy for our db.

class BaseModel(Model):
    class Meta:
        database = database_proxy  # Use proxy for our DB.

class User(BaseModel):
    username = CharField()

# Based on configuration, use a different database.
if app.config['DEBUG']:
    database = SqliteDatabase('local.db')
elif app.config['TESTING']:
    database = SqliteDatabase(':memory:')
else:
    database = PostgresqlDatabase('mega_production_db')

# Configure our proxy to use the db we specified in config.
database_proxy.initialize(database)
```

#### 连接管理

打开一个数据库连接，使用 `Database.connect()` 方法

```python
db = SqliteDatabase(':memory:') 
db.connect()
```

如果尝试再次调用 `connect()` 将会得到一个 `OperationalError`

```python
db.connect()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/charles/pypath/peewee.py", line 2390, in connect
    raise OperationalError('Connection already opened.')
peewee.OperationalError: Connection already opened.
```

为了阻止这个异常，可以添加参数 `reuse_if_open = True`

```python
db.connect()
db.connect(reuse_if_open = True)
```

> 注意：如果数据库连接已打开，则返回 `False`

调用 `close()` 将关闭已打开的数据库连接，再次调用 `close()` 则只会返回 `False`

> 小提示：虽然在使用之前没必要显式连接到数据库，但时最好明确连接。这样如果连接失败，在打开的时候就可以捕获该异常，而不是执行数据库操作的时候。如果在使用数据库连接池。则需要调用 `connect()` 和 `close()` 以确保连接正确回收。

Peewee 使用线程本地存储跟踪连接状态，使得 Peewee 数据库对象可以安全的用于多个线程，每个线程都拥有自己的连接。

数据库对象本身可以使用 `with` 上下文管理器，在上下文管理器中打开一个连接，在连接关闭之前提交，如果错误发生，这种情况下事务将回滚。

```python
db.is_closed()  # True
with db:
    print(db.is_closed())  # False

db.is_closed()  # True
```

`connection_context()` 方法也可用于装饰器

```python
@db.connection_context()
def prepare_database():
    # DB connection will be managed by the decorator, which opens
    # a connection, calls function, and closes upon returning.
    db.create_tables(MODELS)  # Create schema.
    load_fixture_data(db)
```

使用 `Database.connection()` 方法可以获取底层数据库驱动的原始对象。

```python
db.connection()
# <sqlite3.Connection object at 0x0574DF20>
```

#### 连接池

连接池由 `Playhouse` 扩展库中包含的池模块提供

+ 超时后的连接收回
+ 最大连接数上限

```python
from playhouse.pool import PooledMySQLDatabase

db = PooledMySQLDatabase(
    'my_database',
    max_connections=8,
    stale_timeout=300,
    time_out=60,
    user='root', 
    password='db_password',
    host='10.1.0.8')

class BaseModel(Model):
    class Meta:
        database = db
```

以下数据库连接池类可用：

+ `PooledPostgresqlDatabase`
+ `PooledPostgresqlExtDatabase`
+ `PooledMySQLDatabase`
+ `PooledSqliteDatabase`
+ `PooledSqliteExtDatabase`


#### 执行查询

如果想直接执行 SQL 语句，可以使用 `Database.execute_sql()` 方法。

```python
db = SqliteDatabase('my_app.db')
db.connect()

# Example of executing a simple query and ignoring the results.
db.execute_sql("ATTACH DATABASE ':memory:' AS cache;")

# Example of iterating over the results of a query using the cursor.
cursor = db.execute_sql('SELECT * FROM users WHERE status = ?', (ACTIVE,))
for row in cursor.fetchall():
    # Do something with row, which is a tuple containing column data.
    pass
```

#### 事务管理

Peewee 提供了几个用于处理事务的接口，最常用的是 `Database.atomic()` 方法，它也支持嵌套事务。
如果包装块中发生异常，则当前事务将回滚，否则将提交。

而在 `atomic()` 上下文管理器包装的代码块内部时，可以通过调用 `Transaction.rollback()` 或者 `Transaction.commit()` 显性的回滚或提交事务。

```python
with db.atomic() as transaction:  # Opens new transaction.
    try:
        save_some_objects()
    except ErrorSavingData:
        # Because this block of code is wrapped with "atomic", a
        # new transaction will begin automatically after the call
        # to rollback().
        transaction.rollback()
        error_saving = True

    create_report(error_saving=error_saving)
    # Note: no need to call commit. Since this marks the end of the
    # wrapped block of code, the `atomic` context manager will
    # automatically call commit for us.
```

`atomic()` 不仅可以用作上下文管理器，还可用做装饰器

用作装饰器：
```python
db = SqliteDatabase(':memory:')
with db.atomic() as txn:
    # This is the outer-most level, so this block corresponds to
    # a transaction.
    User.create(username='charlie')
    with db.atomic() as nested_txn:
        # This block corresponds to a savepoint.
        User.create(username='huey')
        # This will roll back the above create() query.
        nested_txn.rollback()
    User.create(username='mickey')
# When the block ends, the transaction is committed (assuming no error
# occurs). At that point there will be two users, "charlie" and "mickey".
```

还可使用 `atomic()` 方法来获取或创建数据：
```python
try:
    with db.atomic():
        user = User.create(username=username)
    return 'Success'
except peewee.IntegrityError:
    return 'Failure: %s is already in use.' % username
```

用作装饰器：
```python
@db.atomic()
def create_user(username):
    # This statement will run in a transaction. If the caller is already
    # running in an `atomic` block, then a savepoint will be used instead.
    return User.create(username=username)
create_user('charlie')
```

保存点：

可以像显式创建事务一样，也可以使用 `savepoint()` 方法显式创建保存点。保存点必须发生在一个事务中，但可以任意嵌套。

```python
with db.transaction() as txn:
    with db.savepoint() as sp:
        User.create(username='mickey')

    with db.savepoint() as sp2:
        User.create(username='zaizee')
        sp2.rollback()  # "zaizee" will not be saved, but "mickey" will be.
```

如果手动提交或回滚保存点，则不会自动创建新的保存点。这与事务的行为不同，它会在手动提交/回滚之后自动打开新的事务。


#### 日志记录

所有查询都使用标准库 `logging` 模块记录到 peewee 命名空间。查询使用 `DEBUG` 级别。
如果你对查询有兴趣，你可以简单地注册一个处理程序。

```python
# Print all queries to stderr.
import logging
logger = logging.getLogger('peewee')
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())
```


### 模型和字段

模型类、字段实例和模型实例都映射到了数据库

|项|对应于|
|-|-|
|模型类|数据库|
|字段实例|表中的列|
|模型实例|表中的行|

下面的例子演示了定义数据库连接和模型类的方法

```python
from peewee import *

# 创建一个数据库的实例
db = SqliteDatabase('my_app.db')

# 创建一个指定数据库的基础模型类
class BaseModel(Model):
    class Meta:
        database = db

# 定义模型类
class User(BaseModel):
    username = CharField(unique=True)

# 定义模型类
class Tweet(BaseModel):
    user = ForeignKeyField(User, backref='tweets')
    message = TextField()
    created_date = DateTimeField(default=datetime.datetime.now)
    is_published = BooleanField(default=True)
```

#### 字段

字段类用于描述模型属性到数据库字段的映射，每一个字段类型都有一个相应的 SQL 存储类型，如 `varchar`, `int`。并且python的数据类型和 SQL 存储类型之间的转换是透明的。

在创建模型类时，字段被定义为类属性。有一种特殊类型的字段 `ForeignKeyField`，可以以更直观的方式表示模型之间的外键关系。

```python
class Message(Model):
    user = ForeignKeyField(User, backref='messages')
    body = TextField()
    send_date = DateTimeField()
```

这允许你编写如下的代码：

```python
print(some_message.user.username)
for message in some_user.messages:
    print(message.body)
```

##### 字段类型表

|字段类型|	Sqlite	|Postgresql	|MySQL|
|-|-|-|-|
|IntegerField	|integer|	integer	|integer|
|BigIntegerField|	integer|	bigint|	bigint|
|SmallIntegerField|	integer|	smallint|	smallint|
|AutoField|	integer	|serial|	integer|
|FloatField|	real|	real|	real|
|DoubleField|	real|	double precision	|double precision|
|DecimalField|decimal|	numeric|	numeric|
|CharField|	varchar	|varchar|	varchar|
|FixedCharField|	char|	char|	char|
|TextField|	text	|text	|longtext|
|BlobField|	blob|	bytea|	blob|
|BitField|	integer	|bigint|	bigint|
|BigBitField|	blob|	bytea|	blob|
|UUIDField|	text|	uuid|	varchar(40)|
|DateTimeField|	datetime|	timestamp	|datetime|
|DateField|	date	|date|	date|
|TimeField	|time|	time|	time|
|TimestampField|	integer|	integer|	integer|
|IPField|	integer|	bigint|	bigint|
|BooleanField	|integer|	boolean|	bool|
|BareField|	untyped|	不支持|	不支持|
|ForeignKeyField|	integer	|integer|	integer|

##### 字段初始参数

所有字段类型接受的参数与默认值

+ `null = False` – 布尔值，表示是否允许存储空值
+ `index = False` – 布尔值，表示是否在此列上创建索引
+ `unique = False` – 布尔值，表示是否在此列上创建唯一索引
+ `column_name = None` – 如果和属性名不同，底层的数据库字段使用这个值
+ `default = None` – 字段默认值，可以是一个函数，将使用函数返回的值
+ `primary_key = False` – 布尔值，此字段是否是主键
+ `constraints = None` - 一个或多个约束的列表 例如：`[Check('price > 0')]`
+ `sequence = None` – 序列填充字段（如果后端数据库支持）
+ `collation = None` – 用于排序字段/索引的排序规则
+ `unindexed = False` – 表示虚拟表上的字段应该是未索引的（仅用于sqlite）
+ `choices = None` – 一个可选的迭代器，包含两元数组`（value, display）`
+ `help_text = None` – 表示字段的帮助文本
+ `verbose_name = None` – 表示用户友好的字段名

一些字段的特殊参数

|字段类型|	特殊参数|
|-|-|
|CharField|	max_length|
|FixedCharField	|max_length|
|DateTimeField|	formats|
|DateField|	formats|
|TimeField|	formats|
|TimestampField	|resolution, utc|
|DecimalField|	max_digits, decimal_places, auto_round, rounding|
|ForeignKeyField	|model, field, backref, on_delete, on_update, extra|
|BareField|	coerce|


##### 字段默认值

创建对象时，peewee 可以为字段提供默认值，例如将字段的默认值`null`设置为`0`
```python
class Message(Model):
    context = TextField()
    read_count = IntegerField(default=0)
```

如果想提供一个动态值，比如当前时间，可以传入一个函数

```python
class Message(Model):
    context = TextField()
    timestamp = DateTimeField(default=datetime.datetime.now)
```

数据库还可以提供字段的默认值。虽然 peewee 没有明确提供设置服务器端默认值的 API，但您可以使用 `constraints` 参数来指定服务器默认值：

```python
class Message(Model):
    context = TextField()
    timestamp = DateTimeField(constraints=[SQL('DEFAULT CURRENT_TIMESTAMP')])
```

##### 外键字段

`foreignkeyfield` 是一种特殊的字段类型，允许一个模型引用另一个模型。通常外键将包含与其相关的模型的主键（但您可以通过指定一个字段来指定特定的列）。

可以通过追加 `_id` 的外键字段名称来访问原始外键值

```python
tweets = Tweet.select()
for tweet in tweets:
    # Instead of "tweet.user", we will just get the raw ID value stored
    # in the column.
    print(tweet.user_id, tweet.message)
```

`ForeignKeyField` 允许将反向引用属性绑定到目标模型。隐含地，这个属性将被命名为 `classname_set`，其中 classname 是类的小写名称，但可以通过参数覆盖 backref：

```python
class Message(Model):
    from_user = ForeignKeyField(User)
    to_user = ForeignKeyField(User, backref='received_messages')
    text = TextField()

for message in some_user.message_set:
    # We are iterating over all Messages whose from_user is some_user.
    print(message)

for message in some_user.received_messages:
    # We are iterating over all Messages whose to_user is some_user
    print(message)
```

##### 日期字段

`DateField` `TimeField` 和 `DateTimeField` 字段

`DateField` 包含 `year` `month` `day`
`TimeField` 包含 `hour` `minute` `second`
`DateTimeField` 包含以上所有

#### 创建模型表

为了开始使用模型，它需要打开一个到数据库的连接并创建表。Peewee 将运行必要的 `CREATE TABLE` 查询，另外创建约束和索引。

```python
# Connect to our database.
db.connect()

# Create the tables.
db.create_tables([User, Tweet])
```

默认情况下，Peewee 将确定表是否已经存在，并有条件地创建它们。如果你想禁用它，指定 `safe=False`。

#### 模型选项和表格元数据

为了不污染模型空间，模型的配置被放置在名为 `Meta` 的特殊类中

```python
from peewee import *
contacts_db = SqliteDatabase('contacts.db')
class Person(Model):
    name = CharField()
    class Meta:
        database = contacts_db
```

模型一旦定义，访问元数据应该访问 `ModelClass._meta`

```python
Person._meta.fields
Person._meta.primary_key
Person._meta.database
```

有几个选项可以指定为Meta属性。虽然大多数选项都是可继承的，但有些选项是特定于表的，不会被子类继承。

|选项	|含义|	是否可继承|
|-|-|-|
|database	|模型的数据库	|是|
|table_name|	用于存储数据的表的名称	|否|
|table_function	|函数动态生成表名	|是|
|indexes|	要索引的字段列表|	是|
|primary_key	|一个 `CompositeKey` 实例|	是|
|constraints|	表约束列表	|是|
|schema	|模型的数据库概要|	是|
|only_save_dirty|	当调用 `model.save()` 时，只保存脏字段	|是|
|options	|用于创建表扩展选项的字典|	是|
|table_alias	|用于查询中的表的别名	|否|
|depends_on|	此表依赖于另一个表的创建	|否|
|without_rowid|	指示表不应该有rowid（仅限SQLite）	|否|

不可被继承的例子

    >>> db = SqliteDatabase(':memory:')
    >>> class ModelOne(Model):
    ...     class Meta:
    ...         database = db
    ...         table_name = 'model_one_tbl'
    ...
    >>> class ModelTwo(ModelOne):
    ...     pass
    ...
    >>> ModelOne._meta.database is ModelTwo._meta.database
    True
    >>> ModelOne._meta.table_name == ModelTwo._meta.table_name
    False

自定义主键或者没有主键可以用 `CompositeKey` 或者将主键设置为 `False`

```python
class BlogToTag(Model):
    """A simple "through" table for many-to-many relationship."""
    blog = ForeignKeyField(Blog)
    tag = ForeignKeyField(Tag)
    class Meta:
        primary_key = CompositeKey('blog', 'tag')

class NoPrimaryKey(Model):
    data = IntegerField()
    class Meta:
        primary_key = False
```

#### 索引和约束

Peewee 可以在单列或多列上创建索引，可以包含 `UNIQUE` 约束。Peewee 还在模型和字段上支持用户定义的约束。

##### 单列索引和约束

单列索引是使用字段初始化参数定义的。以下示例在用户名字段上添加唯一索引，并在电子邮件字段上添加常规索引：

```python
class  User （Model ）：
    username  =  CharField （unique = True ）
    email  =  CharField （index = True ）
```

要在列上添加用户定义的约束，可以使用constraints参数传递它 。您可能希望将默认值指定为架构的一部分，或者添加一个 CHECK 约束，例如：

```python
class Product(Model):
    name = CharField(unique=True)
    price = DecimalField(constraints=[Check('price < 10000')])
    created = DateTimeField(
        constraints=[SQL("DEFAULT (datetime('now'))")])
```

##### 多列索引

多列索引可以使用嵌套元组定义为元属性。每个数据库索引都是一个两个元素的元组，第一部分是字段名称的元组，第二部分是布尔值，指示索引是否应该是唯一的。

```python
class Transaction(Model):
    from_acct = CharField()
    to_acct = CharField()
    amount = DecimalField()
    date = DateTimeField()

    class Meta:
        indexes = (
            # create a unique on from/to/date
            (('from_acct', 'to_acct', 'date'), True),
            # create a non-unique on from/to
            (('from_acct', 'to_acct'), False),
        )
```

##### 创建高级索引

Peewee 支持更结构化的 API，以便使用该 `Model.add_index()` 方法在模型上声明索引，或直接使用 `ModelIndexhelper` 类。

```python
class Article(Model):
    name = TextField()
    timestamp = TimestampField()
    status = IntegerField()
    flags = IntegerField()
# Add an index on "name" and "timestamp" columns.
Article.add_index(Article.name, Article.timestamp)
# Add a partial index on name and timestamp where status = 1.
Article.add_index(Article.name, Article.timestamp,
                  where=(Article.status == 1))
# Create a unique index on timestamp desc, status & 4.
idx = Article.index(
    Article.timestamp.desc(),
    Article.flags.bin_and(4),
    unique=True)
Article.add_index(idx)
```

##### 表约束

Peewee允许您为您添加任意约束Model，这将在创建模式时成为表定义的一部分。

例如，假设您有一个具有两列组合主键的人员表格，即人员的姓名。您希望将另一个表与人员表相关联，为此，您需要定义一个外键约束：

```python
class Person(Model):
    first = CharField()
    last = CharField()
    class Meta:
        primary_key = CompositeKey('first', 'last')

class Pet(Model):
    owner_first = CharField()
    owner_last = CharField()
    pet_name = CharField()
    class Meta:
        constraints = [SQL('FOREIGN KEY(owner_first, owner_last) '
                           'REFERENCES person(first, last)')]
```

也可以使用 `CHECK` 在表级别实施约束：

```python
class Product(Model):
    name = CharField(unique=True)
    price = DecimalField()
    class Meta:
        constraints = [Check('price < 10000')]
```

#### 其他主键

##### 非整数主键

如果想使用非整数主键，可以在创建字段时指定 `primary_key=True`。当希望使用非自动增量主键为模型创建新实例时，您需要确保 `save()` 指定 `force_insert=True`。

```python
from peewee import *
class UUIDModel(Model):
    id = UUIDField(primary_key=True)
```

自动递增ID在新行插入数据库时​​会自动生成，当调用 `save()` 时 peewee 会根据主键值的存在性来确定是否执行 `insert` 和 `update`。由于在上一个例子中，数据库驱动程序不会生成新的ID，所以需要手动指定它。在第一次调用 `save()` 时，传入：`force_insert = True`

```python
import uuid
# This works because .create() will specify `force_insert=True`.
obj1 = UUIDModel.create(id=uuid.uuid4())
# This will not work, however. Peewee will attempt to do an update:
obj2 = UUIDModel(id=uuid.uuid4())
obj2.save() # WRONG
obj2.save(force_insert=True) # CORRECT
# Once the object has been created, you can call save() normally.
obj2.save()
```

##### 复合主键

Peewee 对复合键有基本的支持。为了使用组合键，必须将 `primary_key` 模型选项的属性设置为一个 `CompositeKey` 实例：

```python
class BlogToTag(Model):
    """A simple "through" table for many-to-many relationship."""
    blog = ForeignKeyField(Blog)
    tag = ForeignKeyField(Tag)
    class Meta:
        primary_key = CompositeKey('blog', 'tag')
```

###### 手动指定主键

有时不希望数据库自动为主键生成值，例如在批量加载关系数据时。要一次性处理这个问题，您可以简单地告诉 peewee `auto_increment` 在导入期间关闭：

```python
data = load_user_csv() # load up a bunch of data

User._meta.auto_increment = False # turn off auto incrementing IDs
with db.transaction():
    for row in data:
        u = User(id=row[0], username=row[1])
        u.save(force_insert=True) # <-- force peewee to insert row

User._meta.auto_increment = True
```

如果想要始终控制主键，则不要使用 `PrimaryKeyField` 字段类型，而要使用正常 `IntegerField`（或其他列类型）：

    class User(BaseModel):
        id = IntegerField(primary_key=True)
        username = CharField()

    >>> u = User.create(id=999, username='somebody')
    >>> u.id
    999
    >>> User.get(User.username == 'somebody').id
    999


##### 没有主键的模型

如果你想创建一个没有主键的模型，你可以在内部类 `Meta` 中指定 ：`primary_key = False`

```python
class MyData(BaseModel):
    timestamp = DateTimeField()
    value = IntegerField()

    class Meta:
        primary_key = False
```

### 更改和查询

本章将介绍在关系型数据库上执行 CRUD 操作

+ `Model.create()`，用于执行 INSERT 请求。
+ `Model.save()` 和 `Model.update()` 执行 UPDATE 请求。
+ `Model.delete_instance()` 和 `Model.delete()` 执行 DELETE 请求。
+ `Model.select()`，用于执行 SELECT 请求。

#### 创建一条新记录

可以使用 `Model.create()` 创建一个新的模型实例。此方法接受关键字参数，其中键与模型字段的名称相对应。返回一个新实例并将一行添加到表中。

```python
User.create(username='Charlie')
```

这将插入一行新数据到数据库中，主键将自动检索并存储在模型实例中。或者还可以先创建模型实例，然后调用 `save()`

    >>> user = User(username='Charlie')
    >>> user.save()  # save() returns the number of rows modified.
    1
    >>> user.id
    1
    >>> huey = User()
    >>> huey.username = 'Huey'
    >>> huey.save()
    1
    >>> huey.id
    2

当模型有外键时，可以在创建新记录时直接将模型实例分配给外键字段。

    >>> tweet = Tweet.create(user=huey, message='Hello!')

也可以使用相关对象主键的值：

    >>> tweet = Tweet.create(user=2, message='Hello again!')

如果只是想插入数据而不需要创建模型实例，则可以使用 `Model.insert()`：

    >>> User.insert(username='Mickey').execute()
    3

#### 批量插入

可以通过调用 `insert_many()` 高效率的插入大量数据

```python
data_source = [
    {'field1': 'val1-1', 'field2': 'val1-2'},
    {'field1': 'val2-1', 'field2': 'val2-2'},
    # ...
]

# 最快的方法
MyModel.insert_many(data_source).execute()

# 也可以使用元组 并指定插入的字段
fields = [MyModel.field1, MyModel.field2]
data = [('val1-1', 'val1-2'),
        ('val2-1', 'val2-2'),
        ('val3-1', 'val3-2')]
MyModel.insert_many(data, fields=fields)

# 也可以包含在一个事务中
with db.atomic():
    MyModel.insert_many(data, fields=fields)
```

如果要批量加载的数据存储在另一个表中，则还可以创建其源为 SELECT 请求的 INSERT 请求。使用 方法：`Model.insert_from()`

```python
query = (TweetArchive
         .insert_from(
             Tweet.select(Tweet.user, Tweet.message),
             fields=[Tweet.user, Tweet.message])
         .execute())
```

#### 更新数据

一旦模型具有主键，后续的任何 `save()` 都将导致 UPDATE 而不是 INSERT，该模型的主键不会改变。

    >>> user.save()
    1
    >>> user.id
    2
    >>> user.username = 'Tom'
    >>> user.save()
    1
    >>> user.id
    2

如果想更新多条记录，使用 `Model.update()`

    >>> today = datetime.today()
    >>> query = Tweet.update(is_published=True).where(Tweet.creation_date < today)
    >>> query.execute()  # Returns the number of rows that were updated.
    4

#### 原子更新

peewee 允许执行原子更新。假设需要更新计数器，天真的方法是这样写的：

    >>> for stat in Stat.select().where(Stat.url == request.url):
    ...     stat.counter += 1
    ...     stat.save()

这样速度不仅特别慢，如果多进程同时更新计数器，还会受到竞争条件的影响。可以使用 `update()` 自动更新计数器。

```python
query = Stat.update(counter=Stat.counter + 1).where(Stat.url == request.url)
query.execute()
```

还可以使这些更新语句更复杂些。让我们给所有员工一个奖金，等于他们以前的奖金加上他们工资的10％：

```python
query = Employee.update(bonus=(Employee.bonus + (Employee.salary * .1)))
query.execute()
```

还可以使用子查询来更新值：

```python
subquery = Tweet.select(fn.COUNT(Tweet.id)).where(Tweet.user == User.id)
update = User.update(num_tweets=subquery)
update.execute()
```


#### 删除记录

要删除单个模型实例，可以使用 `Model.delete_instance()`，`delete_instance()` 方法将删除给定的模型实例，并可以递归删除任何依赖对象（指定 `recursive=True`）

```python
user = User.get(User.id == 1)
user.delete_instance()
```

要删除多行，可以使用删除命令：

```python
query = Tweet.delete().where(Tweet.creation_date < one_year_ago)
query.execute()
```

#### 查询一条记录

可以使用 `Model.get()` 方法来检索查询匹配到的单个实例。对于主键查找，还可以使用快捷方式 `Model.get_by_id()`。如果没有查询到结果，将返回一个异常

    >>> User.get(User.id == 1)
    <__main__.User object at 0x25294d0>

    >>> User.get_by_id(1)  # Same as above.
    <__main__.User object at 0x252df10>

    >>> User[1]  # Also same as above.
    <__main__.User object at 0x252dd10>

    >>> User.get(User.id == 1).username
    u'Charlie'

    >>> User.get(User.username == 'Charlie')
    <__main__.User object at 0x2529410>

    >>> User.get(User.username == 'nobody')
    UserDoesNotExist: instance matching query does not exist:
    SQL: SELECT t1."id", t1."username" FROM "user" AS t1 WHERE t1."username" = ?
    PARAMS: ['nobody']

对于更高级的查询，可以使用 `SelectBase.get()`。

    >>> (Tweet
    ...  .select()
    ...  .join(User)
    ...  .where(User.username == 'charlie')
    ...  .order_by(Tweet.created_date.desc())
    ...  .get())
    <__main__.Tweet object at 0x2623410>


#### 获取或创建

Peewee 有一个用于执行获取或者创建类型操作的方法 `Model.get_or_create()`，它首先尝试检索匹配的行，否则将创建一个新行

```python
user, created = User.get_or_create(username=username)
```

#### 选择多行

可以使用 `Model.select()` 从表中检索多行，peewee 允许迭代以及检索和切片这些行

    >>> query = User.select()
    >>> [user.username for user in query]
    ['Charlie', 'Huey', 'Peewee']

    >>> query[1]
    <__main__.User at 0x7f83e80f5550>

    >>> query[1].username
    'Huey'

    >>> query[:2]
    [<__main__.User at 0x7f83e80f53a8>, <__main__.User at 0x7f83e80f5550>]

除了返回模型实例之外，选择查询还可以返回字典，元组和命名集。

    >>> query = User.select().dicts()
    >>> for row in query:
    ...     print(row)

    {'id': 1, 'username': 'Charlie'}
    {'id': 2, 'username': 'Huey'}
    {'id': 3, 'username': 'Peewee'}


#### 过滤

可以使用普通的Python操作符来过滤特定的记录。 Peewee 支持多种查询操作符。

    >>> user = User.get(User.username == 'Charlie')
    >>> for tweet in Tweet.select().where(Tweet.user == user, Tweet.is_published == True):
    ...     print(tweet.user.username, '->', tweet.message)
    ...
    Charlie -> hello world
    Charlie -> this is fun

    >>> for tweet in Tweet.select().where(Tweet.created_date < datetime.datetime(2011, 1, 1)):
    ...     print(tweet.message, tweet.created_date)
    ...
    Really old tweet 2010-01-01 00:00:00


还可以使用 join 后过滤

    >>> for tweet in Tweet.select().join(User).where(User.username == 'Charlie'):
    ...     print(tweet.message)
    hello world
    this is fun
    look at this picture of my food

如果想表达复杂的逻辑，还可以使用 `|` 或者 `&` 操作符

    >>> Tweet.select().join(User).where(
    ...     (User.username == 'Charlie') |
    ...     (User.username == 'Peewee Herman'))


#### 排序

要按顺序返回行，要使用 `order_by()` 方法

    >>> for t in Tweet.select().order_by(Tweet.created_date):
    ...     print(t.pub_date)
    ...
    2010-01-01 00:00:00
    2011-06-07 14:08:48
    2011-06-07 14:12:57

    >>> for t in Tweet.select().order_by(Tweet.created_date.desc()):
    ...     print(t.pub_date)
    ...
    2011-06-07 14:12:57
    2011-06-07 14:08:48
    2010-01-01 00:00:00


还可以使用 `+` 和 `-` 前缀来指示排序：

```python
# The following queries are equivalent:
Tweet.select().order_by(Tweet.created_date.desc())

Tweet.select().order_by(-Tweet.created_date)  # Note the "-" prefix.

# Similarly you can use "+" to indicate ascending order, though ascending
# is the default when no ordering is otherwise specified.
User.select().order_by(+User.username)
```

还可以使用 join 连接后排序

```python
query = (Tweet
         .select()
         .join(User)
         .order_by(User.username, Tweet.created_date.desc()))
```

当对计算值进行排序时，可以包含必需的 sql 表达式，或者分配给该值别名。

```python
# Let's start with our base query. We want to get all usernames and the number of
# tweets they've made. We wish to sort this list from users with most tweets to
# users with fewest tweets.
query = (User
         .select(User.username, fn.COUNT(Tweet.id).alias('num_tweets'))
         .join(Tweet, JOIN.LEFT_OUTER)
         .group_by(User.username))
```

还可以在 select 中使用 `COUNT` 表达式来排序

```python
query = (User
         .select(User.username, fn.COUNT(Tweet.id).alias('num_tweets'))
         .join(Tweet, JOIN.LEFT_OUTER)
         .group_by(User.username)
         .order_by(fn.COUNT(Tweet.id).desc()))
```

#### 获取随机记录

偶尔可能想从数据库中提取一条随机记录，可以通过 `random` 或 `rand`（取决于你的数据库）来完成这个任务：

```python
# Postgresql and Sqlite use the Random function
# Pick 5 lucky winners:
LotteryNumber.select().order_by(fn.Random()).limit(5)

# MySQL uses Rand:
# Pick 5 lucky winners:
LotterNumber.select().order_by(fn.Rand()).limit(5)
```

#### 分页

`paginate()` 方法可以轻松对记录进行分页，`paginate()` 方法需要两个参数，`page_number`, 和 `items_per_page`。

    >>> for tweet in Tweet.select().order_by(Tweet.id).paginate(2, 10):
    ...     print(tweet.message)
    ...
    tweet 10
    tweet 11
    tweet 12
    tweet 13
    tweet 14
    tweet 15
    tweet 16
    tweet 17
    tweet 18
    tweet 19

#### 计数

可以计算任何查询中选择的行数

```
>>> Tweet.select().count()
100
>>> Tweet.select().where(Tweet.id > 50).count()
50
```


#### 汇总

假设你有一些用户，并希望得到他们的列表以及每个人的推文数量。

```python
query = (User
         .select(User, fn.Count(Tweet.id).alias('count'))
         .join(Tweet, JOIN.LEFT_OUTER)
         .group_by(User))
```

#### 返回标量值

可以通过调用 `Query.scalar()` 来返回标量值：

    >>> PageView.select(fn.Count(fn.Distinct(PageView.url))).scalar()
    100

您可以通过传递 `as_tuple=true` 来返回多个标量值：

    >>> Employee.select(
    ...     fn.Min(Employee.salary), fn.Max(Employee.salary)
    ... ).scalar(as_tuple=True)
    (30000, 50000)

#### SQL函数，子查询和原始表达式

要使用特殊的 SQL 函数，需要使用 `fn` 的对象来构造请求
假设要获取所有以字母 `a` 开头的用户列表：

```python
# Select the user's id, username and the first letter of their username, lower-cased
first_letter = fn.LOWER(fn.SUBSTR(User.username, 1, 1))
query = User.select(User, first_letter.alias('first_letter'))

# Alternatively we could select only users whose username begins with 'a'
a_users = User.select().where(first_letter == 'a')

for user in a_users:
    print(user.username)
```

有时候想传入一些任意的 SQL ，可以使用特殊的 SQL 类来做到这点

```python
# We'll query the user table and annotate it with a count of tweets for
# the given user
query = (User
         .select(User, fn.Count(Tweet.id).alias('ct'))
         .join(Tweet)
         .group_by(User))

# Now we will order by the count, which was aliased to "ct"
query = query.order_by(SQL('ct'))

# You could, of course, also write this as:
query = query.order_by(fn.COUNT(Tweet.id))
```

有两种方法可以用 peewee 执行手动编写的 SQL 语句：

1. `Database.execute_sql()` 用户执行任意类型的查询
2. 用于执行 SELECT 查询和返回模型实例的 `RawQuery`

#### 安全和SQL注入

默认情况下，peewee会参数化查询，所以用户传入的参数将被转义。这条规则唯一的例外是，如果你正在编写一个原始的 sql 查询或传入一个可能包含不可信数据的 sql 对象。为了减轻这一点，请确保任何用户定义的数据都作为查询参数传入，而不是实际的 sql 查询的一部分：

```python
# Bad! DO NOT DO THIS!
query = MyModel.raw('SELECT * FROM my_table WHERE data = %s' % (user_data,))

# Good. `user_data` will be treated as a parameter to the query.
query = MyModel.raw('SELECT * FROM my_table WHERE data = %s', user_data)

# Bad! DO NOT DO THIS!
query = MyModel.select().where(SQL('Some SQL expression %s' % user_data))

# Good. `user_data` will be treated as a parameter.
query = MyModel.select().where(SQL('Some SQL expression %s', user_data))
```

#### 返回元组/字典/名称元组

有时候不需要创建模型实例的开销，只需要数据即可，可以使用：

+ dicts()
+ namedtuples()
+ tuples()
+ objects() – 接受用行元组调用的任意构造函数。

```python
stats = (Stat
         .select(Stat.url, fn.Count(Stat.url))
         .group_by(Stat.url)
         .tuples())

# iterate over a list of 2-tuples containing the url and count
for stat_url, stat_count in stats:
    print(stat_url, stat_count)
```

同样也可以使用 `dicts()` 将数据作为字典返回

```python
stats = (Stat
         .select(Stat.url, fn.Count(Stat.url).alias('ct'))
         .group_by(Stat.url)
         .dicts())

# iterate over a list of 2-tuples containing the url and count
for stat in stats:
    print(stat['url'], stat['ct'])
```

### 查询操作符

Peewee 支持以下类型的比较：

|对照	|含义|
|-|-|
|==|	x 等于 y|
|<	|x 小于 y|
|<=	|x 小于或等于 y|
|\>	|x 大于 y|
|\>=|	x 大于或等于 y|
|!=	|x 不等于 y|
|<<	|x IN y, y 是一个列表或查询|
|\>>|	x IS y, 当 y 是 None 或者 NULL|
|%|	x LIKE y, 当 y 可能包含通配符|
|**|	x ILIKE y, 当 y 可能包含通配符|
|^	|x XOR y|
|~|	非 (例如：NOT x)|

还有一些查询可以用方法：

<table border="1"><colgroup><col width="32%"><col width="68%"></colgroup><thead valign="bottom"><tr><th>方法</th><th>含义</th></tr></thead><tbody valign="top"><tr><td><code><span>.contains(substr)</span></code></td><td>通配符搜索子字符串</td></tr><tr><td><code><span>.startswith(prefix)</span></code></td><td>搜索以<code>prefix</code>为前缀的值</td></tr><tr><td><code><span>.endswith(suffix)</span></code></td><td>搜索以<code>suffix</code>为后缀的值</td></tr><tr><td><code><span>.between(low,</span><span>high)</span></code></td><td>搜索<code><span>low</span></code>和 <code><span>high</span></code>之间的值</td></tr><tr><td><code><span>.regexp(exp)</span></code></td><td>正则表达式匹配</td></tr><tr><td><code><span>.bin_and(value)</span></code></td><td>二进制 AND</td></tr><tr><td><code><span>.bin_or(value)</span></code></td><td>二进制 OR</td></tr><tr><td><code><span>.in_(value)</span></code></td><td>值是否属于</td></tr><tr><td><code><span>.not_in(value)</span></code></td><td>值是否不属于</td></tr><tr><td><code><span>.is_null(is_null)</span></code></td><td>是 NULL 或者不是 NULL </td></tr><tr><td><code><span>.concat(other)</span></code></td><td>连接两个字符串</td></tr><tr><td><code><span>.distinct()</span></code></td><td>标记不同的选择列</td></tr></tbody></table>

要使用逻辑运算符来组合子句，使用：

<table border="1"><colgroup><col width="18%"><col width="22%"><col width="60%"></colgroup><thead valign="bottom"><tr><th>操作符</th><th>意思</th><th>示例</th></tr></thead><tbody valign="top"><tr><td><code><span>&amp;</span></code></td><td>AND</td><td><code><span>(User.is_active</span><span>==</span><span>True)</span><span>&amp;</span><span>(User.is_admin</span><span>==</span><span>True)</span></code></td></tr><tr><td><code><span>|</span></code></td><td>OR</td><td><code><span>(User.is_admin)</span><span>|</span><span>(User.is_superuser)</span></code></td></tr><tr><td><code><span>~</span></code></td><td>NOT</td><td><code><span>~(User.username</span><span>&lt;&lt;</span><span>['foo',</span><span>'bar',</span><span>'baz'])</span></code></td></tr></tbody></table>

如何使用查询操作符的示例：

```python
# Find the user whose username is "charlie".
User.select().where(User.username == 'charlie')

# Find the users whose username is in [charlie, huey, mickey]
User.select().where(User.username << ['charlie', 'huey', 'mickey'])

Employee.select().where(Employee.salary.between(50000, 60000))

Employee.select().where(Employee.name.startswith('C'))

Blog.select().where(Blog.title.contains(search_string))
```

这里是如何组合表达式的示例：

```python
# Find any users who are active administrations.
User.select().where(
  (User.is_admin == True) &
  (User.is_active == True))

# Find any users who are either administrators or super-users.
User.select().where(
  (User.is_admin == True) |
  (User.is_superuser == True))

# Find any Tweets by users who are not admins (NOT IN).
admins = User.select().where(User.is_admin == True)
non_admin_tweets = Tweet.select().where(~(Tweet.user << admins))

# Find any users who are not my friends (strangers).
friends = User.select().where(User.username.in_(['charlie', 'huey', 'mickey']))
strangers = User.select().where(User.id.not_in(friends))
```

请记住：

+ 使用 `.in_()` 和 `.not_in()` 替换 `in` 和 `not in`
+ 使用 `&` 替换 `and`
+ 使用 `|` 替换 `or`
+ 使用 `~` 替换 `not`
+ 使用 `.is_null()` 替换 `is None` 或者 `== None`
+ 在使用逻辑运算符时，不要忘记使用圆括号包含比较结果

#### 用户自定义操作符

如果发现自己需要的操作符不在上表中，可以非常容易的自定义操作符，比如取模运算

这里是如何在 SQLite 中添加取模运算的支持：

```python
from peewee import *
from peewee import Expression # the building block for expressions

def mod(lhs, rhs):
    return Expression(lhs, '%', rhs)
```

现在可以将自定义运算符来构建更丰富的查询

```python
# Users with even ids.
User.select().where(mod(User.id, 2) == 0)
```

## 附录

Peewee 的详细使用说明请翻阅 [Peewee官方文档](http://docs.peewee-orm.com/en/latest/index.html)