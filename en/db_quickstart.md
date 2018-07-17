# Database Getting Started

## Overview

To use Cabal-DB you need to modify `usr/boot.php` first, and cancel the `use Cabal\DB\ServerHasDB` in the `Boot` class.

```php
Class Boot extends Cabal\Core\Application\Boot
{
    //...
    Use Cabal\DB\ServerHasDB;
    //... 
}
```

The configuration file is in `conf/db.php`, the value of `default` is the default _data connection name _, and `mysql` is the database connection configuration.
Support for read-write separation and multi-machine random queries. Configuration items not set in `read` and `write` will use the external as the default.

```php
Return[
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


?> Cabal-DB will put the _Swoole coroutine database connection _ back into the connection pool (worker process sharing) after each read/write to provide higher resource utilization.
Usually the number of __database connections _ < _ requests per second _** under the same worker process is guaranteed.

## Document Table Structure

The documentation is based on the following data sheet structure:

User table user:

| id | username | password | created_at | 
| --- | -------- | -------- | ------------------- |
| 1 | Cabal | ... | 2018-01-01 00:00:00 |
| 2 | User2 | ... | 2018-01-02 00:00:00 |

Article table article:

| id | user_id | status | title | content | created_at | 
| --- | -------- | ------------- | ------------ | --------- ------------ |--------------------- |
| 1 | 1 | 1 | PHP Tutorial | ............... | 2018-01-01 00:00:00 |
| 2 | 1 | 1 | Introduction to PHP | ............... | 2018-01-02 00:00:00 |
| 3 | 1 | 1 | PHP Installation | ............... | 2018-01-03 00:00:00 |
| 4 | 1 | 0 | Draft | ............... | 2018-01-04 00:00:00 |
| 5 | 2 | 1 | User2's article | ............... | 2018-01-05 00:00:00 |

Article tag association table article_tag:

| id | article_id | tag_id | created_at | 
| --- | ----------- | ------- | -------------------- |
| 1 | 1 | 1 | 2018-01-01 00:00:00 |
| 2 | 1 | 4 | 2018-01-02 00:00:00 |
| 3 | 2 | 1 | 2018-01-03 00:00:00 |
| 4 | 2 | 3 | 2018-01-04 00:00:00 |
| 5 | 3 | 1 | 2018-01-05 00:00:00 |
| 6 | 3 | 2 | 2018-01-06 00:00:00 |

Tag table tag:

| id | name |
| --- | --------|
| 1 | PHP |
| 2 | Installation |
| 3 | Introduction |
| 4 | Tutorial |

The tree structure is as follows:

    .
    ├── User: Cabal
    │ ├── Article: PHP Tutorial
    │ │ ├── Tags: PHP
    │ │ └── Tags: Tutorial
    │ ├── Article: Introduction to PHP
    │ │ ├── Tags: PHP
    │ │ └── Tags: Introduction
    │ ├── Article: PHP installation
    │ │ ├── Tags: PHP
    │ │ └── Label: Installation
    │ └── Draft
    └── User: User2
        └── User2's article

## Inquire

Get the database engine:
```
$db = $server->db(); 
```



### Query example:

**Get the first record:**
```php
Return $db->table('user')->orderBy('id', 'ASC')->first(); 
```

return:
```json
{
    "id": 1,
    "username": "Cabal",
    "password": "...",
    "created_at": "2018-01-01 05:00:00"
}
```

**WHERE statement `->where($cond, $params, $symbol = 'AND')`:**
```php
Return $db->table('article')->where('id = ?', [1])->first();
/ / When there is only one parameter $ params can not pass the array
Return $db->table('article')->where('id = ?', 1)->first();
Return $db->table('article')->where('status = ?', 1)->where('id = ?', 1)->first();
```

return:
```json
{
    "id": 1,
    "user_id": 1,
    "status": 1,
    "title": "PHP tutorial",
    "content": "PHP is a powerful server-side scripting language for creating dynamic interactive sites. \nPHP is free and widely used. For competitors like Microsoft ASP, PHP is definitely another Efficient options.\n",
    "created_at": "2018-01-02 05:00:00"
}
```

More conditional statements can be viewed [more API](/db_quickstart?id=more api)



**LIMIT/OFFSET statement `->limit($limit, $offset = 0)`,`->offset($offset)`:**
```PHP
// LIMIT 1 OFFSET 2
Return $db->table('article')->orderBy('id', 'ASC')->limit(1, 2)->rows();
Return $db->table('article')->offset(2)->limit(1)->rows();
```

return:
```json
[
    {
        "id": 3,
        "user_id": 1,
        "status": 1,
        "title": "PHP installation",
        "content": "What do I need?\nTo get started with PHP, you can: \n\nUse a web host that supports PHP and MySQL\n Install a web server on your PC, then install PHP and MySQL." ,
        "created_at": "2018-01-04 05:00:00"
    }
]

