# Cache

## Configuration

To use the cache, first modify `usr/boot.php` and undo `use Cabal\Core\Cache\Boot\HasCache` in the `Boot` class.

```php
Class Boot extends Cabal\Core\Application\Boot
{
    //...
    Use Cabal\Core\Cache\Boot\HasCache;
    //...
}
```
Then in the controller can get the cache engine with `$server->cache()`?:

```php
$route->get('/', function (Server $server, Request $request, $vars = []) {
    // cache for 1 minute
    $date = $server->cache()->remember('key', 1, function () {
        Return date('Y-m-d H:i:s');
    });
    Return $date;
});
```


## Cache API

```php
// write cache
$cache->set($key, $val, $minutes);
// permanent cache
$cache->forever($key, $val);
// get the cache
$cache->get($key, $default = null);
// clear cache
$cache->del($key);
//del alias
$cache->forget($key);
// increase
$cache->increment($key, $amount = 1);
// Self-built
$cache->decrement($key, $amount = 1);
// get and delete
$cache->pull($key, $default = null);
// get or write, if the cache does not exist, write the return value of callback to the cache and return
$cache->remember($key, $minutes, \Closure $callback);
```