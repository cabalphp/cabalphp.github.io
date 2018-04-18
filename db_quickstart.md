# 数据库入门

## 概述

要使用 Cabal-DB 需要先修改 `usr/boot.php`，取消 `Boot` 类中的 `use Cabal\DB\Boot\HasDB` 注释：

```php
class Boot extends Cabal\Core\Application\Boot
{
    //...
    use Cabal\DB\Boot\HasDB;
    //... 
}
```

配置文件在 `conf/db.php` 中，`default` 的值为默认使用的_数据连接名称_，`mysql` 是数据库连接配置。
支持读写分离和多机器随机查询。`read` 和 `write` 内没有设置的配置项会使用外部的作为默认值。

```php
return[
    'default' => 'mysql',

    'mysql' => [
        'read' => [
            'host' => ['127.0.0.1', 'localhost', '0.0.0.0'], 
            'user' => 'readonly',
        ],
        'write' => [
            'user' => 'root',
        ],
        'host' => '127.0.0.1',
        'port' => '3306',
        'password' => '123456',
        'database' => 'cabal_demo',
    ],
];
```


?> Cabal-DB 会在每一次读/写后将_Swoole协程数据库连接_放回到连接池中（worker进程共享），以提供更高的资源利用率，
通常可保证同一个worker进程下 **_数据库连接数_ < _每秒请求数_**。

## 文档表结构

文档基于以下数据表结构进行阐述：

用户表 user：

| id  | username | password |  created_at          | 
| --- | -------- | -------- |  ------------------- |
| 1   | Cabal    | ...      |  2018-01-01 00:00:00 |
| 2   | User2    | ...      |  2018-01-02 00:00:00 |

文章表 article：

| id  | user_id  | status        | title        |  content               |  created_at          | 
| --- | -------- | ------------- | ------------ |  --------------------- |--------------------- |
| 1   | 1        | 1             | PHP 教程      |  ...............       |  2018-01-01 00:00:00 |
| 2   | 1        | 1             | PHP 简介      |  ...............       |  2018-01-02 00:00:00 |
| 3   | 1        | 1             | PHP 安装      |  ...............       |  2018-01-03 00:00:00 |
| 4   | 1        | 0             | 草稿          |  ...............       |  2018-01-04 00:00:00 |
| 5   | 2        | 1             | User2 的文章  |  ...............       |  2018-01-05 00:00:00 |

文章标签关联表 article_tag：

| id  | article_id  | tag_id  | created_at           | 
| --- | ----------- | ------- | -------------------- |
| 1   | 1           | 1       |  2018-01-01 00:00:00 |
| 2   | 1           | 4       |  2018-01-02 00:00:00 |
| 3   | 2           | 1       |  2018-01-03 00:00:00 |
| 4   | 2           | 3       |  2018-01-04 00:00:00 |
| 5   | 3           | 1       |  2018-01-05 00:00:00 |
| 6   | 3           | 2       |  2018-01-06 00:00:00 |

标签表 tag：

| id  | name    |
| --- | --------|
| 1   | PHP     |
| 2   | 安装    |
| 3   | 简介    |
| 4   | 教程    |

树状结构如下：

    .
    ├── 用户：Cabal
    │   ├── 文章：PHP 教程
    │   │   ├── 标签：PHP
    │   │   └── 标签：教程
    │   ├── 文章：PHP 简介
    │   │   ├── 标签：PHP
    │   │   └── 标签：简介
    │   ├── 文章：PHP 安装
    │   │   ├── 标签：PHP
    │   │   └── 标签：安装
    │   └── 草稿
    └── 用户：User2
        └── User2 的文章

## 查询

获取数据库引擎：
```
$db = $server->boot()->db(); 
```



### 查询示例：

**获取第一条记录:**
```php
return $db->table('user')->orderBy('id', 'ASC')->first(); 
```

返回：
```json
{
    "id": 1,
    "username": "Cabal",
    "password": "...",
    "created_at": "2018-01-01 05:00:00"
}
```