```


**JOIN statement: **

```php
Return $cabal->table('article')
    ->select(['article.id', 'user.username', 'article.title'])
    ->innerJoin('user', 'article.user_id = user.id')
    ->rows();
```

return:
```json
[
    {
        "id": 1,
        "username": "Cabal",
        "title": "PHP tutorial"
    },
    {
        "id": 2,
        "username": "Cabal",
        "title": "Introduction to PHP"
    },
    {
        "id": 3,
        "username": "Cabal",
        "title": "PHP installation"
    },
    {
        "id": 4,
        "username": "Cabal",
        "title": "draft"
    }
]
```


## Pagination
```php
Return $db->table('user')->paginate(3, 2);
```

return:
```json
{
    "lastPage": 4,
    "prePage": 2,
    "currentPage": 3,
    "total": 7,
    "offset": 4,
    "limit": 2,
    "data":[
        {
            "id": "5",
            "username": "xxx1",
            "password": "xxx1",
            "created_at":"2018-04-30 18:23:34"
        },
        {
            "id": "6",
            "username": "xxx1",
            "password": "xxx3",
            "created_at":"2018-04-30 18:24:07"
        }
    ]
}
```


## Insert

The inserted data returns the ID of the last inserted record.
```php
$result = $db->table('user')->insert([
        'username' => 'user1',
        'password' => password_hash('123456', PASSWORD_DEFAULT),
        'created_at' => date('Ymd H:i:s'),
    ]);
```

## Edit
The edit data returns the number of rows affected.
```php
$result = $db->table('user')->where('id = ?', 1)->update([
        'password' => password_hash('123456', PASSWORD_DEFAULT),
    ]);
```

## Delete
Deleting data returns the number of rows affected.
```php
$result = $db->table('user')->where('id = ?', 2)->delete();
```

## Specifying the database

To specify a database you can use the `->on($connectionName)` method:

```php
$db->on('connectionName')->table('user')->orderBy('id', 'ASC')->first(); 
$db->on('connectionName')->table('user')->where('id = ?', 2)->delete();
```

## More API

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
$db->table('table_name')->paginate(($currentPage, $perPage = 20, $columns = ['*']))
$db->table('table_name')->first()

$db->table('table_name')->count($field = '*')
$db->table('table_name')->sum($field)
$db->table('table_name')->max($field)
$db->table('table_name')->min($field)

$db->table('table_name')->insert($data)
$db->table('table_name')->update($data)
```



## Log & Transaction

In order to make higher use of resources, by default, after each query, the ** query interface object (`Cabal\DB\Connection`)** will be destroyed because ** is not referenced**, corresponding to the destruction
**Database connection (`Cabal\DB\Coroutine\MySQL`)** will be put back into the unified connection pool (worker process sharing), it is likely that you check the database query twice in the same request Two different connections.

The query log is stored in the **Query Interface object (`Cabal\DB\Connection`)**.
So we can't get the query log with `$db->getQueryLogs()`.

Similarly, if you want to use transactions, ** must ensure that the operation of the transaction is completed in the same database connection, and in the case of **default**, each operation of the same (HTTP) request may not be the same A database connection.

So if we need to use a transaction, we need to operate on the same Query Interface object (`Cabal\DB\Connection`)**, we should reference a Query Interface object in the controller:

```php
$conn = $db->getConnection(); 
```

?> The first parameter of the method is _connection name _, not passed as the default connection, the second parameter is _ whether it can be written _:`->getConnection($name = null, $writeable = false)`,** The second parameter can be ignored without read/write separation**

Now we use the database read and write operations in the same ** query interface object ** and the same ** database connection ** operation!

### Transaction Method One:
```php
$conn = $db->getConnection(); 

$conn->begin();
Try {
    // code ...

    $conn->commit();
} catch (\Exception $e) {
    $conn->rollback();
    Throw $e;
}
```

### Transaction Method 2:
```php
$conn = $db->getConnection(); 
$conn->transaction(\Closure $callable);
```
!> Using the `$conn->transaction` method exception will still be thrown.

### Get log method one
Set the log storage variable (array) `->logQueryTo(array &$logStore)` for each query:
```php
// log storage array
$logs = [];  
$db->table('article')->where('id = ?', [1])->logQueryTo($logs)->first();
$db->table('article')->where('status = ?', 1)->where('id = ?', 1)->logQueryTo($logs)->first();
// The query in the associated query will automatically inherit the topmost stored variable
$user = $db->table('user')->logQueryTo($logs)->first();
$articleList = $user->has('article');
Return $logs; 
```

### Getting Log Method 2
Reference a query interface object in the controller:
```php
$conn = $db->getConnection(); 
$conn->table('article')->where('id = ?', [1])->first();
$conn->table('article')->where('status = ?', 1)->where('id = ?', 1)->first();
// associated query
$user = $conn->table('user')->first();
$articleList = $user->has('article');
Return $conn->getQueryLogs(); 
```

return:
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