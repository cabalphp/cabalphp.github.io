# 关联查询

## 简介

Cabal-DB 的关联数据查询主要用了两个方法：`->has('table')` 和`->belongs('table')`，
因为其实数据库关联关系只有两种，一种是**拥有（has）**另一种是**属于（belongs）**，如：

* 用户拥有更多个文章
* 文章拥有多个标签
* 文章属于一个用户
* 文章标签关联记录属于一个标签和一篇文章



`->has('table')` 方法返回的是一个 `Cabal\DB\Rows` 对象里，也是一个所有元素都是 `Cabal\DB\Row` 的数组。

`->belongs('table')` 方法返回的是一个 `Cabal\DB\Row` 对象。

## 示例

单个用户的文章查询示例：

```php
$result = $db->table('user')->select(['id', 'username'])->first();

$articleList = [];
foreach ($result->has('article') as $article) {
    $tagList = [];
    foreach ($article->has('article_tag') as $articleTag) {
        $tag = $articleTag->belongs('tag');
        $tagList[] = $tag->name;
    }
    $article->tagList = $tagList;
    $articleList[] = $article->jsonSerialize();
}
$result->articleList = $articleList;

return $result;
```
返回：

```json
{
    "id": 1,
    "username": "Cabal",
    "articleList": [
        {
            "id": 1,
            "user_id": 1,
            "status": 1,
            "title": "PHP 教程",
            "content": "...",
            "created_at": "2018-01-02 246:01:0",
            "tagList": [
                "PHP",
                "教程"
            ]
        },
        {
            "id": 2,
            "user_id": 1,
            "status": 1,
            "title": "PHP 简介",
            "content": "...",
            "created_at": "2018-01-03 199:00:0",
            "tagList": [
                "PHP",
                "简介"
            ]
        },
        {
            "id": 3,
            "user_id": 1,
            "status": 1,
            "title": "PHP 安装",
            "content": "...",
            "created_at": "2018-01-04 30:00:00",
            "tagList": [
                "PHP",
                "安装"
            ]
        },
        {
            "id": 4,
            "user_id": 1,
            "status": 0,
            "title": "草稿",
            "content": "...",
            "created_at": "2018-01-01 05:00:00",
            "tagList": [
                
            ]
        }
    ]
}
```

上面的代码调用了以下的查询语句：
```json
[
    {
        "sql": "SELECT id,username FROM `user` LIMIT 1",
        "params": [
        ]
    },
    {
        "sql": "SELECT `article`.* FROM `article` WHERE `user_id` = ?",
        "params": [
            1
        ]
    },
    {
        "sql": "SELECT `article_tag`.* FROM `article_tag` WHERE article_id IN (?, ?, ?, ?)",
        "params": [
            1,
            2,
            3,
            4
        ]
    },
    {
        "sql": "SELECT `tag`.* FROM `tag` WHERE id IN (?, ?, ?, ?)",
        "params": [
            1,
            4,
            3,
            2
        ]
    }
]
```

多个用户的文章查询示例：
```php
$userList = $db->table('user')->select(['id', 'username'])->rows();

foreach ($userList as $user) {
    foreach ($user->has('article') as $article) {
        $tagList = [];
        foreach ($article->has('article_tag') as $articleTag) {
            $tag = $articleTag->belongs('tag');
            $tagList[] = $tag->name;
        }
        $article->tagList = $tagList;
        $articleList[] = $article->jsonSerialize();
    }
    $user->articleList = $articleList;
}
// return $userList->getRows()->getTable()->getConnection()->getQueryLogs();
return $userList;
```

返回：
```json
[
    {
        "id": 1,
        "username": "Cabal",
        "articleList": [
            {
                "id": 1,
                "user_id": 1,
                "status": 1,
                "title": "PHP 教程",
                "content": "...",
                "created_at": "2018-01-02 246:01:0",
                "tagList": [
                    "PHP",
                    "教程"
                ]
            },
            {
                "id": 2,
                "user_id": 1,
                "status": 1,
                "title": "PHP 简介",
                "content": "...",
                "created_at": "2018-01-03 199:00:0",
                "tagList": [
                    "PHP",
                    "简介"
                ]
            },
            {
                "id": 3,
                "user_id": 1,
                "status": 1,
                "title": "PHP 安装",
                "content": "...",
                "created_at": "2018-01-04 30:00:00",
                "tagList": [
                    "PHP",
                    "安装"
                ]
            },
            {
                "id": 4,
                "user_id": 1,
                "status": 0,
                "title": "草稿",
                "content": "...",
                "created_at": "2018-01-01 39:00:00",
                "tagList": [
                    
                ]
            }
        ]
    },
    {
        "id": 2,
        "username": "User2",
        "articleList": [
            {
                "id": 5,
                "user_id": 2,
                "status": 0,
                "title": "User2 的文章",
                "content": "...",
                "created_at": "2018-01-05 05:00:00",
                "tagList": [
                    
                ]
            }
        ]
    }
]
```

上面的代码调用了以下的查询语句：

```json
[
    {
        "sql": "SELECT id,username FROM `user`",
        "params": [
            
        ],
    },
    {
        "sql": "SELECT `article`.* FROM `article` WHERE user_id IN (?, ?)",
        "params": [
            1,
            2
        ],
    },
    {
        "sql": "SELECT `article_tag`.* FROM `article_tag` WHERE article_id IN (?, ?, ?, ?, ?)",
        "params": [
            1,
            2,
            3,
            4,
            5
        ],
    },
    {
        "sql": "SELECT `tag`.* FROM `tag` WHERE id IN (?, ?, ?, ?)",
        "params": [
            1,
            4,
            3,
            2
        ],
    }
]
```

## 总结说明

1. 没有使用 `JOIN` 查询，因为 `JOIN` 查询性能可能没有简单查询效率高，尤其是数据表大了之后，
2. 合并了查询，查询多篇文章的标签时，自动将多条查询转化成 `WHERE IN` 查询，减少查询次数，提高查询效率。
3. 即使多次调用 `->has('table')` 和`->belongs('table')` 获取关联数据也不会产生多次的数据查询！ 
