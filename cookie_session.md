# Session & Cookie


## Cookie

获取 Cookie：
```php
$request->cookie('name');
```

写入 Cookie：
```php
$response->withCookie($key, $value = '', $expire = 0, $path = '/', $domain = '', $secure = false, $httponly = false);
```
方法和php原生的 set_cookie 一致。

完整示例：
```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Request;

$route->get('/', function (Server $server, Request $request, $vars = []) {
    $response = new Response();
    $times = intval($request->cookie('times', 1)); 
    // 要重新赋值，PSR-7要求消息每次被修改都是一个新的对象
    $response = $response->withCookie('times', ++$times);
    return $response;
});
```

## Session
要使用session的话首先需要添加中间件 `Cabal\Core\Http\Middleware\EnableSession`，在routes.php 中加入以下代码：
```php
use Cabal\Core\Http\Middleware\EnableSession;
//...
$dispatcher->addMiddleware('enableSession', EnableSession::class);
```

Session 持久化存储依赖缓存服务，所以还要修改 `usr/boot.php`，取消 `Boot` 类中的 `use Cabal\Core\Cache\Boot\HasCache` 注释：
```php
class Boot extends Cabal\Core\Application\Boot
{
    //...
    use Cabal\Core\Cache\Boot\HasCache;
    //... 
}
```


接着需要使用session的路由控制器上使用该中间件，然后你就可以通过 `$request->session()` 方法获取到和 `$_SESSION` 一样方便一个变量：

```php
$route->any('/', function (Server $server, Request $request, $vars = []) {
    $response = new Response();
    $session = $request->session();
    if ($request->has('username')) {
        // 写入
        $session['username'] = $request->input('username');
    }
    $response->getBody()->write(
        isset($session['username']) ? "已登录: {$session['username']}" : '未登录'
    );
    return $response;
})->middleware(['enableSession']); 
```

`$request->session()` 返回的是一个实现了 `\Iterator`, `\ArrayAccess`, `\Countable`, `\JsonSerializable` 的 `Cabal\Core\Http\Session` 对象，所以你可以和使用 `$_SESSION` 一样使用它，也可以作为一个对象使用。

?> `enableSession` 中间件会在请求结束前将session中的数据持久化。

!> 不建议用 `$_SESSION` 作为变量名接收 `$request->session()` 的返回值。