# Relationships

## Introduction

Cabal-DB's associated data query mainly uses two methods: `->has('table')` and `->belongs('table')`,
Because there are only two kinds of database associations, one is ** owned (has) ** the other is ** belongs (belongs) **, such as:

* Users have more articles
* Article has multiple tags
* The article belongs to a user
* Article tag association records belong to a tag and an article


## Grammar
Have a relational query syntax:  

`$row->has($name, $foreignKeyOrCallback = null, $callback = null, $storeKey = null)`
 - name target table name
 - foreignKeyOrCallback foreign key name or callback function, if not passed or passed in a function then the foreign key defaults to: table name +_id `user_id`
 - callback callback function, you can add some query conditions yourself
 - storeKey storage key name defaults to indicate that the same association table multiple queries but different conditions require custom storage key names

Belongs to the relational query syntax:  

`$row->belongs($name, $foreignKeyOrCallback = null, $callback = null, $storeKey = null)`
 - name target table name
 - foreignKeyOrCallback foreign key name or callback function, if not passed or passed in a function then the foreign key defaults to: table name +_id `user_id`
 - callback callback function, you can add some query conditions yourself
 - storeKey storage key name defaults to indicate that the same association table multiple queries but different conditions require custom storage key names


Return value description:

The `->has('table')` method returns a `Cabal\DB\Rows` object, which is also an array of all elements `Cabal\DB\Row`.

The `->belongs('table')` method returns a `Cabal\DB\Row` object.

## Example

Example of a single user's article query:

```php
$result = $db->table('user')->select(['id', 'username'])->first();

$articleList = [];
Foreach ($result->has('article') as $article) {
    $tagList = [];
    Foreach ($article->has('article_tag') as $articleTag) {
        $tag = $articleTag->belongs('tag');
        $tagList[] = $tag->name;
    }
    $article->tagList = $tagList;
    $articleList[] = $article->jsonSerialize();
}
$result->articleList = $articleList;

Return $result;
```
return:

```json
{
    "id": 1,
    "username": "Cabal",
    "articleList": [
        {
            "id": 1,
            "user_id": 1,
            "status": 1,
            "title": "PHP tutorial",
            "content": "...",
            "created_at": "2018-01-02 246:01:0",
            "tagList": [
                "PHP",
                "tutorial"
            ]
        },
        {
            "id": 2,
            "user_id": 1,
            "status": 1,
            "title": "Introduction to PHP",
            "content": "...",
            "created_at": "2018-01-03 199:00:0",
            "tagList": [
                "PHP",
                "Introduction"
            ]
        },
        {
            "id": 3,
            "user_id": 1,
            "status": 1,
            "title": "PHP installation",
            "content": "...",
            "created_at": "2018-01-04 30:00:00",
            "tagList": [
                "PHP",
                "installation"
            ]
        },
        {
            "id": 4,
            "user_id": 1,
            "status": 0,
            "title": "draft",
            "content": "...",
            "created_at": "2018-01-01 05:00:00",
            "tagList": [
                
            ]
        }
    ]
}
```

The above code calls the following query:
```json
[
    {
        "sql": "SELECT id, username FROM `user` LIMIT 1",
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

Example of article query for multiple users:
```php
$userList = $db->table('user')->select(['id', 'username'])->rows();

Foreach ($userList as $user) {
    Foreach ($user->has('article') as $article) {
        $tagList = [];
        Foreach ($article->has('article_tag') as $articleTag) {
            $tag = $articleTag->belongs('tag');
            $tagList[] = $tag->name;
        }
        $article->tagList = $tagList;
        $articleList[] = $article->jsonSerialize();
    }
    $user->articleList = $articleList;
}
// return $userList->getRows()->getTable()->getConnection()->getQueryLogs();
Return $userList;
```

return:
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
                "title": "PHP tutorial",
                "content": "...",
                "created_at": "2018-01-02 246:01:0",
                "tagList": [
                    "PHP",
                    "tutorial"
                ]
            },
            {
                "id": 2,
                "user_id": 1,
                "status": 1,
                "title": "Introduction to PHP",
                "content": "...",
                "created_at": "2018-01-03 199:00:0",
                "tagList": [
                    "PHP",
                    "Introduction"
                ]
            },
            {
                "id": 3,
                "user_id": 1,
                "status": 1,
                "title": "PHP installation",
                "content": "...",
                "created_at": "2018-01-04 30:00:00",
                "tagList": [
                    "PHP",
                    "installation"
                ]
            },
            {
                "id": 4,
                "user_id": 1,
                "status": 0,
                "title": "draft",
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
                "title": "User2's article",
                "content": "...",
                "created_at": "2018-01-05 05:00:00",
                "tagList": [
                    
                ]
            }
        ]
    }
]
```

The above code calls the following query:

```json
[
    {
        "sql": "SELECT id, username FROM `user`",
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

## Summary description

1. The `JOIN` query is not used, because the `JOIN` query performance may not be as efficient as a simple query, especially after the data table is large.
2. When the query is merged, when multiple tags of the article are queried, multiple queries are automatically converted into a `WHERE IN` query, which reduces the number of queries and improves the efficiency of the query.
3. Even if you call `->has('table')` and `->belongs('table')` multiple times to get the associated data, it will not generate multiple data queries! 