**WHERE 语句 `->where($cond, $params, $symbol = 'AND')`：**
```php
return $db->table('article')->where('id = ?', [1])->first();
// 当只有一个参数 $params 是可以不传递数组
return $db->table('article')->where('id = ?', 1)->first();
return $db->table('article')->where('status = ?', 1)->where('id = ?', 1)->first();
```

返回：
```json
{
    "id": 1,
    "user_id": 1,
    "status": 1,
    "title": "PHP 教程",
    "content": "PHP 是一种创建动态交互性站点的强有力的服务器端脚本语言。\nPHP 是免费的，并且使用广泛。对于像微软 ASP 这样的竞争者来说，PHP 无疑是另一种高效率的选项。\n",
    "created_at": "2018-01-02 05:00:00"
}
```

更多条件语句可以查看[更多API](/db_quickstart?id=更多api)



**LIMIT/OFFSET 语句 `->limit($limit, $offset = 0)`，`->offset($offset)`：**
```PHP
// LIMIT 1 OFFSET 2
return $db->table('article')->orderBy('id', 'ASC')->limit(1, 2)->rows();
return $db->table('article')->offset(2)->limit(1)->rows();
```

返回：
```json
[
    {
        "id": 3,
        "user_id": 1,
        "status": 1,
        "title": "PHP 安装",
        "content": "我需要什么？\n如需开始使用 PHP，您可以：\n\n使用支持 PHP 和 MySQL 的 web 主机\n在您的 PC 上安装 web 服务器，然后安装 PHP 和 MySQL。",
        "created_at": "2018-01-04 05:00:00"
    }
]

```


**JOIN 语句：**

```php
return $cabal->table('article')
    ->select(['article.id', 'user.username', 'article.title'])
    ->innerJoin('user', 'article.user_id = user.id')
    ->rows();
```

返回：
```json
[
    {
        "id": 1,
        "username": "Cabal",
        "title": "PHP 教程"
    },
    {
        "id": 2,
        "username": "Cabal",
        "title": "PHP 简介"
    },
    {
        "id": 3,
        "username": "Cabal",
        "title": "PHP 安装"
    },
    {
        "id": 4,
        "username": "Cabal",
        "title": "草稿"
    }
]
```


## 插入

插入数据返回的是最后插入记录的ID。
```php
$result = $db->table('user')->insert([
        'username' => 'user1',
        'password' => password_hash('123456', PASSWORD_DEFAULT),
        'created_at' => date('Y-m-d H:i:s'),
    ]);
```

## 编辑
编辑数据返回的是受影响的行数。
```php
$result = $db->table('user')->where('id = ?', 1)->update([
        'password' => password_hash('123456', PASSWORD_DEFAULT),
    ]);
```

## 删除
删除数据返回的是受影响的行数。
```php
$result = $db->table('user')->where('id = ?', 2)->delete();
```

## 指定数据库

想要指定数据库可以用 `->on($connectionName)` 方法：

```php
$db->on('connectionName')->table('user')->orderBy('id', 'ASC')->first(); 
$db->on('connectionName')->table('user')->where('id = ?', 2)->delete();
```

## 更多API

```php
$db->table('table_name')->select($fields, $append = false)

$db->table('table_name')->where($cond, $params, $symbol = 'AND')
$db->table('table_name')->whereIn($field, array $in, $symbol = 'AND')
$db->table('table_name')->orWhereIn($field, $in)
$db->table('table_name')->and($cond, $params)
$db->table('table_name')->or($cond, $params)

$db->table('table_name')->groupBy($fields)

$db->table('table_name')->join($way, $tableName, $on, $params = [])
$db->table('table_name')->leftJoin($tableName, $on, $params = [])
$db->table('table_name')->rightJoin($tableName, $on, $params = [])
$db->table('table_name')->innerJoin($tableName, $on, $params = [])

$db->table('table_name')->orderBy($field, $sort = 'ASC')
$db->table('table_name')->limit($limit, $offset = null)
$db->table('table_name')->offset($offset)

$db->table('table_name')->rows()
$db->table('table_name')->first()

$db->table('table_name')->count($field = '*')
$db->table('table_name')->sum($field)
$db->table('table_name')->max($field)
$db->table('table_name')->min($field)

$db->table('table_name')->insert($data)
$db->table('table_name')->update($data)
```



