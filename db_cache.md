# 缓存

## 配置

要使用缓存请先修改 `usr/boot.php`，取消 `Boot` 类中的 `use Cabal\Core\Cache\Boot\HasCache` 注释：

```php
class Boot extends Cabal\Core\Application\Boot
{
    //...
    use Cabal\Core\Cache\Boot\HasCache;
    //... 
}
```
然后在控制器中可以用 `$server->cache()` 获取到缓存引擎：

```php
$route->get('/', function (Server $server, Request $request, $vars = []) {
    // cache for 1 minute
    $date = $server->cache()->remember('key', 1, function () {
        return date('Y-m-d H:i:s');
    });
    return $date;
});
```


## 缓存API

```php
// 写入缓存
$cache->set($key, $val, $minutes);
// 永久缓存
$cache->forever($key, $val);
// 获取缓存
$cache->get($key, $default = null);
// 清除缓存
$cache->del($key);
// del的别名
$cache->forget($key);
// 自增
$cache->increment($key, $amount = 1);
// 自建
$cache->decrement($key, $amount = 1);
// 获取并删除
$cache->pull($key, $default = null);
// 获取或写入，如果缓存不存在则将 callback 的返回值写入缓存并返回
$cache->remember($key, $minutes, \Closure $callback);
```