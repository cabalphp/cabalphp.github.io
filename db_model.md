# 数据库入门

## 概述

要使用 Cabal-DB 需要先修改 `usr/init.php`，取消 `\Cabal\DB\Model::setDBManager($server->db());` 注释。


## 定义

下面是一个最简单的 模型类：

```php
use Cabal\DB\Model;
class User extends Model
{
    // 表名
    protected $tableName = 'user';
}
```

模型类还支持下面的配置和语法：

```php
use Cabal\DB\Model;
use Cabal\DB\Table;

class User extends Model
{
    // 表名
    protected $tableName = 'user';
    // 日期字段 这些字段会字段转换为 Carbon\Carbon 对象
    protected $dates = array('created_at', 'deleted_at', 'updated_at');
    // 是否使用数据时间戳 - created_at&updated_at 字段会自动填充创建时间也编辑时间
    protected $timestamps = true;
    // toArray 时会追加的字段 需要定义 __getXX魔术方法
    protected $appends = ['anno_name'];
    // 允许用 fill 方法填充的字段
    protected $fillable = array();
    // 不允许自动填充的字段
    protected $guarded = array('*');
    // 日期字段 数据库保存格式
    protected $dateFormat = 'Y-m-d H:i:s';

    // 数据库不存在的字段 可以使用魔术方法支持获取
    public function __getAnnoName($value = null)
    {
        return 'AnnoName';
    }

    // 复杂的数据格式可以用一对魔术方法实现 写入序列话，读取反序列化
    public function __getJson($value = null)
    {
        return json_decode($value, true);
    }
    public function __setJson($value)
    {
        $this->dbData['json'] = json_encode($value);
    }

    // 可以自定义关联数据字段
    public function __getPublishArticles()
    {
        return $this->has(Article::class, function (Table $table) {
            $table->where('status = ?', 1);
        }, 'publishedArticle');
    }
}
```


## 增删改查


### 查询
查询语法和 DB 基础语法一致，只是需要用 `ModelName::query()` 开始一个查询。

```php
User::query()->where('id = ?', 1)->first();
User::query()->rows();
User::query()->paginate(3, 2);
```

### 创建

一个新的模型对象调用 `->save()` 方法表示创建。

```php
$user = new User;
$user->name = uniqid();
$user->save();
```

### 编辑
一个已存在的模型对象 调用 `->save()` 方法只会保存修改过的字段，如果没用修改过的字段不会操作数据。
```php
$user = User::query()->first();
$user->name = 'new name';
$user->save();
```

### 删除

```php
$user = User::query()->first();
$user->delete();
```

## 魔术方法

采用的是和PHP的模式方法类似的 `__` 开头函数，方法名采用驼峰命名，如字段 `->anno_name` 对应的是 `__getAnnoName` 方法。

可以采用一对魔术方法实现数据库字段自动序列化和反序列化：
```php
public function __getJson($value = null)
{
    return json_decode($value, true);
}
public function __setJson($value)
{
    $this->dbData['json'] = json_encode($value);
}
```

## 关联查询

模型的关联查询和[关联查询](/db_relationships.md)的语法类似，只是第一个参数从表明变成了类名：

`$user->has($model, $foreignKeyOrCallback = null, $callback = null, $storeKey = null);`
 - className 目标类名
 - foreignKeyOrCallback 外键名称或者回调函数，如果不传或传入的是一个函数则外键默认为：表名+_id  `user_id`
 - callback 回调函数，可以自己追加一些查询条件
 - storeKey 存储键名 默认为类名，同一个关联类多次查询但是条件不同需要自定义存储键名

`$article->belongs($model, $foreignKeyOrCallback = null, $callback = null, $storeKey = null);`
 - className 目标类名
 - foreignKeyOrCallback 外键名称或者回调函数，如果不传或传入的是一个函数则外键默认为：目标表表名+_id  `user_id`
 - callback 回调函数，可以自己追加一些查询条件
 - storeKey 存储键名 默认为类名，同一个关联类多次查询但是条件不同需要自定义存储键名

```php
use Cabal\DB\Table;

$articles = $user->has(Article::class, function (Table $table) {
    $table->where('status = ?', 1);
}, 'publishedArticle');
```