## 日志&事务

为了更高的利用资源，默认情况下每一次查询后，**查询接口对象（`Cabal\DB\Connection`）**会因为**没有被引用**而被销毁，销毁后对应的
**数据库连接（`Cabal\DB\Coroutine\MySQL`）**会被放回到统一的连接池中（worker进程共享），很可能你在同一个请求中的两次查数据库询用的是两个不同的连接。

而查询日志是保存在**查询接口对象（`Cabal\DB\Connection`）**里的，
所以我们无法用 `$db->getQueryLogs()` 获取查询日志。

同样的，如果要使用事务，**必须保证事务的操作在同一个数据库连接中完成**，而在**默认**的情况下，同一次（HTTP）请求的每次操作都可能不是同一个数据库连接。

所以如果我们需要使用事务的时候我们需要在同一个**查询接口对象（`Cabal\DB\Connection`）**上进行操作，我们应该在控制器中引用一个查询接口对象：

```php
$conn = $db->getConnection(); 
```

?> 该方法第一个参数是_连接名称_，不传为默认连接，第二个参数是_是否可写_：`->getConnection($name = null, $writeable = false)`，**在没有读写分离的情况下可以忽略第二个参数**

现在我们再用进行数据库读写操作都在同一个**查询接口对象**和同一个**数据库连接**下进行操作了!

### 事务方法一：
```php
$conn = $db->getConnection(); 

$conn->begin();
try {
    // code ...

    $conn->commit();
} catch (\Exception $e) {
    $conn->rollback();
    throw $e;
}
```

### 事务方法二：
```php
$conn = $db->getConnection(); 
$conn->transaction(\Closure $callable);
```
!> 使用 `$conn->transaction` 方法异常还是会被抛出。

### 获取日志方法一
每次查询设置日志存储变量（数组）`->logQueryTo(array &$logStore)`：
```php
// 日志存储数组
$logs = [];  
$db->table('article')->where('id = ?', [1])->logQueryTo($logs)->first();
$db->table('article')->where('status = ?', 1)->where('id = ?', 1)->logQueryTo($logs)->first();
// 关联查询内的查询会自动沿用最顶层的存储变量
$user = $db->table('user')->logQueryTo($logs)->first();
$articleList = $user->has('article');
return $logs; 
```

### 获取日志方法二
在控制器中引用一个查询接口对象：
```php
$conn = $db->getConnection(); 
$conn->table('article')->where('id = ?', [1])->first();
$conn->table('article')->where('status = ?', 1)->where('id = ?', 1)->first();
// 关联查询
$user = $conn->table('user')->first();
$articleList = $user->has('article');
return $conn->getQueryLogs(); 
```

返回：
```json
[
    {
        "sql": "SELECT `article`.* FROM `article` WHERE id = ? LIMIT 1",
        "params": [
            1
        ],
        "millisecond": 0.8149147033691406,
        "errno": 0,
        "error": ""
    },
    {
        "sql": "SELECT `article`.* FROM `article` WHERE status = ? AND id = ? LIMIT 1",
        "params": [
            1,
            1
        ],
        "millisecond": 0.7441043853759766,
        "errno": 0,
        "error": ""
    },
    {
        "sql": "SELECT `user`.* FROM `user` LIMIT 1",
        "params": [
            
        ],
        "millisecond": 0.6339550018310547,
        "errno": 0,
        "error": ""
    },
    {
        "sql": "SELECT `article`.* FROM `article` WHERE `user_id` = ?",
        "params": [
            1
        ],
        "millisecond": 0.6520748138427734,
        "errno": 0,
        "error": ""
    }
]
```