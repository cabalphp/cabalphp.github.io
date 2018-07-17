# Model

## Overview

To use the model you need to modify `usr/init.php` first, and cancel the `\Cabal\DB\Model::setDBManager($server->db());` comment.

By the way, [Martin Fowler](https://en.wikipedia.org/wiki/Martin_Fowler ':ignore') long time ago began to question whether ORM is good or not [[Click to view original](https://martinfowler.com/bliki/OrmHate.html ':ignore')].

After using ORM, the development efficiency will be much improved. However, in a complex business scenario, after the object is passed around, whether the value of the object and the value in the database become obscure, it will increase the complexity of the code and the difficulty of maintenance. high.


## Definition

Here is one of the simplest model classes:

```php
Use Cabal\DB\Model;
Class User extends Model
{
    // Table Name
    Protected $tableName = 'user';
}
```

The model class also supports the following configuration and syntax:

```php
Use Cabal\DB\Model;
Use Cabal\DB\Table;

Class User extends Model
{
    // Table Name
    Protected $tableName = 'user';
    // date fields These fields convert fields to Carbon\Carbon objects
    Protected $dates = array('created_at', 'deleted_at', 'updated_at');
    / / Whether to use the data timestamp - created_at & updated_at field will automatically fill the creation time and edit time
    Protected $timestamps = true;
    // The field to be appended to toArray needs to define the __getXX magic method
    Protected $appends = ['anno_name'];
    / / Allow fields filled with the fill method
    Protected $fillable = array();
    // Fields that are not allowed to be autofilled
    Protected $guarded = array('*');
    // date field database save format
    Protected $dateFormat = 'Ymd H:i:s';

    // Fields that do not exist in the database can be obtained using magic method support
    Public function __getAnnoName($value = null)
    {
        Return 'AnnoName';
    }

    / / Complex data format can be used to write a sequence of words with a pair of magic methods, read deserialization
    Public function __getJson($value = null)
    {
        Return json_decode($value, true);
    }
    Public function __setJson($value)
    {
        $this->dbData['json'] = json_encode($value);
    }

    // can customize the associated data field
    Public function __getPublishArticles()
    {
        Return $this->has(Article::class, function (Table $table) {
            $table->where('status = ?', 1);
        }, 'publishedArticle');
    }
}
```


## CRUD


### Query
The query syntax is the same as the DB base syntax, except that you need to start a query with `ModelName::query()`.

```php
User::query()->where('id = ?', 1)->first();
User::query()->rows();
User::query()->paginate(3, 2);
```

### Insert

A new model object calls the `->save()` method to indicate creation.

```php
$user = new User;
$user->name = uniqid();
$user->save();
```

### Update
An existing model object calling the `->save()` method will only save the modified field, and will not manipulate the data if it has not been used.
```php
$user = User::query()->first();
$user->name = 'new name';
$user->save();
```

### Delete

```php
$user = User::query()->first();
$user->delete();
```

## Magic method

The `__` start function is similar to PHP's pattern method. The method name is named after the hump. For example, the field `->anno_name` corresponds to the `__getAnnoName` method.

A pair of magic methods can be used to automatically serialize and deserialize database fields:
```php
Public function __getJson($value = null)
{
    Return json_decode($value, true);
}
Public function __setJson($value)
{
    $this->dbData['json'] = json_encode($value);
}
```

## Relationships

The associated query of the model is similar to the syntax of [associative query](/db_relationships.md), except that the first parameter is changed from the indication to the class name:

`$user->has($model, $foreignKeyOrCallback = null, $callback = null, $storeKey = null);`
 - className target class name
 - foreignKeyOrCallback foreign key name or callback function, if not passed or passed in a function then the foreign key defaults to: table name +_id `user_id`
 - callback callback function, you can add some query conditions yourself
 - storeKey storage key name defaults to class name, the same association class multiple queries but different conditions require custom storage key names

`$article->belongs($model, $foreignKeyOrCallback = null, $callback = null, $storeKey = null);`
 - className target class name
 - foreignKeyOrCallback foreign key name or callback function, if not passed or passed in a function then the foreign key defaults to: target table table name +_id `user_id`
 - callback callback function, you can add some query conditions yourself
 - storeKey storage key name defaults to class name, the same association class multiple queries but different conditions require custom storage key names

```php
Use Cabal\DB\Table;

$articles = $user->has(Article::class, function (Table $table) {
    $table->where('status = ?', 1);
}, 'publishedArticle');
```